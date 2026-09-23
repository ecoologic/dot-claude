---
description: Design the technical architecture for an epic from stories, personas, and the codebase
argument-hint: "[<epic-slug>] [instructions-or-suggestions]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, Skill, AskUserQuestion, Bash(git rev-parse:*), Bash(date:*), Bash(git symbolic-ref:*), Bash(git branch:*)]
disable-model-invocation: true
---

# Architecture

### Pipeline I/O

| Direction  | File                                                                             | Description                                                       |
| ---------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| **In**     | `~/.claude/commands/a-templates/conventions.md`                                             | Shared path resolution, selector resolution, and repo conventions |
| **In**     | `~/.claude/commands/a-templates/epic-architecture.md`                                  | The template for the output document                              |
| **In**     | `$EPIC_DIR/epic-requirements.md`                                                                | Raw epic idea and links to supporting artifacts                   |
| **In/Out** | `$EPIC_DIR/epic.md`                                                                | Story list, `## Domain Concepts`, `## Candidate Terms`, and touched repos from `/a-epic`; update `## Story Order` or an absorbed prerequisite only when implementation reality forces it, NEVER a story number |
| **In**     | `$EPIC_DIR/epic-personas.md`                                                           | Personas from `/a-epic`                                            |
| **In**     | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **Out**    | `$EPIC_DIR/epic-architecture.md`                                                       | Epic-specific architecture, critique, and change mapping           |
| **Out**    | `<repo>/CONTEXT.md`, per touched repo                                             | Durable confirmed terms, including `epic.md`'s confirmed candidate terms |

`$EPIC_DIR` resolves per conventions.md.

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
2. `$EPIC_DIR/epic-personas.md`
3. UI-facing design artifacts and references preserved by `epic.md`
4. `$EPIC_DIR/epic-requirements.md`

For implementation reality, trust existing code and established conventions over prototype structure or inferred models.

Use the hierarchy per inconsistency, not as a blanket rule that one file wins for the whole run.

For every inconsistency:
1. isolate the exact claim or assumption in conflict
2. classify what kind of question it is, such as scope, actor intent, interaction detail, terminology, or implementation reality
3. apply the hierarchy only for that question
4. record both the preferred interpretation and the rejected alternative
5. if the hierarchy is not decisive, or if the difference materially changes the architecture recommendation, stop immediately and ask the user about that specific inconsistency before continuing

## Skills

Discover and invoke project skills per conventions `## Skills`; it also names the global skills for this stage: `grill-me` at the Step 10 gate, `engineering:architecture` for Step 9's decision records, `diagrams` for every mermaid diagram, and `ask-user-question` for every `AskUserQuestion` call. A repo or package skill about naming or pattern validation applies when reconciling terminology.

## Rules

- NEVER write or modify application code, create commits, or write files outside `$EPIC_DIR` or a touched repo's `CONTEXT.md`
- NEVER start with broad codebase exploration before understanding the epic inputs
- NEVER silently trust a prototype or UI-shaped data model
- NEVER define synonyms; a repo's `CONTEXT.md` terms stay canonical unless the user explicitly approves a rename
- Treat inferred models as hypotheses until challenged against the codebase and project conventions; every surviving hypothesis is a row in `## Assumptions`, never confident prose
- Prefer existing code and established conventions over prototype structure when they conflict
- Update a repo's `CONTEXT.md` only for durable confirmed terms or mappings; ask before renaming an existing term
- `epic.md`'s `## Candidate Terms` are unconfirmed until this command confirms them into a repo's `CONTEXT.md`; `a-epic` never writes `CONTEXT.md`
- `epic-architecture.md` is the only architecture document; there is no separate cross-epic file to promote findings into
- prefer reordering `epic.md`'s `## Story Order` to match implementation dependency order over having an earlier story silently absorb a later story's prerequisite; either resolution is surfaced to the user, NEVER decided silently
- NEVER change a story number; the number is identity. `## Story Order` carries the sequence, and it is the only ordering this command may rewrite
- write `epic-architecture.md` per conventions `## Write as you go`: create it from its template at the first write, then Edit only the section a step just settled
- Invoke the `diagrams` skill via `Skill` before drawing any diagram in this document

## Step 1: Resolve required inputs

