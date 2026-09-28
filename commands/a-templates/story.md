---
description: "Template: story-N.md, the story artifact produced by /a-story"
disable-model-invocation: true
---

# Story document template

`story-<story-number>.md` lives at `$EPIC_DIR/story-<story-number>.md`, beside `epic.md` and `epic-architecture.md`. `/a-story` writes it; `/a-edit story <story-number>` revises it.

## Shape

The document is these H2 sections, in this order.

```md
---
updated: 2026-09-23T14:05+1000
status: draft
branch: checkout-flow/1-guest-email
---

# Story <story-number>: <title>

> Epic: <epic name>
> Source Story: `$EPIC_DIR/epic.md`

> _As a_ [role] \
> _I want_ [action] \
> _So that_ [benefit]

## User Context
- ...

## Acceptance Criteria

### Criterion 1
> _Given_ [precondition] \
> _When_ [action] \
> _Then_ [expected result]

### Criterion 2
> _Given_ ... \
> _When_ ... \
> _Then_ ...

## UI References
- Story-relevant subset of the epic-level UI references, plus any story-local UI references followed during this run
- If none exist, write `- None`

## Assumptions
| ID | Assumption | Why It Matters | Status | Evidence or Decision |
| --- | ---------- | -------------- | ------ | -------------------- |

## Findings
| Doc | Finding | Suggested Change |
| --- | ------- | ----------------- |

## References
- `$EPIC_DIR/epic-architecture.md`
```

## Section rules

| Section | Rule |
| --- | --- |
| Header | Per conventions `## Document header`. `branch` is set the moment the story slug locks: `<epic-slug>/<n>-<story-slug>`. It is the story branch; criterion code lands on each criterion's own branch, per conventions `## Criterion branches` |
| User Context | Carried over from `epic.md`'s `### User Context` for this story |
| Acceptance Criteria | Numbered, each phrased _Given_ / _When_ / _Then_, per conventions `## Canonical blocks`. Later stages select a criterion by number |
| UI References | The story-relevant subset of `epic.md`'s `## UI Design References`, plus any story-local reference followed this run. No UI → `- None` |
| Assumptions | Per conventions `## Assumptions` |
| Findings | Per conventions `## Findings` |

## Rules

1. The file carries no technical design. Components, contracts, file structure, reuse, extractions, UX, UI and diagrams live in `story-<story-number>-design.md`
1. Every acceptance criterion describes a user-observable outcome, never a technology layer
1. `## Findings` lists every incongruity found against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md`, with no rows when none were found
