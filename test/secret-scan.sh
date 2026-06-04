#!/usr/bin/env bash
# Proves the pre-send secret scan used by /agy-review and /agy-debug actually
# catches a TRACKED, planted secret — making the "never leaks secrets" claim
# falsifiable. Runs the SAME grep signatures the commands use against the
# fixtures dir. Exits 0 ONLY if the planted secret is detected; exits 1 if the
# scan would have MISSED it (i.e. the privacy backstop is broken).
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fixtures="$here/fixtures"

# Keep this pattern in lockstep with the grep in
# plugins/agy-consult/commands/agy-review.md and agy-debug.md.
pattern='BEGIN [A-Z ]*PRIVATE KEY|AKIA[0-9A-Z]{16}|(authorization|bearer)[[:space:]:]+[A-Za-z0-9._-]+|(api[_-]?key|secret|password|passwd|token)[[:space:]]*[:=]'

echo "Scanning $fixtures for planted secret signatures…"
if hits="$(grep -rnEi "$pattern" "$fixtures")"; then
  echo "PASS: secret scan detected the planted secret(s):"
  echo "$hits"
  exit 0
else
  echo "FAIL: secret scan MISSED the planted secret in $fixtures/leaky.txt." >&2
  echo "The privacy backstop is broken — a real secret could leak." >&2
  exit 1
fi
