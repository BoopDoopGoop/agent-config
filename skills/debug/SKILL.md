---
name: debug
description: Take an error description, form a hypothesis, loop fix→verify until working
---

Take a description of the broken behavior or error message from the user.
Check relevant logs. Run the failing code. Read the output carefully.
Form a hypothesis before touching any code — state it explicitly.
Fix the code based on the hypothesis.
Run the code again and check the output.
Loop: check logs → fix → verify → repeat until the feature works.
Report what was found and what was changed when done.
