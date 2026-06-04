---
description: Send the current change set to Antigravity (agy) for a senior-reviewer code review.
argument-hint: "[--deep] [extra focus]"
allowed-tools: Bash(agy:*), Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git rev-parse:*), Bash(git check-ignore:*), Bash(mktemp:*), Bash(grep:*)
---

Have **Antigravity** (Google's `agy` CLI) review my current change set as a
**senior reviewer**, then relay its findings. The user invoked:
`/agy-review $ARGUMENTS`

Everything in `$ARGUMENTS` is optional extra focus for the reviewer — except
`--deep`, which is **our** flag (not `agy`'s) and is stripped before building
the prompt.

## Before you run

Print a short progress line so the wait is expected, e.g.:

> Reviewing your changes with Antigravity (~30s-3m, agentic CLI)…

## Gather the change context (git only)

Collect the diff with `git`, in this order — use the first that is non-empty:

1. **Staged** changes (a deliberate commit boundary):
   ```
   git diff --staged
   ```
2. Else **working tree vs HEAD** (uncommitted edits):
   ```
   git diff HEAD
   ```
3. Else **branch vs main** (already-committed work on this branch). Resolve the
   base first and only use it if it exists:
   ```
   git rev-parse --verify main
   git diff main...HEAD
   ```

Also grab `git status --short` and `git log --oneline -5` for orientation.

## Bound it (hard cap — never blow past this)

The diff **must** be capped before it leaves the machine:

- Hard cap: **~600 lines** *and* **~24 KB**, whichever is hit first.
- If the diff is over the cap, do **not** send the whole thing. Instead send
  `git diff --stat` plus the diffs of only the changed files that fit, and add a
  line noting that the review was **truncated to fit the cap** (list which files
  were included vs omitted).
- Never include secrets, `.env` files, or any `.gitignored` files. If the diff
  touches such a path, drop that hunk and note the omission. `git diff` already
  excludes ignored files; do not override that.

## Consent line (always visible)

Before sending, print exactly one line stating what leaves the machine, e.g.:

> Attaching <N lines / M files> to Antigravity (Google) — code leaves the machine.

Fill in the real counts from the bounded diff.

## Transport via a dedicated temp dir

Put **only** the bounded, consented context into a fresh temp directory and hand
that to `agy` with `--add-dir` (so nothing else in the repo is exposed):

```
dir="$(mktemp -d)"
git diff --staged > "$dir/changes.diff"   # or the branch you selected above
git status --short > "$dir/status.txt"
git log --oneline -5 > "$dir/recent.txt"
```

Write only the **bounded** content (truncate to the cap before writing). The
temp dir holds nothing but these review artifacts.

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

- For each changed file that the diff covers, also honour git's ignore rules:
  run `git check-ignore -- <path>` and **skip** any path it flags (it is a
  `.gitignored` file and must not leave the machine).
- **If `grep` matches** (a likely secret), **ABORT** the send — mirror the
  panel's ABORT discipline: show the offending **file:line** from the `grep`
  output and stop, rather than transmitting it. Do not "scrub and continue"
  silently; surface it to the user.

## Run

This command may run **only** `agy ...` and the git/`mktemp` commands above —
nothing else. Because real code is attached, run with `--sandbox`:

```
agy -p "<review prompt>" --add-dir "$dir" --sandbox --print-timeout 3m
```

- Default `--print-timeout` is **3m** (a code-bearing agentic review is heavier
  than a plain Q&A).
- With `--deep`, raise it to **5m**. Do **not** pass `--deep` to `agy`.

**Review prompt** — give `agy` a senior-reviewer role and the attached context:

> You are a senior software engineer doing a focused code review. The change set
> is in the attached directory (`changes.diff`, with `status.txt` and
> `recent.txt` for context). Review for **correctness, real bugs, risk, and edge
> cases** — not style nits. Call out anything that could break, data-loss or
> security hazards, missed error handling, and concrete edge cases. Be specific
> and cite the file/line. <append any extra focus the user passed>

## Failure handling (never fabricate a review)

Same rules as `/agy`:

- **`command not found` / exit 127** — the `agy` CLI isn't installed. Tell the
  user to install it (see the README requirements). Do **not** retry.
- **Timeout** — say it timed out (3m, or 5m with `--deep`). The likely cause is
  not being signed in to the **Antigravity desktop app**. Do **not** invent a
  review.
- **Exit 0 with EMPTY output** — report that `agy` returned no review (possible
  auth or print-mode issue); never fabricate.
- For any other error, show the error rather than inventing a review.

## Privacy / governance

`agy` authenticates to **Google** and stores prompts **and** responses in
**cleartext locally**. The attached diff **leaves the machine**, so it is
strictly bounded, consented (the line above), and free of secrets, `.env`, and
`.gitignored` files. **Never** pass `--dangerously-skip-permissions`.

**IP / terms:** code attached to a consult is **transmitted to Google** under
the Antigravity terms — do **not** consult on code you are contractually barred
(NDA, license, or employer policy) from sharing with third-party AI.

## Output

Report `agy`'s response, prefixed with **Antigravity (agy) — review:**. If the
CLI errors or times out, say so and show the error rather than inventing a
review.
