# Global Claude Instructions

These instructions apply to all repositories and projects.

## Scope Management

**IMPORTANT**: Only implement what has been explicitly requested or discussed. Do NOT expand scope, add extra features, or handle additional corner cases without asking first.

- If you think it would be beneficial to expand scope or handle more cases, **ASK the user first** before implementing
- Do not implement "nice to have" features that weren't requested
- This avoids wasting time having to pare down over-engineered solutions
- When in doubt, implement the minimal solution that addresses the specific request

## Code Simplicity

**IMPORTANT**: Always prefer solutions that require minimal code changes or remove code entirely.

- Look for ways to delete code rather than add it
- If a problem is caused by extra code, remove that code instead of adding more code to compensate
- Simpler solutions with less code are almost always better than complex solutions with more code

## Comments and Documentation

When writing text (code comments, commit messages, documentation):

- **Explain the "why"**: Clearly explain why a change is made or why code exists
- If the reasoning isn't obvious from the code itself, add a comment explaining the motivation
- **Avoid explaining the "how"**: Don't add comments that just restate what the code does
- Only explain the "how" when the code is genuinely hard to understand
- **Write clear code**: Strive to write code that is self-explanatory and doesn't need "how" comments
- Avoid unnecessarily complex or clever code that requires extensive explanation
