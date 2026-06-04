---
description: Consult Google's Antigravity CLI (agy) and relay its answer.
argument-hint: "<question or context for agy>"
allowed-tools: Bash(agy:*)
---

Consult **Antigravity** (Google's `agy` CLI), relay its answer back to me, then continue my own work using it as input. The user invoked: `/agy $ARGUMENTS`

Everything after `/agy` is the PROMPT — except for the recognised flags below, which you strip out before building the prompt.

## Before you run

Tell the user a short progress line so the wait is expected, e.g.:

> Consulting Antigravity (~5-30s, agentic CLI)…

## Run

Run via Bash (this command may run **only** `agy ...` — nothing else):

```
agy -p "<prompt>" --print-timeout 90s
```

The 90s default covers a warm call (~5s) plus a cold start. Use `--deep` (below)
for heavy agentic work that needs longer.

Recognised user flags — add **only** when the user's request calls for them:
- `--deep` — **our** flag (not `agy`'s). When present, raise the timeout to
  `--print-timeout 5m` for heavy agentic work. Do **not** pass `--deep` to `agy`.
- `--model <name>` — pick a specific model (run `agy models` to list).
- `--add-dir <path>` — give `agy` extra context directories.
- `-c` / `--continue` — continue the previous `agy` conversation.

## Failure handling (never fabricate an answer)

- **`command not found` / exit 127** — the `agy` CLI isn't installed. Tell the
  user to install it (see the README requirements). Do **not** retry.
- **Timeout** — say it timed out (90s, or 5m with `--deep`). The likely cause is
  not being signed in to the **Antigravity desktop app**. Do **not** invent an
  answer.
- **Exit 0 with EMPTY output** — report that `agy` returned no answer (possible
  auth or print-mode issue); never fabricate. Only with the user's explicit
  permission may you inspect `agy`'s transcript — the default path stays in scope.
- For any other error, show the error rather than inventing an answer.

## Caveats

- `agy` is Google's **Antigravity CLI**. It is *agentic* and **slow to start**
  (tens of seconds), and it authenticates through the **Antigravity desktop
  app** — if it hangs or errors on auth, the user likely needs to be signed in
  to Antigravity.
- **Never** add `--dangerously-skip-permissions`: it auto-approves every tool
  the model runs (unsafe, and blocked by policy). For plain Q&A `agy` answers
  without needing tool approval.

## Privacy / governance

`agy` authenticates to **Google** and stores prompts **and** responses in
**cleartext locally**. Any context you pass **leaves the machine**. So **never**
auto-attach secrets, `.env` files, or any `.gitignored` files to a consult —
only send what the user has knowingly chosen to share.

## Output

Report `agy`'s response, prefixed with **Antigravity (agy):**. If the CLI errors
or times out, say so and show the error rather than inventing an answer.
