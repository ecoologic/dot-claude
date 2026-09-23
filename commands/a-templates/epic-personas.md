---
description: "Template: epic-personas.md, the epic's actors and usage context produced by /a-epic"
disable-model-invocation: true
---

# Personas document template

`epic-personas.md` lives at `$EPIC_DIR/epic-personas.md`, beside `epic.md`. `/a-epic` writes it; `/a-edit personas` revises it.

## Shape

The document is these H2 sections, in this order.

````md
---
updated: <date>
---

# <Epic Name> Personas

> Epic: <epic-slug>

## Persona 1: <name>
- Role: ...
- Primary goals: ...
- Current pain points: ...
- Context of use: ...
- Permissions or constraints: ...

## Persona 2: <name>
...

## Shared Constraints
- ...

## References
- ...
````

## Rules

1. Only include personas that matter to the epic; avoid speculative future roles
