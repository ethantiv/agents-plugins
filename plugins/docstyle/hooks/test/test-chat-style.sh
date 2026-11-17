#!/usr/bin/env bash
# Self-check for chat-style.sh: prints the core rules by default, nothing when switched off.
set -euo pipefail
hook="$(dirname "$0")/../chat-style.sh"
export CLAUDE_CONFIG_DIR="$(mktemp -d)"
trap 'rm -rf "$CLAUDE_CONFIG_DIR"' EXIT

out="$(bash "$hook")"
grep -q "docstyle chat style" <<<"$out" || { echo "FAIL: preamble missing"; exit 1; }
grep -q "second person" <<<"$out" || { echo "FAIL: core rules missing"; exit 1; }
grep -q "^## " <<<"$out" && { echo "FAIL: leaked a section heading"; exit 1; }

touch "$CLAUDE_CONFIG_DIR/docstyle-chat-off"
[ -z "$(bash "$hook")" ] || { echo "FAIL: output while switched off"; exit 1; }
echo "ok"
