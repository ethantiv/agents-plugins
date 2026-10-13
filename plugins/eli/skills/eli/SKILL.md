---
name: eli
description: >-
  This skill should be used when the user wants a short, one-shot explanation of a concept, term, acronym, or piece of code, pitched at a smart adult with zero knowledge of that domain — concrete, example-driven, never childish. Not for interactive lessons, quizzes, or step-by-step PR walkthroughs (use teach-me for those). Triggers: "wytłumacz jak stażyście", "wytłumacz prosto", "wytłumacz po ludzku", "wyjaśnij jak laikowi", "wyjaśnij obrazowo", "wyjaśnij na przykładzie", "co to w ogóle jest X", "wytłumacz mi to krótko", "explain like I'm an intern", "ELI intern", "ELI5", or invoking the eli skill.
argument-hint: "[concept | term | path | snippet]  — empty = the last thing discussed"
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch
---

# eli — explain like I'm an intern

Explain the subject in `$ARGUMENTS` to **a smart, mature adult who just doesn't know this domain yet** — a sharp new intern on day one. Not a child. Assume general intelligence and life experience; assume **zero** field-specific knowledge unless the user indicates otherwise, and define unfamiliar jargon.

**Answer in the language of the user's request**; default to Polish when it is unclear. Keep code identifiers, commands, and quoted source unchanged. These instructions stay in English.

## Agent compatibility

Use the host’s native tools: Claude Code tool names below describe capabilities, not requirements to call missing tools. Invoke this skill as `/eli:eli` in Claude Code, `$eli:eli` in Codex, or `/eli` in Copilot CLI (use its skill picker if names collide). Take arguments from the user’s message when `$ARGUMENTS` is unavailable.

## Resolve the subject

- **No subject in `$ARGUMENTS` or the user’s message** → use a clear referent from the conversation (for example, "explain that"). If none is clear, ask in one sentence what to explain.
- **Code** → explain *that* code, not the abstract concept, reading only what you need:
  - **Existing file path** → read it.
  - **Directory** → list it and read only the entry points.
  - **Symbol or identifier** (function, class, config key) → search for its definition, then read it.
  - **Pasted snippet** → explain it directly; read nothing.
  - **Path that does not exist** → say so in one line, then treat the input as a concept.
- **Anything else** → an abstract concept, term, or acronym. Use your own knowledge for stable, familiar concepts. Verify uncertain or time-sensitive claims and named sources with available research tools; if unavailable, state the limitation instead of guessing. If an acronym has several meanings (CAP, ACID, PR), pick the one the conversation or repo implies; if nothing does, state the assumed meaning in the first line.

## How to explain

The whole point is **short, vivid, concrete**. A senior engineer skimming it should think "yes, that's the cleanest way to say it" — not "this is padded".

1. **One-line core first.** Open with a single plain-language sentence: what it *is* and what it's *for*. If the reader stops here, they still got the gist.
2. **A concrete example or analogy.** Always. Anchor the idea to something the reader already knows from everyday life or from a domain they do have. Prefer a real, specific example over a generic description. Show a tiny code snippet / number / before-after when it lands the point faster than prose.
3. **Why it matters.** One or two sentences: what problem it solves, what breaks without it.
4. **One gotcha (optional).** The single most common misunderstanding or trap — only if it's genuinely useful. Skip it rather than pad.

## Hard rules

- **Mature, not childish.** No "imagine you're five", no cutesy tone, no talking down. Plain words, full respect for the reader's intelligence.
- **No jargon without paying for it.** If a term is unavoidable, define it in the same breath, in plain words. Don't explain one unknown with three more.
- **Length matches the subject, and stays tight.** A term → a few sentences, no headings, and never label the four steps. A gnarly system → still compact, no walls of text; headings only when it has several distinct parts. Every sentence earns its place; if a line only restates the previous one, cut it.
- **Show, don't pad.** A good example beats a paragraph of qualifiers. Reach for an analogy, a number, or a 3-line snippet before reaching for more sentences.
- **One pass, done.** This is a one-shot explanation, not a tutoring session. If the user wants to go deeper or be quizzed, point them to teach-me — `/teach-me:teach-me` in Claude Code, `$teach-me:teach-me` in Codex, `/teach-me` in Copilot CLI — only if it is installed.

Stop after the explanation. Do not end with a question or a menu of options; mention teach-me only if the user asked to go deeper or be quizzed.
