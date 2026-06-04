---
description: Send an error/stack trace plus the relevant file(s) to Antigravity (agy) for root-cause analysis.
argument-hint: "<error or stack trace> [file ...]"
allowed-tools: Bash(agy:*), Bash(git status:*), Bash(git rev-parse:*), Bash(mktemp:*)
---

Have **Antigravity** (Google's `agy` CLI) help debug an error as a
**root-cause analyst**, then relay its hypotheses. The user invoked:
`/agy-debug $ARGUMENTS`

`$ARGUMENTS` is the pasted **error or stack trace** followed by zero or more
**file paths** that are relevant to it. Separate the two: the trace is prose,
the trailing tokens that resolve to real files are the attachments.

## Before you run

Print a short progress line so the wait is expected, e.g.:

> Debugging with Antigravity (~30s-3m, agentic CLI)…

## Gather the context

1. Keep the **error/stack trace** text verbatim — it goes into the prompt.
2. For each named file that exists, plan to attach its contents. Resolve paths
   relative to the repo (use `git rev-parse --show-toplevel` if you need the
   root). Use `git status --short` for orientation on what's changed.

## Bound it (hard cap — never blow past this)

The attached file content **must** be capped before it leaves the machine:

- Hard cap across all attachments: **~600 lines** *and* **~24 KB**, whichever is
  hit first.
- If a file (or the set) is over the cap, attach the most relevant region — the
  area around the line numbers in the stack trace — and note that the file was
  **truncated to fit the cap** (with the line range included).
- Never include secrets, `.env` files, or any `.gitignored` files. If a named
  path is ignored or looks like a secret, **skip it** and tell the user it was
  not attached.

## Consent line (always visible)

Before sending, print exactly one line stating what leaves the machine, e.g.:

> Attaching <N lines / M files> to Antigravity (Google) — code leaves the machine.

Fill in the real counts from the bounded attachments.

## Transport via a dedicated temp dir

Copy **only** the bounded, consented file content into a fresh temp directory
and hand that to `agy` with `--add-dir` (so nothing else in the repo is
exposed):

```
dir="$(mktemp -d)"
# write each bounded file region into "$dir/<name>" (truncate to the cap first)
```

The temp dir holds nothing but the debug artifacts you chose to attach.

## Run

This command may run **only** `agy ...` and the git/`mktemp` commands above —
nothing else. Because real code is attached, run with `--sandbox`:

```
agy -p "<debug prompt>" --add-dir "$dir" --sandbox --print-timeout 3m
```

- Default `--print-timeout` is **3m** (a code-bearing agentic debug is heavier
  than a plain Q&A).
- With `--deep`, raise it to **5m**. Do **not** pass `--deep` to `agy`.

**Debug prompt** — give `agy` a root-cause-analyst role plus the trace and the
attached files:

> You are debugging a failure as a root-cause analyst. Here is the error / stack
> trace:
>
> ```
> <pasted error or stack trace>
> ```
>
> The relevant source is in the attached directory. Give your top **root-cause
> hypotheses** ranked by likelihood, and for each a **concrete next check** (a
> specific line/function to inspect, a value to log, a test to run). Cite the
> file/line. Don't guess blindly — tie each hypothesis to the trace or the code.

## Failure handling (never fabricate an answer)

Same rules as `/agy`:

- **`command not found` / exit 127** — the `agy` CLI isn't installed. Tell the
  user to install it (see the README requirements). Do **not** retry.
- **Timeout** — say it timed out (3m, or 5m with `--deep`). The likely cause is
  not being signed in to the **Antigravity desktop app**. Do **not** invent an
  answer.
- **Exit 0 with EMPTY output** — report that `agy` returned no answer (possible
  auth or print-mode issue); never fabricate.
- For any other error, show the error rather than inventing an answer.

## Privacy / governance

`agy` authenticates to **Google** and stores prompts **and** responses in
**cleartext locally**. The attached files **leave the machine**, so they are
strictly bounded, consented (the line above), and free of secrets, `.env`, and
`.gitignored` files. **Never** pass `--dangerously-skip-permissions`.

## Output

Report `agy`'s response, prefixed with **Antigravity (agy) — debug:**. If the
CLI errors or times out, say so and show the error rather than inventing an
answer.
