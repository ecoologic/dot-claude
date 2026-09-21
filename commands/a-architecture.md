---
description: Design the technical architecture for an epic from stories, personas, and the codebase
argument-hint: "[<epic-slug>] [instructions-or-suggestions]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, Skill, AskUserQuestion]
disable-model-invocation: true
---

# Architecture

### Pipeline I/O

| Direction  | File                                                                             | Description                                                       |
| ---------- | --------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **In**     | `~/.claude/commands/a-templates/conventions.md`                                             | Shared path resolution, selector resolution, and repo conventions |
| **In**     | `$EPIC_DIR/idea.md`                                                                | Raw epic idea and links to supporting artifacts                   |
| **In**     | `$EPIC_DIR/epic.md`                                                                | Story list and touched repos from `/a-epic`                       |
| **In**     | `$EPIC_DIR/personas.md`                                                           | Personas from `/a-epic`                                            |
| **In**     | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **Out**    | `$EPIC_DIR/architecture.md`                                                       | Epic-specific architecture, critique, and change mapping           |
| **Out**    | `<repo>/CONTEXT.md`, per touched repo                                             | Durable confirmed terms                                            |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Purpose

Translate product intent into a grounded architecture for this epic.

This command must clearly separate:
- what the epic is trying to build
- what the current system already looks like
- what architecture is recommended for this epic

It is the first epic-specific step that may inspect the codebase.

## Source Of Truth

For product intent and scope, trust sources in this order:
1. `$EPIC_DIR/epic.md`
2. `$EPIC_DIR/personas.md`
3. UI-facing design artifacts and references preserved by `epic.md`
4. `$EPIC_DIR/idea.md`

For implementation reality, trust existing code and established conventions over prototype structure or inferred models.

Use the hierarchy per inconsistency, not as a blanket rule that one file wins for the whole run.

For every inconsistency:
1. isolate the exact claim or assumption in conflict
2. classify what kind of question it is, such as scope, actor intent, interaction detail, terminology, or implementation reality
3. apply the hierarchy only for that question
4. record both the preferred interpretation and the rejected alternative
5. if the hierarchy is not decisive, or if the difference materially changes the architecture recommendation, stop immediately and ask the user about that specific inconsistency before continuing

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. A skill about naming or pattern validation applies when reconciling terminology.

Invoke the `diagrams` skill via `Skill` before writing any diagram in this document.

## Rules

- NEVER write or modify application code, create commits, or write files outside `$EPIC_DIR` or a touched repo's `CONTEXT.md`
- NEVER start with broad codebase exploration before understanding the epic inputs
- NEVER silently trust a prototype or UI-shaped data model
- NEVER define synonyms; a repo's `CONTEXT.md` terms stay canonical unless the user explicitly approves a rename
- Treat inferred models as hypotheses until challenged against the codebase and project conventions
- Prefer existing code and established conventions over prototype structure when they conflict
- Update a repo's `CONTEXT.md` only for durable confirmed terms or mappings; ask before renaming an existing term
- `architecture.md` is the only architecture document; there is no separate cross-epic file to promote findings into

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution: a leading `<epic-slug>` in `$ARGUMENTS`, then the current branch, then memory, then stop and ask.
1. `$ARGUMENTS` = `[<epic-slug>] [instructions-or-suggestions]`. A leading token that names an existing `$PLANNING_ROOT/<token>` folder is the epic slug; everything else is high-priority guidance for this run and never selects the epic.
1. Resolve `$EPIC_DIR`. Record the resolved epic slug in memory.

Read (stop if any are missing):
- `$EPIC_DIR/idea.md`
- `$EPIC_DIR/epic.md`
- `$EPIC_DIR/personas.md`

Follow references from those files to supporting artifacts. Stop and report any unreadable reference.

Extract:
- epic name and slug
- the touched repos listed in `epic.md`'s `## Repos`
- story list and summaries
- personas and constraints
- domain concepts and obvious relationships
- contradictions, gaps, and unknowns

## Step 2: Understand the target system

Before exploring the codebase, derive from the inputs:
1. intended user flows
2. domain concepts implied by the stories
3. likely entities and relationships
4. likely system areas involved
5. open questions and weak assumptions

### 2a. Infer an ERD from the inputs

Infer a provisional domain model from all useful input evidence, not only the UI.

If evidence is strong enough:
- include the inferred ERD in `architecture.md`
- label it as a review artifact, not accepted truth

If evidence is weak:
- say so explicitly
- record what evidence is missing
- do not fabricate entities or relationships

### 2b. Apply source-of-truth hierarchy

