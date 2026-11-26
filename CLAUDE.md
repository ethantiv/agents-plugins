# CLAUDE.md

## What this is

A plugin marketplace (`ethantiv-plugins`) published from `ethantiv/agents-plugins`. Almost everything is prompt content (`SKILL.md` plus `references/`, `assets/`, `examples/`); the only executable code is in `plugins/babysit-pr/scripts/` (bash + `gh` + `jq`) and `plugins/docstyle/hooks/` (bash). There is no build step and no package manager.

## Tests

No test runner; each test file is a standalone self-check that exits non-zero on failure. They run from any directory:

```bash
bash plugins/babysit-pr/scripts/test/test-auto-gate.sh
bash plugins/babysit-pr/scripts/test/test-pr-snapshot.sh
bash plugins/docstyle/hooks/test/test-chat-style.sh
```

## Manifests and multi-host support

Each plugin lives in `plugins/<name>/` with skills auto-discovered from `skills/<skill>/SKILL.md`. Manifests that must stay in sync:

- `.claude-plugin/marketplace.json` lists every plugin (Claude Code). Its `description` mirrors the plugin's `plugin.json` description.
- `.agents/plugins/marketplace.json` lists only the Codex/Copilot-compatible plugins: `eli`, `refine`, `unslop`, `visual-prompt`, `docstyle`. Its entries use `"source": {"source": "local", "path": "./plugins/<name>"}`, not the plain string of the Claude marketplace.
- Those five plugins have three manifests with the same `version` and `description`: `.claude-plugin/plugin.json` (Claude Code), `.codex-plugin/plugin.json` (Codex, adds `skills` and `interface`), and a root `plugin.json` (Copilot CLI). The Codex manifest repeats the description in `interface.longDescription`; keep it equal.

When changing a plugin's behavior, bump its `version` in every manifest it has. When adding a plugin or changing which hosts it supports, update both marketplaces and the Polish README (plugin list, `Wymagania`, and the Codex and Copilot sections).

Skills for the five cross-host plugins must not assume Claude-only tools: each `SKILL.md` has an `## Agent compatibility` section mapping to the host's equivalents (for example `ask_user` or numbered chat choices instead of `AskUserQuestion`; `spawn_agent` / `task` instead of Workflow/Agent).

Cross-host skills reference bundled files by paths relative to their `SKILL.md` (`references/index.md`); only the Claude-only `babysit-pr` uses `${CLAUDE_PLUGIN_ROOT}/...`.

## babysit-pr architecture

`SKILL.md` drives the loop; deterministic decisions live in scripts. `pr-snapshot.sh` prints a JSON snapshot of the PR (checks, review threads, conflicts), which `SKILL.md` tees to `$(git rev-parse --git-path babysit-pr-snapshot.json)`; `auto-gate.sh` reads it on stdin and decides whether the PR is clean enough to merge (and at which head sha). `restart-review.sh` reruns the review workflow after threads are resolved. Keep merge-safety logic in `auto-gate.sh` and covered by its test. Fix commits carry a `Babysit-PR: fix` trailer; the snapshot flags unpushed commits without it as foreign. Env overrides: `BABYSIT_MERGE_METHOD` (merge|squash|rebase), `BABYSIT_REVIEW_WORKFLOW` (default `claude-code-review.yml`).

## docstyle chat-style hook

`plugins/docstyle/hooks/hooks.json` registers a Claude Code-only SessionStart hook; `hooks.json` runs `chat-style.sh` three times (`core`, `polish-a`, `polish-b`) because Claude Code swaps hook stdout over 10,000 characters for a file path and a preview. `core` prints a preamble plus the `## Core rules` section cut out of `SKILL.md` (keep that heading); the Polish parts print `references/polish/plain-polish.md` and `polish-patterns.md`, split at the `## Formulaic AI Structures` heading. `references/polish/` in docstyle and the miodkuj files in `plugins/unslop/skills/unslop/references/` are verbatim copies of [miodkuj](https://github.com/bartekpucek/miodkuj) (MIT); refresh them from upstream instead of editing. `/docstyle:docstyle off|on` creates or removes the flag file `${CLAUDE_CONFIG_DIR:-~/.claude}/docstyle-chat-off`, which silences the hook.

## Distribution

`ai-devcontainer-sync` and `build-cli-devcontainer` (sibling repos) install the published GitHub version, so local edits only reach them after push. They list plugins by name in `config/env-config.yaml`, so a new plugin needs an entry there too.
