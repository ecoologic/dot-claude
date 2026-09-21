---
description: Break a story into user-approved acceptance criteria, UX/UI definition, and codebase context
argument-hint: "[<story-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Story Breakdown

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `$EPIC_DIR/epic.md` | User stories, story-level context and dependencies, touched repos, and epic-level UI references from `/a-epic` |
| **In** | `$EPIC_DIR/architecture.md` | Epic-specific architecture from `/a-architecture`, and the assumptions it cascaded to this story |
| **In** | `$EPIC_DIR/personas.md` | Personas from `/a-epic` |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **Out** | `$EPIC_DIR/story-<story-number>.md` | Detailed story breakdown: slug, numbered acceptance criteria, UX/UI definition, codebase context, and upstream findings for `/a-design` and, eventually, `/a-finish` |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. A skill about UX, UI, or the project's frontend framework applies when defining the story's interface.

## Purpose

Break one story into a concrete, code-informed context without writing code. This command should:
- investigate the current codebase
- draft and refine acceptance criteria with the user before locking them into the story artifact
- define reuse opportunities and constraints
- refine story-level details when needed
- record any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` as an upstream finding, for `/a-finish` to apply later
- settle every assumption it inherits or coins, by codebase evidence or by the user, before `/a-design`
- capture schema-impact context when the story changes persisted schema
- produce a single story artifact with a stable slug and numbered acceptance criteria for `/a-design`

## Rules

- NEVER write or modify application code, create commits, or write files outside `$EPIC_DIR`
- NEVER write `epic.md`, `architecture.md`, or a repo's `CONTEXT.md`; record the finding in `story-<story-number>.md`'s `## Upstream Findings` instead, per `~/.claude/commands/a-templates/conventions.md`'s Upstream findings rule
- NEVER change a story number, in this file's name, in its heading, or in `epic.md`; an order conflict is recorded as an upstream finding against `epic.md`'s `## Story Order`, never applied here
- NEVER skip codebase investigation; story work must be grounded in the real codebase
- NEVER finish this command with an assumption still `open` or `cascaded`; `/a-design` inherits a settled ledger or the command gates
- NEVER state an unverified claim as settled fact in any section; record it as a row in `## Assumptions` and cite its ID where it matters
- NEVER define synonyms; if a term exists in a touched repo's `CONTEXT.md`, use its canonical name
- NEVER abbreviate new names
- NEVER propose extractions for hypothetical future use
- NEVER write unnumbered acceptance criteria; later stages select a specific criterion by number
- NEVER finalize the acceptance-criteria list without explicit user approval for each criterion in order, unless the user lifted the gate per conventions.md's Bulk approval rule
- NEVER accept a criterion that names a technology layer (eg: "add the table", "add the endpoint", "add the form") instead of a user-observable outcome
- write and update `story-<story-number>.md` incrementally, per conventions.md's Incremental writes rule; NEVER hold the whole file in conversation only to write it once at the end

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<story-number>] [details]`. A leading integer is the story number; the rest is high-priority guidance for this run. `$ARGUMENTS` never carries an epic slug — the epic itself resolves per conventions.md (branch, then memory, then ask).
1. No story number in `$ARGUMENTS` → fall through selector resolution: the current branch, then memory, then list the available story numbers from `epic.md` and ask.
1. Record the resolved story number in memory.

Read (stop if any are missing):
- `$EPIC_DIR/epic.md`
- `$EPIC_DIR/architecture.md`
- `$EPIC_DIR/personas.md`

Follow all references from planning artifacts. Stop and report any unreadable reference.

When `epic.md` contains a `UI References` section, treat those references as required input. Read and follow them before working on any story with UI.

Extract the requested story section from `epic.md`. The story context includes:
- title
- canonical story statement
- user context
- acceptance criteria
- dependencies

Also extract the epic-level sections from `epic.md` that apply across stories:
- touched repos
- draft ERD
- requirements
- UX considerations
- UI references
- references

Output:
```text
Story: <title>
Epic: <epic name>
Architecture: loaded
Personas: loaded
Epic-level context: loaded
Has UI: <yes | no>
UI references: <list or none>
```

## Step 2: Draft acceptance criteria with the user

Use the selected story's canonical statement from `epic.md`, its user context, dependencies, personas, and any trailing guidance to propose the story's working acceptance criteria list.

Draft them interactively:
1. propose exactly one numbered acceptance criterion at a time, starting with `1`, phrased as _Given_ [precondition] / _When_ [action] / _Then_ [expected result]
2. ask the user to approve or revise that specific criterion before proposing the next one
3. if the user revises a criterion, fold the revision into the wording and confirm it before continuing
4. do not draft criterion `N + 1` until criterion `N` is explicitly approved, unless the user lifts the gate per the Bulk approval rule below
5. keep the numbering stable once a criterion is approved; if a later change forces renumbering, stop and get explicit user confirmation for the renumbered list
6. the user may approve criterion `N` and ask for the rest in one pass (eg: "do the rest", "draft them all") — apply `~/.claude/commands/a-templates/conventions.md`'s Bulk approval rule: draft every remaining criterion in one pass, still following the rules below, then print the whole batch together and let the user revise it before it locks. This lifts only the criterion-drafting gate; Steps 3 onward still run and still stop at their own checkpoints

While drafting:
- split overly broad source criteria into multiple numbered criteria when that improves implementation clarity
- merge duplicate or overlapping source criteria when the user agrees
- keep criteria implementation-relevant and testable, but do not turn them into tasks
- reject a criterion phrased as a technology layer; ask for a rephrase around the user-observable outcome before numbering it
- preserve canonical naming from each touched repo's `CONTEXT.md`

After the last criterion is approved, restate the full numbered list and treat it as the locked acceptance-criteria source for the rest of the command.

Immediately compare the locked list against `architecture.md` and note any epic-level technical detail that now needs confirmation, correction, or expansion during investigation.

Once the list locks, write `story-<story-number>.md` now with its header, story statement, `## User Context`, and `## Acceptance Criteria` sections, per the shape in Step 10.

