---
description: "Template: idea.md, the epic's raw idea and supporting links captured by /a-epic"
disable-model-invocation: true
---

# Idea document template

`idea.md` lives at `$EPIC_DIR/idea.md`. `/a-epic` Step 0 writes it from `[details]` verbatim when it does not yet exist, and reads it whole on every later run.

## Shape

The document is these H2 sections, in this order.

````md
---
updated: <date>
---

# <epic-slug>

<the raw epic idea, verbatim from `[details]`>

## References
- Link or path to each supporting artifact the idea mentions
- If none, write `- None`
````

## Rules

1. Write the idea text verbatim; NEVER paraphrase, trim, or reword what the user gave
2. `/a-epic` follows every reference here to its supporting material and reports any that is unreadable