When sources disagree, apply the hierarchy above per inconsistency instead of falling back to `idea.md` or guesswork.

Specifically:
1. `epic.md` beats `personas.md` only for explicit epic scope and story definition
2. `personas.md` sharpens actor intent and context when `epic.md` is less specific
3. preserved UI design artifacts clarify interaction details, but do not silently override epic scope
4. `idea.md` is background context once the epic packet exists
5. existing code and established conventions beat prototype structure for implementation decisions
6. the inferred ERD remains a hypothesis until validated

Do not decide "the conflict is in `epic.md`" or "the conflict is in `idea.md`" as a bulk conclusion. Resolve each differing statement on its own merits.

If a contradiction materially changes the architecture recommendation, stop, surface that exact contradiction immediately, and resolve it with the user before continuing.

## Step 3: Load repo context

For each repo listed in `epic.md`'s `## Repos`, read when present:
- `README.md`
- `CLAUDE.md`, at the repo root and at any package level under it
- `CONTRIBUTING.md`
- `CONTEXT.md`

Use these to understand:
- major system areas and responsibilities
- established naming and conventions
- communication paths between parts
- stable contracts and integrations

A repo missing some of these files → continue with what exists and say so explicitly. A repo with none of them → treat it as a greenfield repo for this epic.

## Step 4: Explore relevant codebase areas

Use targeted exploration only in areas relevant to the stories and still needing confirmation, scoped to the repos listed in `epic.md`'s `## Repos`.

Dispatch one `Agent` with type `Explore` per relevant area, up to 5, and reserve one slot for a prototype source when present. Send every dispatch in a single message so they run concurrently, never one after another.

Each exploration prompt must include:
1. the story list
2. the inferred entities, flows, and open questions
3. the repo's `CONTEXT.md`, when present, as the naming baseline
4. the specific system area to inspect

Each exploration result must report:
- relevant file paths
- existing patterns and conventions
- reuse candidates
- naming matches and conflicts
- how the area communicates with the rest of the system
- any durable structure worth recording in `architecture.md`

Display a summary of findings by system area before moving on.

## Step 5: Reconcile terminology

Build a terminology table for `architecture.md`:

| Domain Term | Repo | Code Name | Definition | Source | Status |
| ----------- | ---- | --------- | ---------- | ------ | ------ |

Status values:
- `exists`
- `new`
- `exists (extend with ...)`
- `conflict`
- `rename-request`

Rules:
- existing `CONTEXT.md` terms remain canonical unless the user approves a change
- add safe new rows and safe enrichments to the relevant repo's `CONTEXT.md` in this command
- do not silently rename existing `CONTEXT.md` terms
- keep conflicts and rename requests explicit in `architecture.md` and review them with the user before writing outputs

## Step 6: Make architecture decisions

Organize decisions around change types:

| Area | What Exists | What Changes | Decision | Rationale |
| ---- | ----------- | ------------ | -------- | --------- |

Action types:
- **Reuse as-is**
- **Extend**
- **Extract**
- **New**

Ground decisions in:
1. epic inputs and intended flows
2. current system structure
3. project conventions already present in the codebase

If a decision has meaningful tradeoffs, present options with pros and cons and resolve them with the user before writing outputs.

### 6a. Review open questions before writing

Before writing `architecture.md` or updating `CONTEXT.md`, present the current architecture direction to the user.

Include:
- input conflicts and gaps, listed one by one
- terminology conflicts and rename requests
- decisions with meaningful tradeoffs
- any weak assumptions that affect the recommended model

For each conflict or tradeoff, present explicit options, state which option the hierarchy or codebase evidence favors, and explain the downstream impact.

Persist every resolved source-of-truth inconsistency in `architecture.md` under the same section structure described below so later stages inherit the decision history instead of re-opening the same conflict.

Pause for user feedback on these items before continuing to the write steps.

## Step 7: Critique the inferred model

The architecture document must contain:

### 7a. Inferred ERD from inputs

Include it when evidence is strong enough.

### 7b. Architectural critique of the inferred ERD

Critique it harshly. Evaluate:
1. entity and aggregate boundaries
2. ownership and lifecycle boundaries
3. relationship quality and direction
4. naming and `CONTEXT.md` alignment
5. consistency with existing code and conventions
6. suspicious UI-shaped or convenience-driven entities
7. status blobs, nullable-field sprawl, duplicated data, and missing invariants
8. missing tenant, auth, or access boundaries

Say clearly:
- what to keep
- what to rename
- what to split or merge
- what to remove
- what remains uncertain

### 7c. Recommended domain model

After critique and codebase comparison, propose the model that should guide this epic.

