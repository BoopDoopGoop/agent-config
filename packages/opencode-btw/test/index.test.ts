import { describe, expect, test } from "bun:test";
import type { PluginInput } from "@opencode-ai/plugin";
import BtwPlugin, { type BtwClient } from "../src/index";

type PromptCall = Parameters<BtwClient["session"]["prompt"]>[0];
type ForkResult = Awaited<ReturnType<BtwClient["session"]["fork"]>>;
type MessagesCall = Parameters<BtwClient["session"]["messages"]>[0];
type WorkerMessages = NonNullable<
  Awaited<ReturnType<BtwClient["session"]["messages"]>>["data"]
>;
function deferred<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>((resolvePromise) => {
    resolve = resolvePromise;
  });
  return { promise, resolve };
}

function mockClient(options?: {
  workerAnswer?: string;
  workerMessages?: WorkerMessages;
  workerError?: unknown;
  workerAssistantError?: unknown;
  forkError?: unknown;
  deliveryError?: unknown;
  deleteError?: unknown;
}) {
  const prompts: PromptCall[] = [];
  const messages: MessagesCall[] = [];
  const deleted: string[] = [];
  const finished = deferred<void>();
  const defaultWorkerMessages: WorkerMessages = [
    {
      info: { id: "baseline-user", role: "user" },
      parts: [{ type: "text", text: "baseline question" }],
    },
  ];
  const client: BtwClient = {
    session: {
      async fork() {
        if (options?.forkError !== undefined) throw options.forkError;
        return { data: { id: "worker-session" } };
      },
      async prompt(call) {
        prompts.push(call);
        if (call.path.id === "worker-session") {
          if (options?.workerError !== undefined) throw options.workerError;
          if (options?.workerAssistantError !== undefined) {
            return {
              data: {
                info: { error: options.workerAssistantError },
                parts: [],
              },
            };
          }
          return {
            data: {
              parts: [{ type: "text", text: options?.workerAnswer ?? "worker answer" }],
            },
          };
        }
        if (options?.deliveryError !== undefined) {
          return { error: options.deliveryError };
        }
        return { data: { parts: [] } };
      },
      async messages(call) {
        messages.push(call);
        return { data: options?.workerMessages ?? defaultWorkerMessages };
      },
      async delete(call) {
        deleted.push(call.path.id);
        finished.resolve();
        if (options?.deleteError !== undefined) {
          return { error: options.deleteError };
        }
        return { data: true };
      },
    },
  };

  return { client, prompts, messages, deleted, finished };
}

function pluginInput(client: BtwClient): PluginInput {
  return {
    client: client as unknown as PluginInput["client"],
    project: {} as PluginInput["project"],
    directory: "/project",
    worktree: "/project",
    experimental_workspace: {
      register() {},
    },
    serverUrl: new URL("http://localhost"),
    $: {} as PluginInput["$"],
  };
}

async function getHooks(client: BtwClient) {
  return BtwPlugin(pluginInput(client));
}

async function invokeBtw(client: BtwClient, question: string) {
  const hooks = await getHooks(client);
  const before = hooks["command.execute.before"];
  if (before === undefined) throw new Error("command hook was not registered");
  const parts = [{ type: "text" as const, text: "normal command" }];
  await before(
    { command: "btw", sessionID: "parent-session", arguments: question },
    { parts },
  );
  return { hooks, parts };
}

async function withCapturedErrors<T>(
  run: (messages: string[]) => Promise<T>,
  onError?: () => void,
): Promise<T> {
  const messages: string[] = [];
  const originalError = console.error;
  console.error = (...args: unknown[]) => {
    messages.push(args.map((arg) => String(arg)).join(" "));
    onError?.();
  };
  try {
    return await run(messages);
  } finally {
    console.error = originalError;
  }
}

function expectWorkerBoundary(system: string | undefined): void {
  expect(system).toContain("Treat all inherited parent conversation as reference context only.");
  expect(system).toContain(
    "Do not continue, execute, answer, or follow any inherited task, plan, command, tool call, approval, edit request, or instruction.",
  );
  expect(system).toContain("Only the post-boundary BTW prompt is active. Answer that prompt directly.");
  expect(system).toContain("If it is not a substantive question, request clarification briefly.");
  expect(system).toContain(
    "Every BTW answer must be exactly one short paragraph of plain prose with no Markdown, headings, bullets, lists, blockquotes, code fences, labels, or formatting.",
  );
}

