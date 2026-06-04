# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] — 2026-06-04

### Added
- **`/agy` now validates a pinned `--model`.** When (and only when) the user
  passes `--model <name>`, the recipe first runs `agy models` and ABORTs if the
  name does not appear verbatim — closing the silent-default landmine (`agy
  --model "<typo>"` returns exit 0 and answers as the default). The default warm
  fast path is untouched (no extra call).
- **`/agy` rate-limit / quota failure branch** distinct from the
  cold-start/auth timeout, so a usage-cap error is diagnosed as "wait and retry"
  rather than an auth problem.
- **`/agy` "relay, do not surrender judgment" rule:** if `agy`'s answer
  contradicts Claude's own correct analysis, FLAG the disagreement rather than
  deferring to the `Antigravity (agy):` prefix (which marks the source, not a
  trust badge).
- **`/agy-review` and `/agy-debug` pre-send secret scan** — a deterministic,
  best-effort backstop (in-scope `grep -nEi` for PRIVATE KEY blocks, AKIA keys,
  bearer/authorization headers, and `api_key`/`secret`/`password`/`token`
  assignments, plus `git check-ignore` to skip ignored paths) that ABORTs the
  send on a hit, layered on top of the existing bounding, consent line, and
  denylist (not a guarantee). `allowed-tools` gained `Bash(grep:*)` and
  `Bash(git check-ignore:*)`.
- **`test/secret-scan.sh` + `test/fixtures/leaky.txt`** — a tracked, FAKE
  planted secret and a test that runs the same grep signatures, making the
  "never leaks secrets" claim falsifiable. Wired into the `copy-truth` CI
  workflow as a `secret-scan` job.
- **IP / terms note** in `/agy-review`, `/agy-debug`, and the README
  privacy/governance section: code attached to a consult is transmitted to
  Google under the Antigravity terms — do not consult on code you are
  contractually barred from sharing with third-party AI.

### Changed
- **`/agy` `-c` / `--continue` caveat:** documented that conversation state is
  cwd-keyed and last-writer-wins, and pointed users to `agy --conversation <ID>`
  for a deterministic resume.

### Fixed
- **Storefront truth-pass — public copy now matches the shipped product.** The
  repo description, `plugin.json`, `marketplace.json`, and README hero/subtitle,
  Layout block, and Contributing note all described a single `/agy` command (and
  a removed `-P` / Gemini-default flow) while **four** commands ship (`/agy`,
  `/agy-review`, `/agy-debug`, `/agy-panel`). Rewrote them to the factual
  four-command suite fronting Gemini, Claude, and GPT-OSS through the Antigravity
  (`agy`) CLI. No pricing or positioning claims; command recipes untouched.
- **Anti-drift grep-gate CI** (`.github/workflows/copy-truth.yml`): fails the
  build if any retired/dead public string reappears (CHANGELOG excluded as a
  historical record), so the storefront copy cannot silently regress.

## [0.3.1] — 2026-06-04

### Changed
- **`/agy-debug` context transport is now in-scope and prompt-free.** The recipe
  materializes each bounded file region into the temp dir with an explicit
  in-scope `mktemp`/`sed` slice instead of implicitly relying on Claude's
  built-in Read/Write (which are not in `allowed-tools`). Public, non-bypass
  users no longer get a mid-command permission prompt. `allowed-tools` gained
  `Bash(sed:*)` to back the bounded copy; the cap, consent line,
  secret/`.env`/`.gitignored` denylist, `--sandbox`, and never-fabricate failure
  handling are unchanged.

### Added
- **`/agy-debug` now advertises `--deep`** in its `argument-hint` and its README
  usage row (raising the `--print-timeout` to 5m), mirroring `/agy-review`.

## [0.3.0] — 2026-06-04

### Added
- **`/agy-review` and `/agy-debug`** — job-aware consults that gather a bounded
  amount of auto-context (the current diff for review; the pasted error/trace
  plus named file(s) for debug) behind a consent gate before sending it to
  Antigravity.
- **`/agy-panel`** — an integrity-checked, cross-vendor opinion comparison that
  asks the same question across several distinct models and presents the answers
  side by side.

## [0.2.1] — 2026-06-04

### Reliability & honest-failure hardening
- Preflight via exit-127 handling: a `command not found` result now tells the
  user the `agy` CLI isn't installed (pointing at the README requirements)
  instead of retrying.
- Default `--print-timeout` lowered from 5m to **90s**, with a new `--deep`
  user flag that raises it back to 5m for heavy agentic work.
- Added a short progress line ("Consulting Antigravity (~5-30s, agentic CLI)…")
  so the wait is expected.
- Crisp auth/timeout failure UX: a timeout now states the limit (90s, or 5m with
  `--deep`) and surfaces the likely cause (not signed in to the Antigravity
  desktop app).
- Never-fabricate-on-empty: exit 0 with empty output is reported as "no answer"
  rather than inventing a response.

### Governance
- Added a privacy/governance note: `agy` authenticates to Google and persists
  prompts and responses in cleartext locally; any context passed leaves the
  machine.
- Secret denylist: never auto-attach secrets, `.env`, or `.gitignored` files to
  a consult.

### Metadata
- `plugin.json`: bumped to `0.2.1`, added `author.email`, expanded `keywords`
  (`second-opinion`, `multi-model`, `gemini`, `claude`, `gpt-oss`).
- `marketplace.json`: added `owner.email` and `owner.url`.

## [0.2.0] — 2026

### Changed
- **BREAKING:** Antigravity-only. Removed the `-P` flag and the Gemini default
  so `/agy` always targets the `agy` CLI (commit `24dec92`).

## [0.1.0]

### Added
- Initial `agy-consult` plugin providing the `/agy` slash command.
