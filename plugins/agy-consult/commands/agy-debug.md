---
description: Send an error/stack trace plus the relevant file(s) to Antigravity (agy) for root-cause analysis.
argument-hint: "[--deep] <error or stack trace> [file ...]"
allowed-tools: Bash(agy:*), Bash(git status:*), Bash(git rev-parse:*), Bash(git check-ignore:*), Bash(mktemp:*), Bash(sed:*), Bash(grep:*)
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

## Transport via a dedicated temp dir (in-scope, prompt-free)

Copy **only** the bounded, consented file content into a fresh temp directory
and hand that to `agy` with `--add-dir` (so nothing else in the repo is
exposed). Do this with the **in-scope** `mktemp`/`sed` commands — **not** with
Claude's built-in Read/Write — so a non-bypass user gets **no mid-command
prompt**:

```
dir="$(mktemp -d)"
# materialize each named file's bounded region with an in-scope sed slice:
sed -n "1,400p" "$file" > "$dir/<name>"   # bounded slice; stay within the ~600-line / ~24 KB hard cap above
# (target the region around the stack-trace line numbers when a file is large)
```

The temp dir holds nothing but the debug artifacts you chose to attach. The
bounded copy is done **entirely** with the listed `mktemp`/`sed` commands; the
recipe never calls Read/Write, so it stays inside `allowed-tools` and never
prompts.

## Pre-send secret scan (best-effort backstop — not a guarantee)

This is a **deterministic last-line check** layered on top of the bounding, the
consent line, and the existing secret/`.env`/`.gitignored` denylist — **not** a
replacement for them and **not** a guarantee. It catches obvious planted
secrets; treat the denylist + consent as the primary control.

Right **before** sending, scan the bounded temp dir for secret signatures with
the in-scope `grep` (both tokens are in `allowed-tools`):

```
grep -rnEi 'BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|(authorization|bearer)[[:space:]:]+[A-Za-z0-9._-]+|(api[_-]?key|secret|password|passwd|token)[[:space:]]*[:=]' "$dir"
```

- Before attaching a named file, also honour git's ignore rules: run
  `git check-ignore -- <path>` and **skip** any path it flags (it is a
  `.gitignored` file and must not leave the machine).
- **If `grep` matches** (a likely secret), **ABORT** the send — mirror the
  panel's ABORT discipline: show the offending **file:line** from the `grep`
  output and stop, rather than transmitting it. Do not "scrub and continue"
  silently; surface it to the user.

## Run

This command may run **only** `agy ...` and the
`git`/`mktemp`/`sed`/`grep` commands above (including the pre-send `grep` and
`git check-ignore` scan) — **not** Read/Write, and nothing else. Every one of those is in
`allowed-tools`, so a non-bypass user is never prompted mid-command. Because
real code is attached, run with `--sandbox`:

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

**IP / terms:** code attached to a consult is **transmitted to Google** under
the Antigravity terms — do **not** consult on code you are contractually barred
(NDA, license, or employer policy) from sharing with third-party AI.

## Output

Report `agy`'s response, prefixed with **Antigravity (agy) — debug:**. If the
CLI errors or times out, say so and show the error rather than inventing an
answer.
