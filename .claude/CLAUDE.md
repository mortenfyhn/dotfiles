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

## Working effectively

- If you trip over a recurring snag (broken tooling, misleading editor errors, a non-obvious setup step, a footgun), don't just work around it silently — either fix it properly or leave a note so the next session (you or me) doesn't lose the same time. Prefer a proper fix; otherwise a short note in the nearest CLAUDE.md (project-specific snags) or a memory. Mention which you did.
