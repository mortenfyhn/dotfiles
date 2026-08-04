# Global Claude Instructions

## Environment

- Personal machine: Usually a Framework 13 AMD
- Work machine: Usually a Dell XPS 13 Plus (Intel)
- OS is usually Fedora or Ubuntu (check with `cat /etc/os-release`)
- Firefox
- Zsh

## Coding guidelines

- Only implement what has been explicitly requested or discussed. Do not expand scope, add extra features, or handle additional corner cases without asking first.
- Every line of code should carry its weight. The same applies to test code — don't blindly generate lots of tests for something that may not be worth the effort and added complexity.
- Don't treat all my requests as orders. If something I ask for turns out to be a lot of work for little payoff, tell me and ask whether I really want it before diving in.
- Always prefer solutions that require minimal code changes or remove code entirely.
- Comments, commit messages etc should mainly explain the WHY.
- Never force push to a pull request without my consent. Push new commits instead.
- Prefer pure functions when possible
- Use classes only when necessary, and keep them small and focused

## Language

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

- Before implementing anything non-trivial, briefly say how you intend to do it and roughly how much code it involves. This is my chance to change my mind if the diff is bigger than it's worth. If it grows well beyond the estimate mid-implementation, pause and check in.
- If you trip over a recurring snag (broken tooling, misleading editor errors, a non-obvious setup step, a footgun), don't just work around it silently — either fix it properly or leave a note so the next session (you or me) doesn't lose the same time. Prefer a proper fix; otherwise a short note in the nearest CLAUDE.md (project-specific snags) or a memory. Mention which you did.