1. Read conventions.md. This command is a planning stage: follow conventions `## Where a command runs` (stop if started inside a worktree; print a warning if not on the default branch) and its planning-stage selector order — this command's own argument, then memory, then stop and ask.
1. `$ARGUMENTS` = `[<epic-slug>] [instructions-or-suggestions]`. A leading token that names an existing `$PLANNING_ROOT/<token>` folder is the epic slug; everything else is high-priority guidance for this run and never selects the epic.
1. Resolve `$EPIC_DIR`. Record the resolved epic slug in memory, per conventions `## Memory`.

Read (stop if any are missing):
- `$EPIC_DIR/epic-requirements.md`
- `$EPIC_DIR/epic.md`
- `$EPIC_DIR/epic-personas.md`
- `~/.claude/commands/a-templates/epic-architecture.md`

Follow references from those files to supporting artifacts. Stop and report any unreadable reference.

Extract:
- epic name and slug
- the touched repos listed in `epic.md`'s `## Repos`
- story list and summaries
- `epic.md`'s `## Domain Concepts` and `## Candidate Terms`
- personas and constraints
- contradictions, gaps, and unknowns

Create `$EPIC_DIR/epic-architecture.md` from `~/.claude/commands/a-templates/epic-architecture.md` now: the header with `status: draft`, the title, and every H2 heading. Every later step Edits its own section alone as it settles.

Output:
```text
Epic: <epic name>
Epic dir: <EPIC_DIR>
Touched repos: <list>
Stories: <count>
epic-architecture.md: created from template
```

## Step 2: Understand the target system

Before exploring the codebase, derive from the inputs:
1. intended user flows
2. domain concepts implied by the stories
3. likely entities and relationships
4. likely system areas involved
5. open questions and weak assumptions, each one a row in `## Assumptions`

### 2a. Infer an ERD from the inputs

Infer a provisional domain model from all useful input evidence, including `epic.md`'s `## Domain Concepts`, not only the UI.

If evidence is strong enough:
- include the inferred ERD in `epic-architecture.md`
- label it as a review artifact, not accepted truth

If evidence is weak:
- say so explicitly
- record what evidence is missing
- do not fabricate entities or relationships

### 2b. Apply source-of-truth hierarchy

When sources disagree, apply the hierarchy above per inconsistency instead of falling back to `epic-requirements.md` or guesswork.

Specifically:
1. `epic.md` beats `epic-personas.md` only for explicit epic scope and story definition
2. `epic-personas.md` sharpens actor intent and context when `epic.md` is less specific
3. preserved UI design artifacts clarify interaction details, but do not silently override epic scope
4. `epic-requirements.md` is background context once the epic packet exists
5. existing code and established conventions beat prototype structure for implementation decisions
6. the inferred ERD remains a hypothesis until validated

Do not decide "the conflict is in `epic.md`" or "the conflict is in `epic-requirements.md`" as a bulk conclusion. Resolve each differing statement on its own merits.

If a contradiction materially changes the architecture recommendation, stop, surface that exact contradiction immediately, and resolve it with the user before continuing.

Edit `## Epic Summary` now.

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
- any durable structure worth recording in `epic-architecture.md`

Display a summary of findings by system area before moving on.

Edit `## Current System Landscape` now: one `### <system area>` subsection per area explored, and `### Communication Paths and Boundaries`.

## Step 5: Reconcile terminology

Build the `## Terminology` table for `epic-architecture.md`, seeded from `epic.md`'s `## Candidate Terms` plus every domain term this run's investigation adds:

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
- confirm `epic.md`'s `## Candidate Terms` into the relevant repo's `CONTEXT.md` when safe and durable; this is their first landing point, since `a-epic` never writes `CONTEXT.md`
- add other safe new rows and safe enrichments to the relevant repo's `CONTEXT.md` in this command too
- do not silently rename existing `CONTEXT.md` terms
- keep conflicts and rename requests explicit in `epic-architecture.md` and review them with the user at the Step 10 gate

Edit `## Terminology` and `### Key Domain Concepts` now.

## Step 6: Record the inferred ERD

Per Step 2a: include the inferred ERD when evidence is strong enough, labeled as a review artifact, not accepted truth. Evidence too weak → say so explicitly and name what is missing.

Edit `## Diagrams and Model Review` now with this content.

## Step 7: Critique the inferred model

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

