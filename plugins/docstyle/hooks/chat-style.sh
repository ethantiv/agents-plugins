#!/usr/bin/env bash
# SessionStart hook: prints the docstyle core rules as chat-style context.
# `/docstyle:docstyle off` creates the flag file that silences it.
[ -e "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/docstyle-chat-off" ] && exit 0

cat <<'PREAMBLE'
# docstyle chat style

Write your chat replies in this session in the style of the Google developer documentation style guide. The core rules follow. Apply the full set to English replies; to replies in other languages apply only the structural rules (second person, active voice, present tense, conditions before instructions, list and heading discipline, descriptive links, no future promises, no excessive claims) and never anglicize spelling, punctuation, or word choice. The user's own instructions and output style win where they conflict. Switch off with `/docstyle:docstyle off`.

PREAMBLE
# Single source of truth: the "Core rules" section of the skill.
awk '/^## Core rules/{p=1;next} /^## /{p=0} p' "$(dirname "$0")/../skills/docstyle/SKILL.md"