Represent the recommended model in an epic class diagram focused on the entities, components, boundaries, and relationships that must be added, extended, extracted, or reused for this epic.

### 7d. Epic sequence diagrams for required changes

Rules:
- these are required deliverables, separate from the optional inferred ERD
- cover the whole epic through its major user and system interactions
- include more than one sequence diagram when a single flow cannot represent the epic clearly
- map each sequence diagram back to the relevant stories
- show the main technical boundaries and handoffs introduced or affected by the epic
- make runtime and deployment boundaries explicit, such as monorepo apps, API surfaces, jobs, Lambdas, queues, AWS services, databases, and third-party systems
- label arrows with the boundary-crossing contract or call, such as HTTP routes, webhooks, queue publishes or consumes, events, SDK calls, or SQL operations
- do not turn these diagrams into internal function-call traces; concrete code entrypoints may be annotated, but the boundary should remain the primary unit shown

### 7f. Change inventory

List every new or modified artifact that later story and criterion work will depend on.

## Step 8: Write `architecture.md`

Write `$EPIC_DIR/architecture.md` with this structure:

```md
# <Epic Name> — Architecture
> Epic: <epic-slug>
> Generated: <date>
> Repos: `<repo>`, ...
> Stories: `$EPIC_DIR/epic.md`
> Personas: `$EPIC_DIR/personas.md`

## Epic Summary
## Resolved Source-of-Truth Decisions
- Use this section only for inconsistencies that were actually resolved during this step
- Record each resolved inconsistency as its own item using this shape:
  - Question: ...
  - Option A: ...
  - Option B: ...
  - Chosen: ...
  - Basis: which source or evidence won for this specific question, and why
  - Impact: how the decision changed architecture, terminology, reuse, or boundaries
- If no inconsistencies were resolved, write `- None`

### Remaining Input Conflicts and Gaps

List only the contradictions, missing inputs, and weak assumptions that still remain after discussion with the user. Record them as individual items, not bulk file-level conflict notes. This section records items explicitly left open by user choice or still awaiting later resolution.

## Terminology
| Domain Term | Repo | Code Name | Definition | Source | Status |

### Key Domain Concepts

## Current System Landscape

### <system area>
### Communication Paths and Boundaries

## Reuse and Extraction Plan
| Candidate | Source | Action | Stories | Target System Area |

## Technical Decisions
| Area | What Exists | What Changes | Decision | Rationale |

## Diagrams and Model Review

### Recommended Epic Class Diagram
### Recommended Epic Sequence Diagrams

## Change Inventory
| Type | Name | Action | Story | Details |

## Story Mapping
| Story | System Areas | New | Modified | Reused | Risk |

## CONTEXT.md Updates Applied
- Updates made in this run, per repo
- Conflicts or rename requests left for user review

## Risks and Open Questions
## References
```

## Step 9: Update repo terminology

Update the relevant repo's `CONTEXT.md` in this command when the findings are durable and safe:
- add new terms
- enrich existing rows with confirmed code names, sources, or statuses

Do not:
- remove rows
- rename an existing term without explicit user approval
- persist uncertain conflicts as canonical truth

## Step 10: Present to user

Summarize:
- key decisions
- ERD critique and recommended model
- reuse opportunities
- `CONTEXT.md` updates applied, per repo
- `CONTEXT.md` conflicts or rename requests still open
- risks and open questions

Invite final feedback or corrections before moving to `/a-story`. Do not use this step as the primary discussion gate for conflicts or tradeoffs.

## Success Criteria

- [ ] `architecture.md` exists with the required sections
- [ ] all required inputs and followed references were validated before architecture work continued
- [ ] every story appears in Story Mapping and Change Inventory
- [ ] the inferred ERD is included or explicitly unavailable
- [ ] the inferred ERD is criticized, not just described
- [ ] the recommended domain model is explicit
- [ ] the epic-wide class diagram is included
- [ ] the epic-wide sequence diagrams are included
- [ ] resolved inconsistencies, if any, were persisted in `architecture.md` under `## Resolved Source-of-Truth Decisions`, or `- None` was written explicitly
- [ ] any safe durable `CONTEXT.md` updates were applied, in the correct repo
- [ ] blocking conflicts, tradeoffs, and weak assumptions were reviewed with the user before files were written
- [ ] the epic slug is recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **Weak repo context** — continue, perform targeted structural exploration, and say which files were missing
- **Empty or new codebase** — say so explicitly and focus on greenfield decisions
- **Inputs too weak for an ERD** — record the gap instead of fabricating certainty
- **Conflicting input artifacts** — surface the conflict immediately and pause for user direction before continuing