Edit `## Diagrams and Model Review` now, continuing after the inferred ERD.

## Step 8: Recommend the domain model

After critique and codebase comparison, propose the model that should guide this epic.

Represent the recommended model in an epic class diagram focused on the entities, components, boundaries, and relationships that must be added, extended, extracted, or reused for this epic.

Edit `### Recommended Epic Class Diagram` now.

## Step 9: Make architecture decisions

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

Invoke the `engineering:architecture` skill via `Skill` when drafting each decision record.

If a decision has meaningful tradeoffs, present options with pros and cons; resolve them with the user at the Step 10 gate.

Edit `## Technical Decisions` and `## Reuse and Extraction Plan` now.

### 9a. Check story order against implementation reality

`/a-epic` orders stories by user value alone, before any codebase investigation. Validate that `epic.md`'s `## Story Order` still holds now that real dependencies are known.

1. For each story, check whether it can be delivered and proven end-to-end using only what stories placed before it in `## Story Order` establish
2. A story that needs ground only a later-placed story establishes is an order conflict
3. Present every order conflict found, with both resolution paths: move the affected stories within `## Story Order` to match implementation order, or keep the order and have the earlier story explicitly absorb the missing prerequisite
4. Default to reordering; recommend it unless the user has a standing reason to keep the original order
5. This surfaces only as deep as this run's investigation goes. A conflict found later, in `/a-story` or `/a-design`, is surfaced explicitly there and recorded as an upstream finding against `epic.md`'s `## Story Order` for `/a-finish` to apply; NEVER silently absorbed, NEVER ignored, and NEVER written into `epic.md` by a story-level command
6. Reordering chosen → rewrite `epic.md`'s `## Story Order` only, leaving every story number, `## Story N` heading, and future `story-N.md` filename untouched
7. Absorption chosen → record in `epic.md`'s story text that the earlier story's scope now includes the prerequisite
8. Update the affected stories' `### Dependencies` too, so the edge that forced the resolution is recorded, not just its outcome
9. Either way, record the resolution under `## Resolved Source-of-Truth Decisions`, same shape as any other resolved conflict

### 9b. Settle the assumption ledger

Inherit every `A-EPIC` row routed here, per conventions `## Assumptions`. Add a row under `A-ARCH-<n>` for every claim this run acted on without evidence: an inferred entity, an unvalidated flow, a guessed boundary, an untested reuse candidate.

1. This run's codebase investigation is the evidence. Settle a row `verified` or `invalidated` the moment it settles, citing the file, line, or test
2. The inferred ERD, its entities, and its relationships stay assumptions until Step 7's critique settles them; carry them as rows, NEVER as confident prose
3. A row no architecture decision requires → cascade it straight to the `story-<n>.md` whose implementation requires it, or `every story-N.md`, per conventions `## Assumptions`. NEVER gate Step 10 on it. No story requires it either → that is a gate, not a cascade; put it to the user at Step 10 instead
4. A row an architecture decision requires, still unsettled from code → put it to the user at Step 10, one at a time, with what it affects and what changes if it is false
5. Still unsettled after Step 10 → cascade it the same way as point 3
6. An `invalidated` row already baked into `epic.md` → surface its impact at Step 10 and record the user's decision under `## Resolved Source-of-Truth Decisions`. This command's `epic.md` write permission still stops at `## Story Order` and an absorbed prerequisite

Edit `## Assumptions` now.

## Step 10: Review with the user

Invoke the `grill-me` skill via `Skill` before running this gate.

Present the current architecture direction to the user:
- input conflicts and gaps, listed one by one
- terminology conflicts and rename requests
- story order conflicts against implementation reality, with both resolution paths
- decisions with meaningful tradeoffs
- any weak assumptions that affect the recommended model
- the assumption ledger: every row still `open` that an architecture decision requires, what it blocks, and what changes if it is false, per conventions `## Assumptions`

For each conflict or tradeoff, present explicit options, state which option the hierarchy or codebase evidence favors, and explain the downstream impact. Keep each question within conventions `## Size caps`.

Edit `## Resolved Source-of-Truth Decisions` and `### Remaining Input Conflicts and Gaps` now, as each item resolves. Continue to Step 11 only once every item above has the user's response.

## Step 11: Draw the epic sequence diagrams

