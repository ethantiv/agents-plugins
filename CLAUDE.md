# CLAUDE.md

## What this is

A plugin marketplace (`ethantiv-plugins`) published from `ethantiv/agents-plugins`. Almost everything is prompt content (`SKILL.md` plus `references/`, `assets/`, `examples/`); the only executable code is in `plugins/book-forge/scripts/` (Python 3, stdlib only) and `plugins/babysit-pr/scripts/` (bash + `gh` + `jq`). There is no build step and no package manager.

## Tests

No test runner; each test file is a standalone self-check that exits non-zero on failure. They run from any directory:

```bash
python3 plugins/book-forge/scripts/tests/test_bible.py
python3 plugins/book-forge/scripts/tests/test_echo.py
bash plugins/babysit-pr/scripts/test/test-auto-gate.sh
bash plugins/babysit-pr/scripts/test/test-pr-snapshot.sh
```

`test_bible.py` works in a temp dir via `BIBLE_DIR`; it never touches real book projects.

## Manifests and multi-host support

Each plugin lives in `plugins/<name>/` with skills auto-discovered from `skills/<skill>/SKILL.md`. Manifests that must stay in sync:

- `.claude-plugin/marketplace.json` lists every plugin (Claude Code). Its `description` mirrors the plugin's `plugin.json` description.
- `.agents/plugins/marketplace.json` lists only the Codex/Copilot-compatible plugins: `eli`, `refine`, `teach-me`, `unslop`, `visual-prompt`, `docstyle`.
- Those six plugins have three manifests with the same `version` and `description`: `.claude-plugin/plugin.json` (Claude Code), `.codex-plugin/plugin.json` (Codex, adds `skills` and `interface`), and a root `plugin.json` (Copilot CLI).

When changing a plugin's behavior, bump its `version` in every manifest it has. When adding a plugin or changing which hosts it supports, update both marketplaces and the README (plugin table, install commands, Requirements, Usage, Codex and Copilot sections).

Skills for the six cross-host plugins must not assume Claude-only tools: each `SKILL.md` has an `## Agent compatibility` section mapping to the host's equivalents (for example `ask_user` or numbered chat choices instead of `AskUserQuestion`; `spawn_agent` / `task` instead of Workflow/Agent).

Cross-host skills reference bundled files by paths relative to their `SKILL.md` (`references/index.md`); only the Claude-only `book-forge` and `babysit-pr` use `${CLAUDE_PLUGIN_ROOT}/...`.

## book-forge architecture

A 12-stage Polish novel pipeline (stage table in `plugins/book-forge/README.md`, roadmap in `shared/roadmap.md`). All prose and skill text in this plugin is Polish.

- Stages hand data to each other through files in the user's book directory: human-facing `*.html`, `ksiazka.md` and `pakiet.md` in the root; everything else in a hidden `.book-forge/`. The canon ("biblia") is `.book-forge/biblia/**/*.md`.
- `scripts/bible.py` is the single library and CLI for the canon: markdown pages whose frontmatter is JSON (not YAML), merged by `load_all()` into one object whose 17 sections are defined in `shared/biblia-spec.md`. Skills call `bible.py check-stage <stage>` as a preflight before launching an expensive swarm, and `bible.py status` for progress. Series mode nests everything under `tom-NN/` via the `BOOK_DIR`, `WORK` and `BIBLE_DIR` env vars.
- Fields are RO or RUNTIME (see `biblia-spec.md`). Only `continuity-check` writes canon from the prose stages.
- Most stage skills follow one pattern: `SKILL.md` gathers input, `references/workflow-swarm.md` holds the Workflow agent-swarm script (fallback: parallel Task agents), `references/build-and-verify.md` defines the `DATA` object injected into `assets/*-template.html` and the validation (`node --check` on the generated HTML script).
- `shared/polish-style.md` is the shared Polish style guide. Most stages run a `/unslop:unslop` pass (a cross-plugin dependency), but scene prose gets it only in `polish-pl`, after `continuity-check`, so `write-scene` must not run it.
- `scripts/echo.py` is the repetition detector used by `assemble-book`.

## babysit-pr architecture

`SKILL.md` drives the loop; deterministic decisions live in scripts. `pr-snapshot.sh` prints a JSON snapshot of the PR (checks, review threads, conflicts), which `SKILL.md` tees to `$(git rev-parse --git-path babysit-pr-snapshot.json)`; `auto-gate.sh` reads it on stdin and decides whether the PR is clean enough to merge (and at which head sha). `restart-review.sh` reruns the review workflow after threads are resolved. Keep merge-safety logic in `auto-gate.sh` and covered by its test. Fix commits carry a `Babysit-PR: fix` trailer; the snapshot flags unpushed commits without it as foreign.

## Distribution

`ai-devcontainer-sync` and `build-cli-devcontainer` (sibling repos) install the published GitHub version, so local edits only reach them after push. They list plugins by name in `config/env-config.yaml`, so a new plugin needs an entry there too.
