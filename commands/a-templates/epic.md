---
description: "Template: epic.md, the epic's structured story packet produced by /a-epic"
disable-model-invocation: true
---

# Epic document template

`epic.md` lives at `$EPIC_DIR/epic.md`, beside `idea.md`, `personas.md`, and `stretch-goals.md`. `/a-epic` writes it; `/a-edit epic` revises it.

## Shape

The document is these H2 sections, in this order.

````md
---
updated: <date>
status: draft
---

# <Epic Name> (<epic-slug>)

> Epic: <summary>

## Repos
- One line per touched repo, with its path relative to the dev root
- If only one repo, still list it

## Story Order
- The epic's execution sequence, one line per story: `1. Story <n> — <title>`
- This section, NOT the story numbers, is the authoritative order; the `## Story N` sections below may sit in any order
- List every `Actionable` and `Blocked` story exactly once
- A later stage revises this list; it NEVER renumbers a story

## UI Design References
- Every UI-facing reference later stages should read directly, with its type (eg: Lovable), exact path or URL plus a brief note about what it covers.
- If there is a primary design file, list it first and label it clearly
- If none exist, write `- None`

## Resolved Source-of-Truth Decisions
- Use this section only for inconsistencies that were actually resolved during this step
- Record each resolved inconsistency as its own item using this shape:
  - Question: ...
  - Option A: ...
  - Option B: ...
  - Chosen: ...
  - Basis: which source won for this specific question, and why
  - Impact: how the decision changed story scope, boundaries, or wording
- If no inconsistencies were resolved, write `- None`

## Story 1: <title>

> _As a_ [role] \
> _I want_ [action] \
> _So that_ [benefit]

### User Context
- User Role: ...
- User Goals: ...
- Use Case: ...

### Dependencies
- ...

## Story 2: <title>

...

## Domain Concepts
- One bullet per domain concept the idea and its referenced artifacts imply, in plain language
- Include user-visible fields where the inputs show them; omit ids and internal fields unless the inputs state them explicitly
- Derive concepts from the idea and referenced product artifacts only; NEVER from the codebase

## Requirements
- Cross-story requirements that shape the whole epic

## UX Considerations
- Epic-level UX constraints or interaction expectations shared across stories

## Candidate Terms
- Durable product terms this step surfaced but did not confirm against a touched repo's `CONTEXT.md`
- One bullet per term, with a short definition
- If none, write `- None`

## Assumptions
| ID | Assumption | Why It Matters | Status | Evidence or Decision |
| --- | --- | --- | --- | --- |

## References
- ...
````

## Section rules

| Section | Rule |
| --- | --- |
| Assumptions | Per conventions `## Assumptions` (`A-EPIC-<n>`). This step reads no code: it settles a row only with the user, as `resolved`; every other row stays `open` for `/a-architecture` to inherit |
| Candidate Terms | `/a-architecture` Step 5 confirms, rejects, or renames each one before it reaches any `CONTEXT.md`, per conventions `## Terminology` |

## Rules

1. Include only `Actionable` and `Blocked` stories. Exclude every `Nice to have` story; it belongs in `stretch-goals.md` instead
2. When UI references exist, include all of them, even if only some stories use each one
3. List every touched repo in `## Repos`, even when there is only one
4. Place `## Repos` immediately after the epic summary, `## Story Order` after `## Repos`, `## UI Design References` after that, and `## Resolved Source-of-Truth Decisions` immediately after that, so later stages find them near the top
5. Ensure the numbered story sections are unique and contiguous, so later stages resolve `Story N` to one story and one corresponding `story-N.md` file. `## Story Order` lists every one of them exactly once
6. NEVER write numbered acceptance criteria; `/a-story` owns acceptance-criteria drafting
7. NEVER write implementation details, API shapes, schema designs, or task-level work into this document
