---
description: Ask Antigravity (agy) the same question across several distinct models and compare their answers side by side.
argument-hint: "<question>"
allowed-tools: Bash(agy:*)
---

Convene a **panel**: put the **same** question to several **distinct** models via
**Antigravity** (Google's `agy` CLI), then lay their answers side by side. The
user invoked: `/agy-panel $ARGUMENTS`

Everything in `$ARGUMENTS` is the PROMPT for every panellist. This command may
run **only** `agy ...` — nothing else (everything here is an `agy` call).

## Before you run

Print a short progress line so the wait is expected, e.g.:

> Convening an Antigravity panel (~30-90s; fanning out to N models)…

## Pick the panel (validate every name — this is mandatory)

1. List what's actually available:
   ```
   agy models
   ```
2. Read that output. Choose **N** (default **3**) **verified-distinct** models
   from different stables — e.g. a **Gemini**, a **Claude**, and **GPT-OSS**.
   Honour an explicit list if the user named models.
3. **Validate every chosen/requested name against the `agy models` output.**
   - If **any** name is **not present** in that list, **ABORT** the whole panel
     with a clear message naming the bad model and showing the available list.
   - **Landmine:** `agy --model "<typo>"` returns **exit 0** and *silently
     answers as the DEFAULT model*. So a misspelt name does **not** error — it
     just gives you the default's answer wearing the wrong label. **Never**
     present such a fallback as a panel member. Only names that appear verbatim
     in `agy models` are eligible.

## Run the panel (fan out in parallel, one-shot each)

Send the **same** prompt to each validated model **in parallel** (issue the
calls together so they run concurrently):

```
agy --model "<name>" -p "<prompt>" --print-timeout 90s
```

- These are **one-shot** calls. **NEVER** use `-c` / `--continue` here.
  **Landmine:** `agy` conversation state is keyed by the **current working
  directory** and is **last-writer-wins** — fanning several models out with
  `-c` in the same cwd would clobber each other's history. So every panellist
  runs fresh.
- **Warn the user** that, because a panel writes several conversations into the
  same cwd-keyed slot, a plain `/agy -c` **afterwards is ambiguous** (it
  continues whichever call wrote last, not "the panel"). If they want to follow
  up, they should re-ask with `/agy --model <name>`.
- **Per-model timeout / isolation:** if one model **errors or times out**, do
  **not** block on it. Collect whatever finished and present **partial** results
  from the others, clearly noting which panellist failed and why.

## Present the panel

- Show each answer **side by side**, each clearly **LABELLED** with its
  **resolved** model name (the validated `--model` value you actually sent).
- After the answers, add an **honest 2-line synthesis**: where they **agree on
  X** and where they **split on Y**. Models often **agree** — say so plainly.
  Do **not** sell this as a "disagreement engine" or overclaim independence.
- Note the real limitation: **all** panellists route through **one Google
  backend** (`agy`), so this is **not** failure-domain independence — a backend
  outage or shared bias hits every panellist at once.

## Failure handling (never fabricate an answer)

- **`command not found` / exit 127** — the `agy` CLI isn't installed. Tell the
  user to install it (see the README requirements). Do **not** retry.
- **Timeout** — say which panellist(s) timed out (90s each); the likely cause is
  not being signed in to the **Antigravity desktop app**. Present the others;
  do **not** invent an answer for the one that failed.
- **Exit 0 with EMPTY output** — report that panellist returned no answer
  (possible auth or print-mode issue); never fabricate.
- For any other error, show the error rather than inventing an answer.

## Privacy / governance

`agy` authenticates to **Google** and stores prompts **and** responses in
**cleartext locally**. The prompt is sent to **every** panellist, so it **leaves
the machine** N times — only send what the user has knowingly chosen to share.
**Never** auto-attach secrets, `.env` files, or any `.gitignored` files, and
**never** pass `--dangerously-skip-permissions` (it auto-approves every tool the
model runs — unsafe, and blocked by policy).

## Output

Report the panel, prefixed with **Antigravity (agy) — panel:**. If a panellist
errors or times out, say so and present the rest rather than inventing an answer.
