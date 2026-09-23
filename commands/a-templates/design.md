---
description: "Template: design-N.md, the story design produced by /a-design"
disable-model-invocation: true
---

# Design document template

`design-<story-number>.md` lives at `$EPIC_DIR/design-<story-number>.md`, beside `story-<story-number>.md`. `/a-design` writes it; `/a-edit design <story-number>` revises it.

## Shape

The document is these H2 sections, in this order.

````md
---
updated: 2026-09-23T14:05+1000
status: draft
---

# Design <story-number>: <title>

> Epic: <epic name>
> Source Story: `$EPIC_DIR/story-<story-number>.md`

## Goal
- **Problem**: one short paragraph, ELI5
- **Solution**: one short paragraph, ELI5

## UX Definition
### User Flow
1. ...

### States
| State | Description | UI Behaviour |
| ----- | ----------- | ------------ |

### Feedback
- Errors, empty states, loading, success

### Accessibility
- ...

## UI Sketch

```text
+--------------------------------------------------+
| Story Screen Title                               |
+--------------------------------------------------+
| Filter / Search: [______________]   [Action Btn] |
+--------------------------+-----------------------+
| Navigation / List        | Primary Content Area  |
| - Item A                 | - Key field           |
| - Item B                 | - Status              |
| - Item C                 | - Secondary actions   |
+--------------------------+-----------------------+
| Feedback / validation / empty-state messaging    |
+--------------------------------------------------+
```

## Components
### Component Inventory
| Component | New/Existing | Location |
| --------- | ------------ | -------- |

### Component Hierarchy
- ...

### Props And State Boundaries
- What owns which state, and what is passed down

### Styling And Responsive Behaviour
- ...

## File Structure

```text
repo/
├── src/
│   ├── existing/file.ts        # edit
│   └── new/file.ts             # new
└── tests/
    └── new/file.test.ts        # new
```

## New Glossary
| Name | Description | Example Value |
| ---- | ----------- | ------------- |

## Reuse And Extractions
### Reuse Opportunities
| What | Where It Lives | Used For |
| ---- | -------------- | -------- |

### Extractions
| What | From/Why | Target Location | Blocks Story? |
| ---- | -------- | --------------- | ------------- |

## Sequence Diagram

## Class Diagram

## API Endpoints

## DB Migrations

## Happy Path Automated Tests

## Architecture
### Related Code
- ...

### Patterns To Follow
- ...

### Consistency Notes
- ...

### Boundaries And Ownership
- ...

## Current Weaknesses & Risks
| Impact | Risk | Details | Resolution |
| ------ | ---- | ------- | ---------- |

## Assumptions
| ID | Assumption | Why It Matters | Status | Evidence or Decision |
| --- | ---------- | -------------- | ------ | -------------------- |

## Decision Registry
| Decision | Options Considered | Trade-offs | Why This One |
| -------- | ------------------ | ---------- | ------------ |

## AI Notes
- ...

## References
- `$EPIC_DIR/story-<story-number>.md`
- `$EPIC_DIR/architecture.md`
````

## Header

Per conventions `## Document header`. `status` moves to `done` only on the user's final "design is ready" approval.

## Section rules

| Section | Rule |
| --- | --- |
| Goal | Problem and Solution, one short paragraph each, ELI5. Nothing else |
| UX Definition | The story has no UI → write `- None` and omit the subsections |
| UI Sketch | A compact ASCII layout: primary regions, key controls, important content, main affordances. Labels use the story's own terminology. No UI → `- None` |
| Components | Every existing component carries a real repository path. No UI → `- None` |
| File Structure | A `tree`-shaped block of the files this story touches. Mark each one `new` or `edit` |
| New Glossary | Every new class, method, function and constant this design coins. `Example Value` is what it holds or returns, `N/A` for a class |
| Reuse Opportunities | What already exists that this story uses instead of writing. Every row carries a real path |
| Extractions | Only an extraction this story itself justifies. NEVER one for hypothetical future use |
| Sequence Diagram | The `uml-diagram` agent draws it, mode `design`, form `sequence`. Paste it verbatim. Story altitude, boundary-crossing calls only |
| Class Diagram | The `uml-diagram` agent draws it, mode `design`, form `class`. Paste it verbatim. Each concept once, DB representation. `((NEW))`, `((CHANGED))`, `((DELETED))` for real schema changes only |
| API Endpoints | Endpoint usage only. Follow a project API skill's format when one exists |
| DB Migrations | The full SQL, one block, no comments |
| Happy Path Automated Tests | The expected results written as test lines, in the repo's own test format. One line per acceptance criterion at minimum |
| Architecture | Boundaries, dependency direction, ownership, the patterns to follow, the smells to avoid, and the inconsistencies this story must respect |
| Current Weaknesses & Risks | One row per risk, biggest impact first. `Impact` is a T-shirt size. `Risk` is a title, 5 words max. `Details` is an ELI5 example, 3 sentences max. `Resolution` is a status — `open`, `accepted`, `mitigated`, `postponed` — then a one-sentence solution |
| Assumptions | Per conventions.md's Assumptions rule. No row this story's implementation requires may stay `open` or `cascaded` |
| Decision Registry | The ONLY place that holds how the design got here. Every considered option, its trade-offs, and why the agreed one won. A resolved risk moves here from the section above |
| AI Notes | Invariants, gotchas and existing code to reuse that no other section records. NEVER a work breakdown, a task packet, or a model and effort table |

## Rules

1. Omit a section the story genuinely has nothing for, except `## UX Definition`, `## UI Sketch` and `## Components`, which write `- None` when the story has no UI
1. Mark every speculation `TODO`
1. Every path and symbol is real, or is marked as planned by this design
1. NEVER record conversation history outside `## Decision Registry`. A wording or naming back-and-forth belongs nowhere, unless it changed the approach
1. NEVER repeat `architecture.md`'s epic-level diagrams. This document is story altitude
