---
description: Consult Google's Antigravity CLI (agy) and relay its answer.
argument-hint: "<question or context for agy>"
allowed-tools: Bash(agy:*)
---

Consult **Antigravity** (Google's `agy` CLI), relay its answer back to me, then continue my own work using it as input. The user invoked: `/agy $ARGUMENTS`

Everything after `/agy` is the PROMPT.

## Run

Run via Bash:

```
agy -p "<prompt>" --print-timeout 5m
```

Optional flags — add **only** when the user's request calls for them:
- `--model <name>` — pick a specific model (run `agy models` to list).
- `--add-dir <path>` — give `agy` extra context directories.
- `-c` / `--continue` — continue the previous `agy` conversation.

## Caveats (state these if the call fails)

- `agy` is Google's **Antigravity CLI**. It is *agentic* and **slow to start**
  (tens of seconds), and it authenticates through the **Antigravity desktop
  app** — if it hangs or errors on auth, the user likely needs to be signed in
  to Antigravity.
- **Never** add `--dangerously-skip-permissions`: it auto-approves every tool
  the model runs (unsafe, and blocked by policy). For plain Q&A `agy` answers
  without needing tool approval.

## Output

Report `agy`'s response, prefixed with **Antigravity (agy):**. If the CLI errors
or times out, say so and show the error rather than inventing an answer.