## Step 3: Investigate the codebase

Use `architecture.md` and each touched repo's `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`, and `CONTEXT.md` to scope targeted code exploration to achieve the story acceptance criteria.

The five axes below are **independent** — dispatch one `Agent` with type `Explore` per axis, all in a single message so they run concurrently. Don't run them sequentially.

1. related existing code
2. patterns and conventions
3. reuse opportunities
4. epic-specific architecture details worth recording as an upstream finding for `/a-finish`
5. evidence for or against every `open` and `cascaded` assumption this story inherits from `epic.md` and `architecture.md`, per `~/.claude/commands/a-templates/conventions.md`'s Assumptions rule

Each investigation result should report:
- relevant files
- why they matter
- patterns to follow
- reusable components, services, types, or utilities
- naming matches or conflicts with `CONTEXT.md`

The fifth axis reports one verdict per assumption instead: its ID, the evidence found, and whether that evidence proves it, disproves it, or settles nothing. NEVER let it return an opinion without a file, line, or test behind it.

If the story affects persisted schema, also identify:
- affected entities or tables
- relationships relevant to the story
- fields that are new, changed, or deleted
- unchanged fields that are still relevant to the story's implementation or review

Display the findings before proceeding.

## Step 4: Check consistency

Based on the investigation, evaluate:
1. naming conventions
2. file placement conventions
3. API and service patterns
4. component patterns
5. test patterns
6. type and contract patterns

Flag inconsistencies that matter to this story. Do not fix unrelated issues.

Update `story-<story-number>.md`'s `## Codebase Context` and `## Consistency Notes` sections now.

## Step 5: Define UX

If the story has UI, discover and invoke a project skill about UX per `~/.claude/commands/a-templates/conventions.md`, and define:
- user flow
- states
- feedback
- accessibility requirements

Use the followed UI references to ground those decisions. Do not invent UI behavior that contradicts the referenced design artifacts unless the conflict is surfaced explicitly.

If there is no UI, explicitly note that UX/UI sections are skipped.

Update `story-<story-number>.md`'s `## UX Definition` section now.

## Step 6: Define UI

If the story has UI, define:
- component inventory
- hierarchy
- important props and state boundaries
- styling approach
- responsive behavior

If there is no UI, explicitly note that UI sections are skipped.

Update `story-<story-number>.md`'s `## UI Definition` (including `### ASCII UI Sketch`) and `## UI References` sections now.

## Step 7: Define opportunities for code extraction and reusability

Identify justified extractions:
- shared components
- shared utilities
- shared types
- necessary refactors

Only include extractions that are clearly warranted by this story.

Update `story-<story-number>.md`'s `### Extractions` table now.

## Step 8: Record upstream findings

Deeper investigation may uncover something `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` should eventually reflect: a story wording, boundary, sequencing, or dependency correction; an epic-specific technical detail other stories should inherit; a durable domain name, code name, source, or status. NEVER write any of those three files from this command.

Record each finding in `story-<story-number>.md`'s `## Upstream Findings` section instead:
- the target doc: `epic.md`, `architecture.md`, or `<repo>/CONTEXT.md`
- the finding
- the suggested change

A story-order conflict is one of these findings, never a rewrite: target `epic.md`'s `## Story Order`, name the position this story must move to, and name the dependency that forces it. NEVER renumber a story — the number is identity, and `story-N.md`, `design-N.md`, `plan-N-M.md`, the branch name, and the memory selector all key on it.

`/a-finish` reads this section once the story's last criterion lands and applies whichever findings are still confirmed.

Update `story-<story-number>.md`'s `## Upstream Findings` section now.

## Step 9: Settle the assumption ledger

`/a-design` NEVER starts with an unsettled assumption. This step is the deadline, per `~/.claude/commands/a-templates/conventions.md`'s Assumptions rule.

