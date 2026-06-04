---
description: Consult an external CLI model — Gemini by default, Antigravity (agy) with -P.
argument-hint: "[-P] <question or @file ...>"
allowed-tools: Bash(agy:*), Bash(gemini:*), mcp__gemini-cli__ask-gemini
---

Consult an external coding-model CLI and relay its answer back to me, then continue my own work using it as input. The user invoked: `/agy $ARGUMENTS`

## Pick the backend from the flag

Look at the start of the arguments above:

- If they begin with `-P`, `--antigravity`, or `--agy` → **strip that flag** and consult **Antigravity (`agy`)**.
- Otherwise → consult **Gemini** (the default).

The remaining text (after stripping any backend flag) is the PROMPT.

## Gemini (default)

Prefer the `ask-gemini` MCP tool with `prompt` = the prompt. Its `@file` syntax pulls in files, e.g. `@src/foo.py what does this do`. Pass `model:` only if the user named one.

If that MCP tool is unavailable, fall back to Bash: `gemini -p "<prompt>"`.

## Antigravity — `-P`

Run via Bash:

```
agy -p "<prompt>" --print-timeout 5m
```

Caveats (state these to the user if the call fails):
- `agy` is Google's **Antigravity CLI**. It is *agentic* and **slow to start** (tens of seconds), and it authenticates through the **Antigravity desktop app** — if it hangs or errors on auth, the user likely needs to be signed in to Antigravity.
- **Never** add `--dangerously-skip-permissions`: it auto-approves every tool the model runs (unsafe, and blocked by policy). For plain Q&A `agy` answers without needing tool approval.
- Optional flags to add only when relevant: `--model <name>` (run `agy models` to list), `--add-dir <path>` to give it extra context directories, `-c` / `--continue` to continue the previous `agy` conversation.

## Output

Report the external model's response, prefixed with which backend answered (e.g. **Gemini:** or **Antigravity (agy):**). If the CLI errors or times out, say so and show the error rather than inventing an answer.
