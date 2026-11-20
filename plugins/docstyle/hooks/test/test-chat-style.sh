#!/usr/bin/env bash
# Self-check for chat-style.sh: each part prints its rules under the hook output cap, nothing when switched off.
set -euo pipefail
hook="$(dirname "$0")/../chat-style.sh"
refs="$(dirname "$0")/../../skills/docstyle/references/polish"
export CLAUDE_CONFIG_DIR="$(mktemp -d)"
trap 'rm -rf "$CLAUDE_CONFIG_DIR"' EXIT

out="$(bash "$hook")"
grep -q "docstyle chat style" <<<"$out" || { echo "FAIL: preamble missing"; exit 1; }
grep -q "second person" <<<"$out" || { echo "FAIL: core rules missing"; exit 1; }
grep -q "^## " <<<"$out" && { echo "FAIL: leaked a section heading"; exit 1; }

a="$(bash "$hook" polish-a)"; b="$(bash "$hook" polish-b)"
# Claude Code swaps hook stdout over 10,000 characters for a file path and a preview.
for part in "$out" "$a" "$b"; do
  [ "$(wc -m <<<"$part")" -le 10000 ] || { echo "FAIL: a part exceeds 10,000 characters"; exit 1; }
done
# Together the two Polish parts carry every line of both reference files.
missing="$(cat "$refs/polish-patterns.md" "$refs/plain-polish.md" | grep -vxFf <(printf '%s\n%s\n' "$a" "$b") || true)"
[ -z "$missing" ] || { echo "FAIL: Polish reference lines missing from the hook output:"; echo "$missing"; exit 1; }

touch "$CLAUDE_CONFIG_DIR/docstyle-chat-off"
for part in core polish-a polish-b; do
  [ -z "$(bash "$hook" "$part")" ] || { echo "FAIL: output from $part while switched off"; exit 1; }
done
echo "ok"
