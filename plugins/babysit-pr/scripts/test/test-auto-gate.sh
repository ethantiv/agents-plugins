#!/usr/bin/env bash
#
# Self-check for auto-gate.sh: asserts only a positively-green snapshot reads
# as clean, and that the merge sha is the PR head from the snapshot.

set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
gate="$script_dir/../auto-gate.sh"

fail=0
field() { printf '%s' "$1" | jq -r ".$2"; }
assert() {
  local label="$1" got="$2" want="$3"
  if [ "$got" = "$want" ]; then
    echo "ok   - $label"
  else
    echo "FAIL - $label: got '$got' want '$want'" >&2
    fail=1
  fi
}

clean_snapshot='{"status":"ok","number":42,"head_sha":"abc123","mergeStateStatus":"CLEAN","has_conflicts":false,"failing_checks":[],"pending_checks":[],"review_threads":[],"changes_requested":[],"unpushed_local_commits":false}'
variant() { printf '%s' "$clean_snapshot" | jq -c "$1"; }
gate_clean() { field "$(printf '%s' "$1" | bash "$gate")" clean; }

# 1: a single clean pass is enough to merge
out="$(printf '%s' "$clean_snapshot" | bash "$gate")"
assert "clean" "$(field "$out" clean)" "true"
assert "clean sha is PR head" "$(field "$out" sha)" "abc123"

# 2: mergeStateStatus != CLEAN -> not clean
assert "blocked not clean" "$(gate_clean "$(variant '.mergeStateStatus="BLOCKED"')")" "false"

# 3: open review thread despite CLEAN -> not clean
assert "open thread not clean" "$(gate_clean "$(variant '.review_threads=[{"thread_id":"x"}]')")" "false"

# 4: pending check despite CLEAN -> not clean
assert "pending check not clean" "$(gate_clean "$(variant '.pending_checks=[{"name":"ci"}]')")" "false"

# 5: local fix not yet pushed -> not clean
assert "unpushed not clean" "$(gate_clean "$(variant '.unpushed_local_commits=true')")" "false"

# 6: snapshot without head_sha -> gate refuses
printf '%s' "$(variant 'del(.head_sha)')" | bash "$gate" >/dev/null 2>&1
assert "missing head_sha fails" "$?" "1"

exit $fail
