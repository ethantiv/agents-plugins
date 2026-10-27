# agents-plugins

Marketplace wtyczek dla [Claude Code](https://claude.com/claude-code). Wtyczki `docstyle`, `eli`, `refine`, `teach-me`, `unslop` i `visual-prompt` działają też w Codex i GitHub Copilot CLI.

Dostępne wtyczki: `babysit-pr`, `book-forge`, `dependency-update`, `docstyle`, `eli`, `read-arxiv-paper`, `refine`, `roadmap`, `teach-me`, `unslop` i `visual-prompt`. Wtyczki są od siebie niezależne, więc instaluj tylko te, których potrzebujesz.

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
| `book-forge` | Python 3, Node.js, wtyczka `unslop` oraz skill i CLI agent-browser |
| `babysit-pr` | `git`, `jq` i `gh` zalogowane do GitHuba |
| `read-arxiv-paper` | `curl` i `tar` |
| `dependency-update` | Menedżery pakietów twojego projektu, na przykład `npm` albo `pip`, w `PATH` |
| `teach-me` | Opcjonalnie: Git do lekcji o zmianach w kodzie i `gh` do lekcji o PR |

Żeby zainstalować skill i CLI agent-browser dla `book-forge`, uruchom:

```bash
npx skills add https://github.com/vercel-labs/agent-browser --skill agent-browser
npm install -g agent-browser
agent-browser install
```

Żeby zmienić sposób scalania w `babysit-pr`, ustaw `BABYSIT_MERGE_METHOD` na `merge` (domyślnie), `squash` albo `rebase`. Jeśli workflow recenzji nazywa się inaczej niż `claude-code-review.yml`, ustaw `BABYSIT_REVIEW_WORKFLOW`.

## Licencja

[MIT](LICENSE)
