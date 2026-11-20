---
name: unslop
description: >-
  This skill should be used when the user asks to "unslop" a document, "remove AI slop", "fix AI-generated text", "make this sound human", "remove signs of AI writing", "humanize this text", "this reads like ChatGPT", "usuń AI-slop", "odslopuj", "popraw tekst po LLM", "zredaguj tekst wygenerowany przez AI", "ten tekst brzmi jak AI", or wants a document edited according to Wikipedia's "Signs of AI writing". Also covers audit-only requests: "audit this text for AI slop", "tylko audyt", "wskaż problemy bez poprawiania". Edits Polish and English documents in place, or returns the revised text in chat when the text is pasted; for Polish it additionally covers officialese and bureaucratic heaviness while keeping the original register (deliberate simplification to plain Polish is /unslop:plain).
argument-hint: "<file path(s) to fix, or a directory> [--audit]"
allowed-tools: Read, Edit, Grep, Glob
---

## Agent compatibility

Use the host’s native tools: Claude Code tool names below describe capabilities, not requirements to call missing tools. Invoke this skill as `/unslop:unslop` in Claude Code, `$unslop:unslop` in Codex, or `/unslop` in Copilot CLI (use its skill picker if names collide). Take arguments from the user’s message when `$ARGUMENTS` is unavailable. Resolve relative resource paths from this SKILL.md, never from the working directory. For optional helper skills, use the host’s skill tool when available, otherwise read the installed skill’s SKILL.md; continue without helpers that are not installed. Cross-plugin references use the invocation syntax of the current host.

# unslop — remove signs of AI writing

Edit the document(s) in `$ARGUMENTS` **in place**, removing the telltale signs of AI-generated writing catalogued by Wikipedia's [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing). Preserve the meaning, the facts, and the order of the argument; change only wording, style, and formatting.

## Workflow

