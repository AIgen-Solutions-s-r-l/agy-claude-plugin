# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
