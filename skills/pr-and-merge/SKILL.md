---
name: pr-and-merge
description: Create a PR from the current branch targeting main, then immediately squash-merge and delete the branch
---

Use this when the user asks to "pr and merge", "create and merge a PR", or invokes /pr-and-merge.

Steps:

1. Export trusted certs (corporate proxy TLS workaround):
   ```
   security find-certificate -a -p > $TMPDIR/certs.pem
   security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain >> $TMPDIR/certs.pem
   ```

2. Get credentials and repo info:
   ```
   GH_TOKEN=$(python3 -c "import yaml,sys; d=yaml.safe_load(open('$HOME/.config/gh/hosts.yml')); print(d['github.com']['oauth_token'])" 2>/dev/null || grep -A1 'oauth_token' ~/.config/gh/hosts.yml | tail -1 | tr -d ' ')
   BRANCH=$(git rev-parse --abbrev-ref HEAD)
   REMOTE_URL=$(git remote get-url origin)
   ```
   Parse OWNER/REPO from the remote URL — handle both SSH (`git@github.com:OWNER/REPO.git`) and HTTPS (`https://github.com/OWNER/REPO.git`) formats.

3. Infer PR title and body from recent commits:
   ```
   git log main..HEAD --oneline
   ```
   Use the most descriptive commit message as the title. Summarize the full set of commits as the body.

4. Check if a PR already exists for the branch:
   ```
   curl --cacert $TMPDIR/certs.pem -s \
     -H "Authorization: Bearer $GH_TOKEN" \
     -H "Accept: application/vnd.github+json" \
     "https://api.github.com/repos/OWNER/REPO/pulls?head=OWNER:BRANCH&state=open"
   ```
   If a PR exists, extract its number and skip to step 5. Otherwise create one:
   ```
   curl --cacert $TMPDIR/certs.pem -s -X POST \
     -H "Authorization: Bearer $GH_TOKEN" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/repos/OWNER/REPO/pulls \
     -d '{"title":"TITLE","body":"BODY","head":"BRANCH","base":"main"}'
   ```
   Extract the PR number from the response.

5. Squash-merge the PR:
   ```
   curl --cacert $TMPDIR/certs.pem -s -X PUT \
     -H "Authorization: Bearer $GH_TOKEN" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/repos/OWNER/REPO/pulls/NUMBER/merge \
     -d '{"merge_method":"squash"}'
   ```

6. Delete the remote branch:
   ```
   curl --cacert $TMPDIR/certs.pem -s -X DELETE \
     -H "Authorization: Bearer $GH_TOKEN" \
     -H "Accept: application/vnd.github+json" \
     https://api.github.com/repos/OWNER/REPO/git/refs/heads/BRANCH
   ```

7. Return to main with merged changes:
   ```
   git checkout main && git pull
   ```
