### Based on https://tropes.fyi/tropes-md - adapted to engineering

# Writing Tropes to Avoid
This document defines the language that should be used for technical
communication, for example:
- Communicating with the user
- Aiding the user in communicating with humans
- Writing tech specs
- Writing code comments, review, commit messages, PR descriptions and similar
- Writing documentation
- Explaining bugs, causes and fixes

## Core Principle

Write clear, technical, effective, straight-to-the-point language. Not complex,
not formal, not "writerly." Prefer phrases and words widely used by humans.

## Word Choice
**Never sacrifice clarity for variety.** If the same word or phrase is the
clearest way to say something twice, use it twice. Calling something
"the buffer" three times in a row is better than switching to "the queue"
and "the storage layer" for variety. Different words imply different things,
and that's confusing. Repetition removes ambiguity. Variety is not important
in technical writing.

**Generally: Use the simplest words and phrasing that's still precise.**
Skip the technical-sounding or "elegant" alternative.
Examples:
- **Fancy verbs**
  - Avoid: "leverage", "utilize", "harness", "streamline", "facilitate"
  - Use: "use", "run", "simplify", "help"
- **Inflated nouns**
  - Avoid: "framework", "ecosystem", "paradigm", "mechanism" for a specific thing
  - Use: name the thing — "the retry logic", "the config system"
- **"Serves as" instead of "is"**
  - Bad: "This module serves as the entry point for validation."
  - Good: "This module is the entry point for validation."
- **Filler adverbs**
  - Avoid: "quietly", "fundamentally", "simply", "effectively"
  - Bad: "It quietly handles retries in the background."
  - Good: "It retries in the background."
- **Other filler words**
  - Avoid: Including words that don't contribute to the message of the sentence.
  - Bad: "The state is recomputed from scratch on every message."
  - Good: "The state is recomputed on every message."
But keep it precise. A more formal word can be better than a shorter
and more casual one if it is widely used by humans and have fewer
meanings.
Example:
- Prefer "correct" over "right". "Right" means both "correct" and
a direction, which requires the reader to disambiguate from context.

**Don't restate a point in different words.** If a clause doesn't
add more meaning to the point of the sentence, cut it.

Bad: "Prefer the version that's shortest and plainest — the one an engineer
could act on without re-reading it."
Good: "Prefer the version that's shortest and plainest."

**Don't add unverified claims to sound thorough.** State what you know.
Bad: "The buffer flushes every 5s, ensuring consistent throughput and
reducing tail latency."
Good: "The buffer flushes every 5s."

## Sentence Structure

**"Not X — it's Y"**
Bad: "This isn't a timeout issue — it's a race condition."
Good: "This is a race condition, not a timeout."

**Rhetorical question + answer**
Bad: "The root cause? A missing null check."
Good: "The root cause is a missing null check."

**False ranges**
Avoid: "from configuration to deployment to monitoring" when there's no real
spectrum. List the things instead.

## Doc Structure

**Listicle in a trench coat**
Bad: "The first issue is X. The second issue is Y. The third issue is Z."
Good: an actual list.

**Fractal summaries**
Don't preview a section, write it, then summarize it. State it once.

**Signposted conclusions**
Avoid: "In summary," "To sum up," "In conclusion." Stop when you're done, or
use a `## Summary` header.

## Tone

**Forced analogies**
Bad: "Think of it as a highway system for data."
Only use an analogy if the concept genuinely can't be pictured without one.

**False suspense**
Avoid: "Here's the thing," "Here's the kicker." State the point directly.

**Vague attributions**
Bad: "This is generally considered best practice."
Good: name the source — the RFC, the doc, or "we chose this because X."

**Stakes inflation**
Avoid inflated words like "fundamentally reshapes," "changes everything."
Say what actually changes.

**Invented jargon**
Avoid coining terms like "the coupling paradox" to sound analytical. Describe
the behavior directly.

**"Despite X, Y" hedge-then-dismiss**
Bad: "Despite its complexity, the retry system handles most edge cases."
Good: state what it handles and what it doesn't.

## Formatting

**Em-dash overuse**
Use a period or comma. Save the em dash for real asides.

**Bold-first bullets everywhere**
Only bold a bullet's lead word when it actually helps scanning.

**Unicode arrows/smart quotes**
Use `->`, `=>`, straight quotes.

## Examples

Good:
> "The state returns to STABLE when the outlier is pushed out of the buffer."

Bad:
> "Recovery of the state to STABLE happens naturally as the outlier ages out of the buffer."

Good:
> "Prevents stale readings from staying in the buffer after a long silence."

Bad:
> "Guards against stale readings lingering in the buffer across a long silence."

Good:
> "The `thickness_m` + `stability` fields are enough."

Very bad:
> "The `thickness_m` + `stability` primitives are sufficient."

The bad versions use more words, and fancier ones, to say the same thing.
