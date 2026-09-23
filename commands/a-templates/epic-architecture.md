---
description: "Template: epic-architecture.md, the epic-specific architecture produced by /a-architecture"
disable-model-invocation: true
---

# Architecture document template

`epic-architecture.md` lives at `$EPIC_DIR/epic-architecture.md`. `/a-architecture` writes it; `/a-edit architecture <epic-slug>` revises it.

## Shape

The document is these H2 sections, in this order.

````md
---
updated: 2026-09-23T14:05+1000
status: draft
---

# <Epic Name> — Architecture

> Epic: <epic-slug>
> Repos: `<repo>`, ...
> Stories: `$EPIC_DIR/epic.md`
> Personas: `$EPIC_DIR/epic-personas.md`

## Epic Summary

## Resolved Source-of-Truth Decisions

### Remaining Input Conflicts and Gaps

## Terminology
| Domain Term | Repo | Code Name | Definition | Source | Status |
| ----------- | ---- | --------- | ---------- | ------ | ------ |

### Key Domain Concepts

## Current System Landscape

### <system area>

### Communication Paths and Boundaries

## Reuse and Extraction Plan
| Candidate | Source | Action | Stories | Target System Area |
| --------- | ------ | ------ | ------- | ------------------- |

## Technical Decisions
| Area | What Exists | What Changes | Decision | Rationale |
| ---- | ----------- | ------------ | -------- | --------- |

## Diagrams and Model Review

### Recommended Epic Class Diagram

### Recommended Epic Sequence Diagrams

## Change Inventory
| Type | Name | Action | Story | Details |
| ---- | ---- | ------ | ----- | ------- |

## Story Mapping
| Story | System Areas | New | Modified | Reused | Risk |
| ----- | ------------ | --- | -------- | ------ | ---- |

## CONTEXT.md Updates Applied

## Assumptions
| ID | Assumption | Why It Matters | Status | Evidence or Decision |
| --- | --- | --- | --- | --- |

## Risks and Open Questions

## References
````

## Section rules

| Section | Rule |
| --- | --- |
| Epic Summary | The epic name, slug, and a short summary of intended user flows and system areas |
| Resolved Source-of-Truth Decisions | Only inconsistencies actually resolved during this run. Each item: Question, Option A, Option B, Chosen, Basis, Impact. `- None` when nothing was resolved |
| Remaining Input Conflicts and Gaps | Only contradictions and missing inputs still open after user discussion, one item each, never a bulk file-level note. A weak assumption belongs in `## Assumptions`; cite its ID here when a conflict turns on it |
| Terminology | One row per domain term. `Status` is `exists`, `new`, `exists (extend with ...)`, `conflict`, or `rename-request`. Seeded from `epic.md`'s `## Candidate Terms` plus every term this run's investigation adds |
| Key Domain Concepts | The domain concepts this run confirmed, one bullet each, in the terminology's confirmed names |
| Current System Landscape | One `### <system area>` subsection per area explored, naming its responsibilities and existing structure |
| Communication Paths and Boundaries | How the explored areas talk to each other and to the rest of the system today |
| Reuse and Extraction Plan | One row per reuse or extraction candidate, with the stories it serves |
| Technical Decisions | One row per decision. `Decision` is one of Reuse as-is, Extend, Extract, New |
| Diagrams and Model Review | The inferred ERD, or why it is unavailable, and its harsh critique, as prose, above the two diagrams below |
| Recommended Epic Class Diagram | The epic-wide class diagram for the recommended model: the entities, components, boundaries, and relationships this epic adds, extends, extracts, or reuses |
| Recommended Epic Sequence Diagrams | One or more epic-wide sequence diagrams, each mapped back to the stories it covers |
| Change Inventory | Every new or modified artifact later story and criterion work depends on |
| Story Mapping | One row per story: its system areas, and what is new, modified, reused, and risky |
| CONTEXT.md Updates Applied | Updates made in this run, per repo, plus conflicts or rename requests left for user review |
| Assumptions | Per conventions `## Assumptions`. Every `A-EPIC` row routed here, under its original ID, plus this run's own `A-ARCH-<n>` rows. No rows when nothing was assumed and nothing was inherited |
| Risks and Open Questions | Risks and open questions that are not assumption rows |
| References | Source docs and artifacts this run relied on |

## Rules

1. Every claim not settled by evidence is a row in `## Assumptions`, never confident prose
1. Write `- None` explicitly in `## Resolved Source-of-Truth Decisions` and `### Remaining Input Conflicts and Gaps` when nothing qualifies, rather than omitting the section
1. Every path, term, and code name named is real, or is marked as this run's own proposal
1. NEVER repeat a settled `## Assumptions` row's claim in prose elsewhere; cite its ID
1. `epic-architecture.md` is the only architecture document; there is no separate cross-epic file to promote findings into