Rules:
- these are required deliverables, separate from the optional inferred ERD
- cover the whole epic through its major user and system interactions
- include more than one sequence diagram when a single flow cannot represent the epic clearly
- map each sequence diagram back to the relevant stories
- show the main technical boundaries and handoffs introduced or affected by the epic
- make runtime and deployment boundaries explicit, such as monorepo apps, API surfaces, jobs, Lambdas, queues, AWS services, databases, and third-party systems
- label arrows with the boundary-crossing contract or call, such as HTTP routes, webhooks, queue publishes or consumes, events, SDK calls, or SQL operations
- do not turn these diagrams into internal function-call traces; concrete code entrypoints may be annotated, but the boundary should remain the primary unit shown

Edit `### Recommended Epic Sequence Diagrams` now.

## Step 12: Build the change inventory

List every new or modified artifact that later story and criterion work will depend on. Map each item to the stories, system areas, and reuse status established above.

Edit `## Change Inventory` and `## Story Mapping` now.

## Step 13: Final check and approval

Per conventions `## Write as you go`: read `~/.claude/commands/a-templates/epic-architecture.md` again, check `$EPIC_DIR/epic-architecture.md` against its `## Shape`, and Edit in only the sections still missing. NEVER rewrite a section an earlier step already settled.

Present the completed document to the user. On approval, Edit the header's `status` line to `done`.

## Step 14: Update repo terminology

Update the relevant repo's `CONTEXT.md` in this command when the findings are durable and safe:
- add new terms
- enrich existing rows with confirmed code names, sources, or statuses

Do not:
- remove rows
- rename an existing term without explicit user approval
- persist uncertain conflicts as canonical truth

Edit `## CONTEXT.md Updates Applied` now.

## Step 15: Present to user

Summarize:
- key decisions
- ERD critique and recommended model
- reuse opportunities
- `CONTEXT.md` updates applied, per repo
- `CONTEXT.md` conflicts or rename requests still open
- risks and open questions
- the assumption ledger: rows verified, invalidated, resolved, and cascaded, with the story each cascade lands in

Invite final feedback or corrections before moving to `/a-story`. Do not use this step as the primary discussion gate for conflicts or tradeoffs; that already happened at Step 10.

## Success Criteria

- [ ] `epic-architecture.md` exists, created from its template at the first write and completed incrementally, per conventions `## Write as you go`
- [ ] all required inputs and followed references were validated before architecture work continued
- [ ] every story appears in Story Mapping and Change Inventory
- [ ] the inferred ERD is included or explicitly unavailable
- [ ] the inferred ERD is criticized, not just described
- [ ] the recommended domain model is explicit
- [ ] the epic-wide class diagram is included
- [ ] the epic-wide sequence diagrams are included
- [ ] resolved inconsistencies, if any, were persisted in `epic-architecture.md` under `## Resolved Source-of-Truth Decisions`, or `- None` was written explicitly
- [ ] every story's place in `## Story Order` was checked against implementation reality; any conflict found was surfaced, resolved with the user, and recorded
- [ ] no story number was changed; any reordering was applied to `epic.md`'s `## Story Order` alone
- [ ] every `A-EPIC` row routed to this doc was inherited into `## Assumptions` under its original ID, per conventions `## Assumptions`
- [ ] every assumption this run could settle from the codebase is `verified` or `invalidated`, with its evidence cited
- [ ] the Step 10 gate covered only rows an architecture decision requires, per conventions `## Assumptions`; every other unsettled row was cascaded straight to a named `story-<n>.md` or `every story-N.md`, never gated here
- [ ] every gated row this run could not settle was put to the user, and is `resolved`
- [ ] `epic.md`'s `## Candidate Terms` were confirmed into the relevant repo's `CONTEXT.md`, or left explicit as conflicts for user review
- [ ] any other safe durable `CONTEXT.md` update was applied, in the correct repo
- [ ] blocking conflicts, tradeoffs, and weak assumptions were reviewed with the user at the Step 10 gate before the header's `status` was set to `done`
- [ ] the epic slug is recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **Weak repo context** — continue, perform targeted structural exploration, and say which files were missing
- **Empty or new codebase** — say so explicitly and focus on greenfield decisions
- **Inputs too weak for an ERD** — record the gap instead of fabricating certainty
- **Conflicting input artifacts** — surface the conflict immediately and pause for user direction before continuing
