#!/usr/bin/env bash
# SessionStart hook: prints the docstyle chat-style context.
# Claude Code replaces hook stdout over 10,000 characters with a file path and a
# preview, so hooks.json runs this script once per part: core, polish-a, polish-b.
# `/docstyle:docstyle off` creates the flag file that silences all parts.
[ -e "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/docstyle-chat-off" ] && exit 0

skill="$(dirname "$0")/../skills/docstyle"
patterns="$skill/references/polish/polish-patterns.md"
split='^## Formulaic AI Structures'

case "${1:-core}" in
core)
  cat <<'PREAMBLE'
# docstyle chat style

Write your chat replies in this session in the style of the Google developer documentation style guide. The core rules follow. Apply the full set to English replies; to replies in other languages apply only the structural rules (second person, active voice, present tense, conditions before instructions, list and heading discipline, descriptive links, no future promises, no excessive claims) and never anglicize spelling, punctuation, or word choice. To Polish replies also apply the docstyle Polish rules, which arrive as two more hook outputs. The user's own instructions and output style win where they conflict. Switch off with `/docstyle:docstyle off`.

PREAMBLE
  # Single source of truth: the "Core rules" section of the skill.
  awk '/^## Core rules/{p=1;next} /^## /{p=0} p' "$skill/SKILL.md"
  ;;
polish-a)
  printf '# docstyle Polish rules (part 1 of 2)\n\nWhen you write Polish in this session, in chat or in documents, keep these patterns out of your own text; the fixes show what to write instead.\n\n'
  cat "$skill/references/polish/plain-polish.md"
  echo
  awk -v s="$split" '$0 ~ s {exit} 1' "$patterns"
  ;;
polish-b)
  printf '# docstyle Polish rules (part 2 of 2)\n\n'
  awk -v s="$split" '$0 ~ s {p=1} p' "$patterns"
  ;;
esac