1. **Resolve targets.** If `$ARGUMENTS` contains the flag `--audit`, strip it and run in audit mode (see below) instead of editing. The rest of `$ARGUMENTS` may hold one or more file paths (any text format) or a directory (expand it with `Glob` patterns `**/*.md` and `**/*.txt`; files with other extensions inside a directory are skipped — name them explicitly to include them). **Pasted text** (the text itself is in the user's message instead of a path) → follow [Pasted text](#pasted-text-edit-mode) instead of steps 2–4's file edits. Empty → if another skill loaded this one as an editing pass, or a drafting task is already in progress in the conversation, skip the workflow and apply the pattern catalog below to all prose produced from that point on; otherwise ask in one sentence for the text or the file to fix — don't guess.
2. **Read each file whole** (long files in sequential chunks) and detect its language. Apply the shared patterns below plus the matching vocabulary table. For mixed-language files, apply each language's rules to its own passages. If the text contains Polish, also `Read` these and apply them to the Polish passages:
   - [references/polish-patterns.md](references/polish-patterns.md) — always: the full Polish pattern catalog with its false-positive guards.
   - [references/registers.md](references/registers.md) — always: pick the register (public, business, technical, academic, legal, opinion) before editing; register fit beats generic naturalness.
   - [references/voice-calibration.md](references/voice-calibration.md) — for personal, marketing, newsletter, social, or opinion text.
   - [references/examples.md](references/examples.md) — before → after models, for ambiguous cases and translated word choices.
   - [references/eval.md](references/eval.md) — the pass/fail gate to run before the summary. Its "Edit Mode" checks apply to pasted text; for files, steps 3–4 of this workflow decide the output form ("Embedded Or File Mode"), and for audits the audit mode of this skill does.
3. **Fix with surgical `Edit` calls** — sentence-level replacements, not a wholesale rewrite. The author's voice and structure stay; the slop goes.
4. **Summarize in chat** when done: per file, fix counts for the main categories touched and one or two before → after examples. Write the summary in the conversation language.

Hard rules:

- **Never invent facts.** Slop like "experts argue" is fixed by deleting or hedging honestly ("this is unverified"), never by fabricating a source, number, or name. If a vague claim carries real weight, leave it and flag it in the summary. A removed slogan or kicker is never replaced by an inferred explanation, however plausible: make the claim smaller or end on the preceding supported sentence.
- **Leave clean text alone.** Change a passage only for a pattern you can name; a passage with none stays verbatim, with no cosmetic rewording to show an edit. The author's fragments, asides, self-corrections, deliberate repetition, and uneven rhythm are voice, not slop.
- **Don't touch:** code blocks and inline code, URLs, quoted material, titles, passages that discuss a watched phrase rather than use it, proper names, YAML frontmatter keys, data in tables. Match the file's existing quote style (straight vs typographic) instead of imposing one.
- **Keep the register.** Formal stays formal, casual stays casual — unslopping is not informalizing. Academic hedging, citations, and conventional passive methods language stay; in legal text the obligated party and the legal force stay. Requests to simplify or informalize a Polish text ("uprość", "napisz prościej", "prosty język") are a deliberate register change and belong to `/unslop:plain`, not this skill.
- **Prefer deletion over substitution.** Most slop sentences add nothing; the best fix is usually cutting, not rephrasing. The document should get shorter.
- **Preserve document structure** (heading hierarchy, section order), except where the structure itself is a slop pattern listed below.

## Pasted text (edit mode)

Default for pasted text. Read the catalogs as in step 2, edit no files, and reply in chat. Return the revised text first. Add a short change note only when requested or when a material constraint or evidence gap needs explanation. If the source already passes the quality gate ([references/eval.md](references/eval.md)), return it verbatim without a "no changes needed" note; do not replace correct wording merely to show an edit. An audit request on pasted text follows [Audit mode](#audit-mode).

## Structural patterns (any language)

1. **Inflated significance.** "stands as a testament", "pivotal moment", "underscores its enduring legacy" / "stanowi świadectwo", "kluczowy moment", "odcisnęło trwały ślad" → state the plain fact; cut the grandeur.
2. **Negative parallelisms.** "not just X, but Y", "It's not about X — it's about Y" / "to nie tylko X, ale (także) Y", "nie chodzi o X, chodzi o Y" → keep the half that matters, drop the scaffolding. The same goes for stacked negated fragments ("Not a report. Not a dashboard. A decision system." / "Nie raport. Nie dashboard. System decyzji.") → state the positive claim and keep only a contrast that changes its meaning.
3. **Rule of three.** Forced triads of adjectives, phrases, or examples ("fast, reliable, and scalable") → keep the one or two that carry real information.
4. **Superficial participle analyses.** Trailing "-ing" clauses attributing unsupported significance: "…, highlighting the importance of…", "…, ensuring long-term success" / "…, podkreślając znaczenie…", "…, co pokazuje, jak ważne…" → delete, or turn into a concrete supported claim.
5. **Vague attributions.** "Experts argue", "Industry reports suggest", "Some critics note" / "Eksperci wskazują", "Wielu obserwatorów uważa", "Branżowe raporty sugerują" → name the actual source or drop the claim (see the never-invent rule).
6. **Promotional tone.** "vibrant", "nestled", "rich heritage", "must-see" / "tętniący życiem", "malowniczo położony", "bogate dziedzictwo" → neutral description; a document is not a brochure.
7. **Formulaic endings.** "Challenges and Future Prospects" sections, "Despite these challenges…", hollow-optimism closers ("Time will tell", "a step in the right direction") / "Podsumowując, …", "Przyszłość rysuje się obiecująco", "Czas pokaże", "To krok w dobrym kierunku", "ma ogromny potencjał" → end when the content ends; delete conclusions that only restate.
8. **Copula avoidance.** "serves as", "functions as", "boasts", "features" / "stanowi", "pełni funkcję", "może poszczycić się", "oferuje" (for mere possession) → plain "is" / "has" ("jest" / "ma").
9. **Elegant variation.** Cycling synonyms for one referent (the city → the metropolis → the urban hub) → repeat the ordinary word; repetition is fine.
10. **Chat artifacts.** "I hope this helps", "Let's dive in", "Certainly!", knowledge-cutoff disclaimers, "As an AI…", "Here is the revised version", leftover placeholders ("[insert X]") / "Mam nadzieję, że to pomoże", "Zanurzmy się", "Oto poprawiona wersja", "Jako model językowy" → delete outright.
11. **Throat-clearing and faux-insight setups.** "Here's the thing", "Let me be clear", "What nobody tells you", "The part everyone misses", "What if I told you…", "Plot twist:", self-answered "Question? Answer." pairs / "Powiedzmy sobie szczerze", "Tego nikt ci nie powie", "I tu robi się ciekawie", "Sekret polega na tym, że" → cut the setup and let the claim stand on its own.
12. **Colon reveals and dramatic fragmentation.** A noun phrase, a colon, then a dramatic reveal ("The best part: it learns"), and staccato one-liners for effect ("That's it. That's the whole thing.") / "Najlepsze? Działa od razu.", "To wszystko. Naprawdę." → plain full sentences; colons stay for lists, labels, and quotes.
13. **Fake-profound kickers.** A final "deep" metaphor, aphorism, or mic-drop line ("In the end, it's not about the code — it's about people" / "Bo w końcu nie chodzi o kod. Chodzi o ludzi.") → delete it — never rewrite it into a better metaphor; end on the last concrete point in the text.
14. **Inflated verb phrases.** "made a decision", "has the ability to", "conducted an analysis" / "dokonać zakupu", "przeprowadzić analizę", "ulec poprawie" → the plain verb: "decided", "can", "analyzed" / "kupić", "przeanalizować", "poprawić się".
15. **Robotic rhythm.** Runs of sentences with the same shape and length, identically built paragraphs, stacked punchy fragments → vary sentence length and structure; merge or recast a few so the passage stops ticking like a metronome.
16. **Interpretive metadiscourse.** Prose that steps outside the subject to tell the reader how much a claim weighs instead of giving the reason: "This point matters more than it seems", "As you can see", "In other words" followed by a repetition / "Ten punkt jest ważniejszy, niż się wydaje", "Jak widać", "Innymi słowy" + powtórzenie, "To rozróżnienie ma kluczowe znaczenie" → delete it, or replace it with the consequence the text already supports. Genuine signposting in a long technical, legal, or academic argument stays.
17. **Portable filler.** A sentence that could move unchanged to another company, product, ministry, or project, usually built on "stakeholders", "solutions", "processes", "challenges", "areas", "aspects" / "interesariusze", "rozwiązania", "procesy", "wyzwania", "obszary", "aspekty" → ground it in a fact already in the text, make the claim smaller, or cut it. Definitions, legal formulas, standard warnings, and procedural language are exempt.

## Formatting patterns

- **Bold overuse** — mechanical bolding of "key terms" throughout prose → unbold; keep at most genuinely load-bearing emphasis.
- **List-itis** — bullet lists of `**Header:** description` where flowing prose belongs → merge into sentences; keep lists only for genuinely enumerable items.
- **Em-dash overuse** — more than an occasional `—` → commas, periods, or parentheses. In Polish use the en dash (–) sparingly and correctly.
- **Semicolon overuse** — sentences glued together with `;` where a human would write two sentences or use a comma → split into separate sentences. Especially suspect in Polish, where semicolons are rare in ordinary prose; legitimate uses (complex list items) stay.
- **Emoji as decoration** — 🚀 in headings or bullets of a serious document → remove.
- **Title Case Headings** in English documents → sentence case (match the file's dominant convention if it already has one).
- **Skipped heading levels** (H2 → H4) → restore the hierarchy.
- **Heading inflation** — a heading over every one- or two-sentence section → merge the fragments under one heading.
- **Horizontal rules before headings** → remove; the heading is the break.
- **Tables for prose** — tables holding sentences instead of data → convert to prose.

## Leftover LLM artifacts

Certain proof of AI generation — `Grep` each file for these before reading, and delete every hit (the whole tag, keeping any human-readable text it wraps):

- ChatGPT: `oaicite`, `contentReference`, `turn0search`, `citeturn`
- Gemini: `[cite: 1]`-style tags, `[cite_start]`
- Grok: `grok_card`, `render_inline_citation`
- DeepSeek: lenticular-bracket citations (`Grep` pattern `【[^】]*】`)
- Perplexity: `ppl-ai-file-upload`
- Generic: `:contentReference[oaicite:0]{index=0}`, stray `[1]`-style citation markers pointing at nothing, unresolved placeholders (`[Company Name]`, `[insert date]`)

## Link and citation hygiene

- **Tracking parameters** — strip `?utm_source=…` (and other `utm_*`, `ref=`) from URLs; `utm_source=chatgpt.com` is itself an AI tell.
- **Suspicious citations** — a DOI/ISBN that looks malformed, a source whose title doesn't match the claim, or a reference with no locator (no page, no URL): do not "fix" by guessing and do not delete silently — leave it and flag it in the summary as unverified.
- **Fabrication risk** — never repair a broken citation by inventing a plausible one; that converts detectable slop into undetectable misinformation.

## AI vocabulary

Replace with the plain equivalent, or delete the phrase when it carries no content. A single occurrence can be innocent — density is the signal; when several of these cluster, rewrite the passage.

**English:** delve, tapestry, landscape (figurative), testament, pivotal, crucial, vibrant, showcase, underscore, highlight (verb, figurative), leverage, robust, seamless, foster, garner, boast, intricate, interplay, comprehensive, holistic, transformative, game-changer, cutting-edge, "it's important to note", "in today's fast-paced world", sentence-starting "Additionally," / "Moreover," / "Furthermore," in long chains.

**Polish:** kluczowy, istotny (nadużywane), niezwykle, innowacyjny, kompleksowy, holistyczny, dynamiczny rozwój, szeroko pojęty, "w dzisiejszym świecie", "w dobie…", "warto podkreślić / zauważyć", "należy zaznaczyć", "co więcej" / "ponadto" w łańcuchach, "niewątpliwie" / "bez wątpienia", "krajobraz" (przenośnie: medialny, biznesowy), "serce miasta", "prawdziwa gratka", "pełni kluczową rolę", "w kontekście" (jako wytrych), "swoisty", "niejako", fundamentalny, strategiczny, przełomowy, unikalny, wielowymiarowy, "nie sposób nie wspomnieć", "co istotne", "w obecnych realiach", "w dynamicznie zmieniającym się świecie", "wpisuje się w szerszy trend", "odgrywa coraz większą rolę".

## Audit mode

When `$ARGUMENTS` carries the `--audit` flag, or the user asks for an audit, scan, or diagnosis without rewriting ("tylko audyt", "wskaż problemy", "audit this, don't edit"), make no edits. Instead report, per file, a list of findings: the pattern name, the quoted fragment as evidence, a severity, and the direction of a fix. Severity:

- **Red** — the wording invents or distorts a claim, hides responsibility, changes legal or scientific force, or blocks understanding (fabricated attribution, a suspicious citation, meaning-changing fog). Fix before the text is used.
- **Yellow** — a real style problem, but the meaning survives (AI vocabulary clusters, throat-clearing, robotic rhythm). Worth fixing.
- **Green** — a watched phrase justified here by register, quotation, or terminology. Leave it, and say briefly why it is not a problem.

Two hard limits: never claim the text was written by AI — report the patterns present, nothing about authorship; and never manufacture findings — if the text is clean, say so plainly instead of forcing a report.

## Success check

The pass is done when the file reads like a competent human wrote it: varied sentence rhythm, plain verbs, no pattern from the lists above left in bulk, and no changed meaning. Judge that from the edits you made — a separate re-reading pass is warranted only for a file long enough that you edited it in chunks, where the seams between chunks are the thing to check. If a paragraph still smells like AI but no listed pattern matches, apply the general test — does the sentence say something a knowledgeable human would bother to write? If not, cut it.

---

Patterns 16–17 and the negative-listing and leave-clean-text rules are adapted from [miodkuj](https://github.com/bartekpucek/miodkuj); `references/registers.md`, `voice-calibration.md`, `examples.md`, `eval.md`, `plain-polish.md`, and the catalog in `polish-patterns.md` are copied from it verbatim. Copyright (c) 2026 Bartek Pucek, MIT License.
