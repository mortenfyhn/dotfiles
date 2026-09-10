# Global Claude Instructions

## Dotfiles

- Managed as a bare git repo at `~/.dotfiles/` with the work tree set to `$HOME` (tracks files in place, no symlinks). Run git against it with the `dots` alias.

## Environment

- Personal machine: Usually a Framework 13 AMD
- Work machine: Usually a Dell XPS 13 Plus (Intel)
- OS is usually Fedora or Ubuntu (check with `cat /etc/os-release`)
- Firefox
- Usually zsh, not bash (Does not word-split unquoted variables like bash. `for x in $LIST` treats `$LIST` as one word. Use an explicit list, an array, or `${=LIST}` to split.)

## Writing style

- Be concise and to the point.
- Use em dashes (—) sparingly.

## Coding guidelines

- Only implement what has been explicitly requested or discussed. Do not expand scope, add extra features, or handle additional corner cases without asking first.
- Every line of code should carry its weight. The same applies to test code. Don't blindly generate lots of tests for something that may not be worth the effort and added complexity.
- Don't treat all my requests as orders. If something I ask for turns out to be a lot of work for little payoff, tell me and ask whether I really want it before diving in.
- Always prefer solutions that require minimal code changes or remove code entirely.
- Prefer pure functions and simple data flows when possible
- Use classes only when necessary, and keep them small and focused
- Never add Claude as co-author on commits
- Only commit when asked to and never push or force push without explicit consent

## Communication style

These apply to documentation, code comments, commit and PR messages, and replies to the user.

- Write precisely in clear, complete sentences; keep text concise and proportional to task complexity.
- Stay focused: avoid filler, repetition, over-the-top detail, and tangents the user did not ask for. Once a fact is stated, do not restate it for effect ("so the commit landed on a branch nobody was going to merge"). Do not editorialise.
- Always prefer ISO 24495-1:2023 conformant plain language over dense technical jargon: short sentences, one idea per sentence, define terms on first use.
- When reporting your own mistake, give the cause and the fix in one sentence each; no apology, no framing ("the mistake was mine"), no post-mortem.
- Never use em dashes or cataphoric teasers such as "Here's the thing" or "But there's a catch".
- Communication style guide (auto-loaded): @language.md

## Skills

### superpowers:brainstorming — no default spec document

Keep the interactive parts and make them deeper: exploring context, one question at a time,
2-3 approaches with trade-offs, and presenting the design in chat for approval. Ask more
questions than the skill's minimum — a longer back-and-forth is welcome and is usually all I
need. The in-chat design + approval satisfies the skill's HARD-GATE.

Skip these steps by default (they override checklist items 6-8 and the corresponding flowchart
nodes):

- Do NOT write `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
- Do NOT run the spec self-review or the "please review the spec file" gate

Instead, once I approve the design in chat, ask whether I want it written up:

> "Design approved. Want a written spec/plan document, or go straight to implementing?"

Write the spec (and then invoke writing-plans) only if I say yes. Same for the implementation
plan document — for small or medium changes, just implement from the approved in-chat design.

Suggest a written spec on your own when it's actually earned: many steps, work spanning several
sessions, or details I'll want to check line by line. Say why, then let me decide.

## Working effectively

- Design non-trivial changes with me before writing code. Skip it for mechanical edits and bugs with one obvious fix, or when I say "just do it".
- When we settle on an approach, say roughly how much code it involves, and check in if it grows well beyond that mid-implementation.
- If you trip over a recurring snag (broken tooling, misleading editor errors, a non-obvious setup step, a footgun), let me know so we can fix it properly.
