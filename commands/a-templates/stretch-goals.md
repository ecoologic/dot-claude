---
description: "Template: stretch-goals.md, the epic's deferred later-scope stories produced by /a-epic"
disable-model-invocation: true
---

# Stretch goals document template

`stretch-goals.md` lives at `$EPIC_DIR/stretch-goals.md`, beside `epic.md`. `/a-epic` writes it; `/a-edit stretch-goals` revises it.

## Shape

The document is these H2 sections, in this order.

````md
---
updated: <date>
---

# <Epic Name> Stretch Goals

> Epic: <epic-slug>
> Purpose: Deferred later-scope stories that are explicitly not required reading for the current pipeline stage.

## How To Use This File
- Treat this as parking lot scope for later review.
- Do not assume later commands must read this file unless the user explicitly asks for it.

## Stretch Goal 1: <title>

> _As a_ [role] \
> _I want_ [action] \
> _So that_ [benefit]

### Why Later
- ...

### Dependencies or Enablers
- ...

## Stretch Goal 2: <title>

...

## References
- ...
````

## Rules

1. If there are no stretch goals, still create the file and say so clearly
