# agents-plugins

Marketplace wtyczek dla [Claude Code](https://claude.com/claude-code). Wtyczki `docstyle`, `eli`, `refine`, `unslop` i `visual-prompt` działają też w Codex i GitHub Copilot CLI.

Dostępne wtyczki: `babysit-pr`, `docstyle`, `eli`, `refine`, `unslop` i `visual-prompt`. Wtyczki są od siebie niezależne, więc instaluj tylko te, których potrzebujesz.

## Instalacja w Claude Code

1. Dodaj marketplace:

   ```bash
   claude plugin marketplace add ethantiv/agents-plugins
   ```

2. Zainstaluj wtyczkę, na przykład `unslop`:

   ```bash
   claude plugin install unslop@ethantiv-plugins
   ```

3. Sprawdź instalację:

   ```bash
   claude plugin marketplace list
   ```

W sesji Claude Code możesz zamiast tego użyć poleceń `/plugin marketplace add` i `/plugin install`.

## Instalacja w Codex

```sh
codex plugin marketplace add ethantiv/agents-plugins
codex plugin add unslop@ethantiv-plugins
```

Uruchom sesję ponownie i wywołaj skill jako `$<wtyczka>:<skill>`, na przykład `$unslop:unslop`.

## Instalacja w GitHub Copilot CLI

```sh
copilot plugin marketplace add ethantiv/agents-plugins
copilot plugin install unslop@ethantiv-plugins
```

Rozpocznij nową sesję i wywołaj skill jako `/<skill>`, na przykład `/unslop`. Jeśli dwie wtyczki mają skill o tej samej nazwie, wybierz go z listy skilli.

## Wymagania

Wtyczki, których nie ma w tabeli, potrzebują tylko CLI hosta.

| Wtyczka | Wymagania |
| --- | --- |
| `babysit-pr` | `git`, `jq` i `gh` zalogowane do GitHuba |

Żeby zmienić sposób scalania w `babysit-pr`, ustaw `BABYSIT_MERGE_METHOD` na `merge` (domyślnie), `squash` albo `rebase`. Jeśli workflow recenzji nazywa się inaczej niż `claude-code-review.yml`, ustaw `BABYSIT_REVIEW_WORKFLOW`.

## Licencja

[MIT](LICENSE)