1. Inherit every `open` and `cascaded` row from `epic.md` and `architecture.md` that this story touches, under its original ID. NEVER renumber one, NEVER drop one by omission
2. Add a row under `STORY-<story-number>-<n>` for every claim this run acted on without evidence
3. Step 3's fifth axis already reported what the codebase proves or disproves. Mark each row `verified` or `invalidated` now, citing the file, line, or test that settled it
4. Put every row still `open` to the user, one at a time, with what it blocks and what changes if it is false. NEVER batch them into one question, unless the user lifts the gate per conventions.md's Bulk approval rule
5. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`: record their decision in their words, and its impact. NEVER a silent pass
6. The user cannot settle a row → stop. That is a gate: report the row, what it blocks, and the decision needed. NEVER hand `/a-design` an `open` or `cascaded` row
7. An `invalidated` row already baked into `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` also goes to `## Upstream Findings`, per Step 8

Update `story-<story-number>.md`'s `## Assumptions` section now.

## Step 10: Write `story-<story-number>.md`

Derive `<story-slug>` as the kebab-case form of the title. `story-<story-number>.md` already exists → reuse its existing `Slug:` value instead of re-deriving it, so the slug survives a later title reword.

Write `$EPIC_DIR/story-<story-number>.md` with this structure:

This file is the single source of truth for the story. It captures the slug, story context, codebase findings, UX, UI, references, justified extractions, upstream findings, and the user-approved numbered acceptance criteria that `/a-design` reads next.

```md
# Story <story-number>: <title>

> Epic: <epic name>
> Slug: <story-slug>
> Generated: <date>
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

## UX Definition
### User Flow
1. ...

### States
| State | Description | UI Behavior |
| ----- | ----------- | ----------- |

### Accessibility
- ...

## UI Definition
### Component Inventory
| Component | New/Existing | Location |
| --------- | ------------ | -------- |

### Component Hierarchy
- ...

### ASCII UI Sketch
- If the story has UI, include a compact ASCII drawing that shows the primary layout, key controls, important content regions, and main interaction affordances
- Keep it implementation-oriented and readable in plain text; use labels that match the story terminology and followed UI references
- If the story does not have UI, write `- None`

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

## UI References
- Story-relevant subset of the epic-level UI references, plus any story-local UI references followed during this run
- If none exist, write `- None`

## Codebase Context
### Related Code
- ...

### Patterns To Follow
- ...

### Reuse Opportunities
- ...

## Consistency Notes
- ...

### Extractions
| What | From/Why | Target Location | Blocks Story? |
| ---- | -------- | --------------- | ------------- |

## Assumptions
| ID | Assumption | Why It Matters | Status | Evidence or Decision |
| --- | ---------- | -------------- | ------ | -------------------- |

## Upstream Findings
| Doc | Finding | Suggested Change |
| --- | ------- | ----------------- |

## References
- `$EPIC_DIR/architecture.md`
```

Rules for the story artifact:
- acceptance criteria must stay explicitly numbered; later stages select a specific criterion by number
- every criterion must be phrased as _Given_ / _When_ / _Then_, so it stays testable without becoming a task
- every criterion must describe a user-observable outcome, never a technology layer
- `## Upstream Findings` lists every incongruity found against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md`, with no rows when none were found; NEVER apply one of those files' changes directly from this command
- `## Assumptions` carries every inherited and own assumption, each one `verified`, `resolved`, or `invalidated` by the time this command finishes; no row may stay `open` or `cascaded`

## Step 11: Present to user

Summarize:
1. number of acceptance criteria
2. critical path
3. reuse opportunities
4. upstream findings recorded, for `/a-finish` to apply
5. the assumption ledger: rows verified from code, rows the user resolved, rows invalidated, and the evidence behind each
6. risks and open questions

Ask the user to review the completed story artifact before moving to `/a-design`.

## Success Criteria

- [ ] `story-<story-number>.md` exists
- [ ] all required inputs and followed references were validated before story work continued
- [ ] `story-<story-number>.md` carries a `Slug:` header
- [ ] `story-<story-number>.md` contains numbered acceptance criteria, each phrased as _Given_ / _When_ / _Then_
- [ ] each acceptance criterion was explicitly approved by the user before the next criterion was drafted, or the user explicitly lifted the gate to bulk-draft the rest, per conventions.md's Bulk approval rule
- [ ] acceptance criteria cover the story's happy path plus important errors, failures, and security constraints
- [ ] every acceptance criterion describes a user-observable outcome, not a technology layer
- [ ] UI stories include a `### ASCII UI Sketch` section with a readable plain-text layout sketch; non-UI stories explicitly write `- None`
- [ ] story-relevant UI references were carried into `story-<story-number>.md`, or `- None` was written explicitly
- [ ] any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` found this run was recorded in `## Upstream Findings`, never applied directly
- [ ] any story-order conflict found this run was recorded as an upstream finding against `epic.md`'s `## Story Order`; no story was renumbered
- [ ] every `open` and `cascaded` assumption this story inherits from `epic.md` and `architecture.md` appears in `## Assumptions` under its original ID
- [ ] every assumption the codebase could settle is `verified` or `invalidated`, with a file, line, or test cited
- [ ] every remaining assumption was put to the user and is `resolved` in their words; none is left `open` or `cascaded`
- [ ] the user reviewed the output before the pipeline advanced
- [ ] the story number is recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **Story not found in `epic.md`** — list available story numbers and ask the user to pick one
- **No relevant code found** — say so explicitly and treat the story as a greenfield area while still following project-wide patterns
