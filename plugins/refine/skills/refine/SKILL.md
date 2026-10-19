---
name: refine
description: >-
  This skill should be used when the user wants a raw, chaotic, stream-of-consciousness prompt cleaned up before it is executed: filler words, false starts, typos, self-corrections, contradictions, and scattered ideas rewritten into a clear, structured prompt that keeps every real requirement. Shows the refined prompt and asks the user to accept it (then carries it out), revise it with notes, copy it to the clipboard, or reject it. Triggers: "popraw ten prompt", "uporządkuj prompt", "wyczyść mój prompt", "zrób z tego porządny prompt", "refine this prompt", "clean up my prompt", "tidy this prompt", "/refine".
argument-hint: "<raw, unpolished prompt>"
---

# refine — clean up a messy prompt, then confirm before acting

Take the raw prompt in `$ARGUMENTS` (or, when that is unavailable, the user's message after the invocation). If there is no prompt text at all, ask in one sentence for the prompt and stop.

## Agent compatibility

Invoke as `/refine:refine` in Claude Code, `$refine:refine` in Codex, or `/refine` in Copilot CLI. The closed-question interface means `AskUserQuestion` in Claude Code, `ask_user` in Copilot CLI, or `request_user_input` in Codex when the current mode offers it. When none is available, show the same four options as a numbered list in chat and wait for the answer; never assume a choice.

## Step 1 — refine

Rewrite the raw prompt into a clear, well-structured prompt that faithfully preserves the user's intent. Follow these rules:

- Preserve the original meaning and EVERY genuine requirement, constraint, and detail. Do not add new requirements and do not drop real ones.
- Resolve contradictions and self-corrections in favor of the user's LATEST stated intent (later statements override earlier ones).
- Remove filler ("um", "uh", "er", "like", "you know"; in Polish "yyy", "no", "jakby", "wiesz", "w sumie"), false starts, and redundant repetition.
- Fix typos, grammar, punctuation, and inconsistent terminology.
- Group related points together; use short paragraphs or bullet lists only where they improve clarity.
- Keep the user's voice and level of technical detail. Do not make it more formal or verbose than the original.
- Write the refined prompt in the language of the raw prompt; keep mixed-language technical terms as the user wrote them.
- Do NOT answer, solve, or act on the prompt in this step. Do NOT expand the scope, invent details, or add suggestions. Only clean up what is already there.
- Preserve code, file paths, commands, URLs, and identifiers verbatim.

Example:

- Input: "ok so i want to uh add a login page, actually make it a login AND signup page, use react, oh and it should you know validate the email, wait no just the password for now, min 8 chars"
- Output: Add a combined login and signup page built with React. For now, validate only the password (minimum 8 characters).

## Step 2 — show and ask

Print the refined prompt as plain text, with no blockquote (`>`), code fence, tags, preamble, or commentary. Then ask one closed question in the user's language with exactly these four options (Polish labels shown; translate for other languages):

1. **Akceptuję** — run this prompt now.
2. **Poprawiam** — give notes and get a new version.
3. **Kopiuj prompt** — copy the refined prompt to the clipboard, run nothing. In Claude Code the option description reads: "Pokażę sam prompt, potem wpisz /copy".
4. **Odrzucam** — drop it, do nothing.

## Step 3 — act on the choice

- **Akceptuję** → treat the refined prompt as the user's new request and carry it out now, exactly as if the user had typed it. The refinement rules no longer apply; work normally.
- **Poprawiam** → ask in one sentence what to change and wait. Apply the notes to the current refined prompt (the notes override it where they conflict, under the same rules as Step 1), then repeat Step 2. Loop until the user accepts or rejects.
- **Kopiuj prompt** in Claude Code → run no tools. Reply with the refined prompt exactly as shown and nothing else (no preamble, confirmation, fence, or blockquote), and stop: the user's built-in `/copy` copies the last response to the clipboard, also inside containers and over SSH. Do not act on the raw or the refined prompt.
- **Kopiuj prompt** in other hosts → copy the refined prompt, exactly as shown, to the system clipboard with the shell tool and do nothing else. Pipe it through a quoted heredoc (`cat <<'REFINE_EOF' | <cmd>`) into the first clipboard command that exists: `pbcopy` (macOS), `wl-copy` (Wayland), `xclip -selection clipboard`, `xsel --clipboard --input` (X11), or `clip.exe` (Windows, WSL). Reply with one short line confirming the copy, and stop. If no clipboard command works (for example in a container or over SSH), say so in one line and print the refined prompt in a code fence for manual copying. Do not act on the raw or the refined prompt.
- **Odrzucam** → reply with one short line confirming nothing was done, and stop. Do not act on the raw or the refined prompt.
- **Any other free-text answer** → treat it as revision notes (the **Poprawiam** path).