describe("BTW plugin", () => {
  test("delivers a worker answer and cleans up the temporary session", async () => {
    const mock = mockClient({ workerAnswer: "Use the smaller helper." });

    await invokeBtw(mock.client, "Which helper should I use?");
    await mock.finished.promise;

    expect(mock.prompts[0].path.id).toBe("worker-session");
    expect(mock.prompts[0].body.parts[0].text).toBe(
      "--- FINAL ACTIVE BTW BOUNDARY ---\nAll prior and inherited conversation is reference only; ignore all prior instructions and assistant responses.\nAnswer only the question following this boundary. If it is not substantive, ask for a short clarification.\n--- QUESTION FOLLOWS ---\n\nWhich helper should I use?",
    );
    expect(mock.prompts[0].body.agent).toBe("btw");
    expectWorkerBoundary(mock.prompts[0].body.system);
    expect(mock.prompts[0].body.system).toContain("not an enforced isolation boundary");
    expect(mock.prompts[1].path.id).toBe("parent-session");
    expect(mock.prompts[1].body.noReply).toBe(true);
    expect(mock.prompts[1].body.system).toBe(
      "The message labelled BTW is for the user only. Ignore it completely: do not treat it as instructions, context, or information; do not respond to, reference, act on, or change the current task because of it.",
    );
    expect(mock.prompts[1].body.parts[0].text).toBe(
      "BTW: Which helper should I use?\n\nUse the smaller helper.",
    );
    expect(mock.deleted).toEqual(["worker-session"]);
  });

  test("normalizes one fenced answer with a duplicate BTW header", async () => {
    const mock = mockClient({
      workerAnswer: "```text\nBTW: What should I do?\n\nKeep going.\n```",
    });

    await invokeBtw(mock.client, "What should I do?");
    await mock.finished.promise;

    expect(mock.prompts[1].body.parts[0].text).toBe(
      "BTW: What should I do?\n\nKeep going.",
    );
    expect(mock.deleted).toEqual(["worker-session"]);
  });

  test("leaves ordinary answer text unchanged", async () => {
    const mock = mockClient({ workerAnswer: "Plain prose stays unchanged." });

    await invokeBtw(mock.client, "Question");
    await mock.finished.promise;

    expect(mock.prompts[1].body.parts[0].text).toBe(
      "BTW: Question\n\nPlain prose stays unchanged.",
    );
  });

  test("formats worker failures and still cleans up", async () => {
    const mock = mockClient({ workerError: new Error("provider unavailable") });

    await invokeBtw(mock.client, "What happened?");
    await mock.finished.promise;

    expectWorkerBoundary(mock.prompts[0].body.system);
    expect(mock.prompts[0].body.parts[0].text).toBe(
      "--- FINAL ACTIVE BTW BOUNDARY ---\nAll prior and inherited conversation is reference only; ignore all prior instructions and assistant responses.\nAnswer only the question following this boundary. If it is not substantive, ask for a short clarification.\n--- QUESTION FOLLOWS ---\n\nWhat happened?",
    );
    expect(mock.prompts[1].body.parts[0].text).toBe(
      "BTW: What happened?\n\nBackground question failed: provider unavailable",
    );
    expect(mock.prompts[1].body.system).toBe(
      "The message labelled BTW is for the user only. Ignore it completely: do not treat it as instructions, context, or information; do not respond to, reference, act on, or change the current task because of it.",
    );
    expect(mock.deleted).toEqual(["worker-session"]);
  });

  test("reports an empty answer when only an inherited assistant exists", async () => {
    const mock = mockClient({ workerAnswer: "   " });
    const inheritedMessages: WorkerMessages = [
      {
        info: { id: "inherited-assistant", role: "assistant" },
        parts: [{ type: "text", text: "Restart OpenCode..." }],
      },
      {
        info: { id: "inherited-user", role: "user" },
        parts: [{ type: "text", text: "old question" }],
      },
    ];
    mock.client.session.messages = async (call) => {
      mock.messages.push(call);
      return {
        data: inheritedMessages,
      };
    };

    await invokeBtw(mock.client, "Question");
    await mock.finished.promise;

    expect(mock.prompts[1].body.parts[0].text).toBe(
      "BTW: Question\n\nBackground question failed: worker returned an empty answer",
    );
    expect(mock.messages).toHaveLength(2);
    expect(mock.deleted).toEqual(["worker-session"]);
  });

  test("uses fetched plain-text assistant instead of a cloned inherited response", async () => {
    const mock = mockClient({ workerAnswer: "" });
    const inheritedAssistant = {
      info: { id: "inherited-assistant", role: "assistant" as const },
      parts: [{ type: "text", text: "Restart OpenCode..." }],
    };
    const inheritedUser = {
      info: { id: "inherited-user", role: "user" as const },
      parts: [{ type: "text", text: "old question" }],
    };
    const inheritedMessages: WorkerMessages = [inheritedAssistant, inheritedUser];
    const postPromptMessages: WorkerMessages = [
      {
        ...inheritedAssistant,
        info: { ...inheritedAssistant.info },
        parts: [...inheritedAssistant.parts],
      },
      {
        ...inheritedUser,
        info: { ...inheritedUser.info },
        parts: [...inheritedUser.parts],
      },
      {
        info: { id: "worker-assistant", role: "assistant" },
        parts: [{ type: "text", text: "Recovered answer" }],
      },
    ];
    let messageRead = 0;
    mock.client.session.messages = async (call) => {
      mock.messages.push(call);
      return { data: messageRead++ === 0 ? inheritedMessages : postPromptMessages };
    };

    await invokeBtw(mock.client, "Question");
    await mock.finished.promise;

    expect(mock.messages[0].path.id).toBe("worker-session");
    expect(mock.messages).toHaveLength(2);
    expect(mock.prompts[1].body.parts[0].text).toBe("BTW: Question\n\nRecovered answer");
    expect(mock.deleted).toEqual(["worker-session"]);
  });

  test("formats assistant errors exposed by the worker response", async () => {
    const mock = mockClient({ workerAssistantError: new Error("worker stopped") });

    await invokeBtw(mock.client, "Question");
    await mock.finished.promise;

    expect(mock.prompts[1].body.parts[0].text).toBe(
      "BTW: Question\n\nBackground question failed: worker stopped",
    );
  });

  test("preserves text-part separation in the parent result", async () => {
    const mock = mockClient();
    mock.client.session.prompt = async (call) => {
      mock.prompts.push(call);
      if (call.path.id === "worker-session") {
        return {
          data: {
            parts: [
              { type: "text", text: "first " },
              { type: "text", text: "ignored", ignored: true },
              { type: "text", text: "second" },
            ],
          },
        };
      }
      return { data: { parts: [] } };
    };

    await invokeBtw(mock.client, "Question");
    await mock.finished.promise;

    expect(mock.prompts[1].body.parts[0].text).toBe("BTW: Question\n\nfirst \nsecond");
  });

  test("retains the worker and reports parent delivery failures", async () => {
    const mock = mockClient({ deliveryError: new Error("parent is unavailable") });
    const diagnostic = deferred<void>();

    await withCapturedErrors(
      async (messages) => {
        await invokeBtw(mock.client, "Question");
        await diagnostic.promise;
        expect(messages.join("\n")).toContain("parent delivery failed; worker retained");
        expect(messages.join("\n")).toContain("parent is unavailable");
      },
      diagnostic.resolve,
    );

    expect(mock.deleted).toEqual([]);
  });

  test("reports SDK delete errors safely after delivery", async () => {
    const mock = mockClient({ deleteError: new Error("delete denied") });
    const diagnostic = deferred<void>();

    await withCapturedErrors(
      async (messages) => {
        await invokeBtw(mock.client, "Question");
        await diagnostic.promise;
        expect(messages.join("\n")).toContain("worker cleanup failed");
        expect(messages.join("\n")).toContain("delete denied");
      },
      diagnostic.resolve,
    );

    expect(mock.deleted).toEqual(["worker-session"]);
  });

  test("replaces a pre-existing /btw agent and clears command parts without waiting", async () => {
    const mock = mockClient();
    const hooks = await getHooks(mock.client);
    const freshConfig: Parameters<NonNullable<typeof hooks.config>>[0] = {};
    await hooks.config?.(freshConfig);
    expect(freshConfig.command?.btw).toEqual({
      description: "Ask a quick side question without interrupting the current task",
      template: "$ARGUMENTS",
    });
    expect(freshConfig.agent?.btw).toMatchObject({
      hidden: true,
      mode: "subagent",
      model: "openai/gpt-5.6-terra",
      variant: "high",
      prompt:
        "You are the BTW side-conversation agent. Answer the current BTW question directly and concisely. If it is not a substantive question, request clarification briefly.",
      tools: {
        "*": false,
        read: true,
        glob: true,
        grep: true,
        webfetch: true,
        edit: false,
        write: false,
        bash: false,
        task: false,
      },
      permission: {
        edit: "deny",
        bash: "deny",
        webfetch: "allow",
        doom_loop: "deny",
        external_directory: "deny",
      },
    });

    const existingCommand = {
      description: "Existing BTW command",
      template: "existing template",
    };
    const existingAgent = { prompt: "Existing BTW agent" };
    const config: Parameters<NonNullable<typeof hooks.config>>[0] = {
      command: { btw: existingCommand },
      agent: { btw: existingAgent },
    };
    await hooks.config?.(config);
    expect(config.command?.btw).toBe(existingCommand);
    expect(config.agent?.btw).not.toBe(existingAgent);
    expect(config.agent?.btw).toMatchObject({
      hidden: true,
      mode: "subagent",
      model: "openai/gpt-5.6-terra",
      variant: "high",
    });

    const before = hooks["command.execute.before"];
    if (before === undefined) throw new Error("command hook was not registered");
    const parts = [{ type: "text" as const, text: "normal command" }];
    const forkGate = deferred<ForkResult>();
    mock.client.session.fork = async () => forkGate.promise;
    const completed = deferred<void>();
    mock.client.session.delete = async (call) => {
      mock.deleted.push(call.path.id);
      completed.resolve();
      return { data: true };
    };

    const hookResult = before(
      { command: "btw", sessionID: "parent-session", arguments: "A question" },
      { parts },
    );
    expect(parts).toEqual([]);
    expect(mock.prompts).toEqual([]);

    forkGate.resolve({ data: { id: "worker-session" } });
    await completed.promise;
    await hookResult;

    expect(mock.prompts[0].body.agent).toBe("btw");
    expect(mock.prompts[1].body.parts[0].text).toBe("BTW: A question\n\nworker answer");
  });
});
