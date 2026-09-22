---
description: Agree one story's design with the user - boundaries, contracts, UX, UI, diagrams, names
argument-hint: "[<story-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Story Design

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `~/.claude/commands/a-templates/design.md` | The template for the output document |
| **In** | `$EPIC_DIR/story-<story-number>.md` | The story: slug, numbered acceptance criteria, user context, UI references, settled assumptions |
| **In** | `$EPIC_DIR/architecture.md` | The epic's architecture, its epic-level diagrams, and its terminology |
| **In** | `$EPIC_DIR/epic.md` | Touched repos, epic-level UI references, and the draft ERD |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **In/Out** | `$EPIC_DIR/story-<story-number>.md` | Append to `## Upstream Findings` only. NEVER change any other section |
| **Out** | `$EPIC_DIR/design-<story-number>.md` | The agreed design: goal, UX, UI, components, file structure, reuse, contracts, diagrams, risks, decisions |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. A skill about coding, APIs, testing, UX, UI, or the project's frontend framework applies to the design decision it covers.

The `diagrams` skill belongs to the `uml-diagram` agent, not to this command. NEVER read it here.

## Purpose

Agree ONE story's design with the user, then record it. This command should:
- agree boundaries, modules, classes, interactions, contracts and names
- define the story's UX, its UI, and the components that deliver them
- ground every path, symbol and pattern in the real codebase
- have the `uml-diagram` agent draw every diagram
- review the agreed design on four axes, and record what that review finds
- settle every assumption it coins, and reprint the ledger it inherits
- record any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` as an upstream finding
- produce one design document that `/a-plan` turns into per-criterion plans

## Rules

- NEVER write implementation steps, work breakdowns, task packets, subagent instructions, model tables or effort tables; `/a-plan` owns all of those
- NEVER write application code, and NEVER create commits
- NEVER write files outside `$EPIC_DIR`
- NEVER write `epic.md`, `architecture.md`, or a repo's `CONTEXT.md`; append the finding to `story-<story-number>.md`'s `## Upstream Findings` instead, per conventions.md's Upstream findings rule
- NEVER edit any section of `story-<story-number>.md` except `## Upstream Findings`
- NEVER change a story number, in this file's name, in its heading, or in `epic.md`
- NEVER draw a diagram yourself; the `uml-diagram` agent is the only diagram author, see Step 6
- NEVER restate `architecture.md`'s epic-level diagrams; `design-<story-number>.md` is story altitude and shows only what this story changes
- NEVER start work with an assumption still `open` or `cascaded` in `story-<story-number>.md`; that is a gate, see Step 1
- NEVER design for an acceptance criterion the story does not carry, and NEVER design the next story
- NEVER define synonyms; if a term exists in a touched repo's `CONTEXT.md`, use its canonical name
- NEVER abbreviate new names
- NEVER propose extractions for hypothetical future use
- NEVER state a speculation as agreed; mark it `TODO` in the document
- NEVER store conversation history anywhere but `## Decision Registry`
- NEVER offer to proceed to implementation or to `/a-plan`; the user says when the design is ready
- The user can be wrong. Clarify and find the correct solution rather than following a mistaken instruction
- Asked to change an existing interface beyond this story's scope → explain the consequence and ask for confirmation first
- Interactions in chat stay brief and follow the active output style; express the design in the document, not in chat
- write and update `design-<story-number>.md` incrementally, per conventions.md's Incremental writes rule

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<story-number>] [details]`. A leading integer is the story number; the rest is high-priority guidance for this run. `$ARGUMENTS` never carries an epic slug — the epic itself resolves per conventions.md (branch, then memory, then ask).
1. No story number in `$ARGUMENTS` → fall through selector resolution: the current branch, then memory, then list the story numbers that have a `story-N.md` on disk and ask.
1. Record the resolved story number in memory.

Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>.md`
- `$EPIC_DIR/architecture.md`
- `$EPIC_DIR/epic.md`
- `~/.claude/commands/a-templates/design.md`

Follow all references from planning artifacts. Stop and report any unreadable reference.

When `story-<story-number>.md` or `epic.md` lists UI references, treat them as required input. Read and follow them before designing any UI.

`story-<story-number>.md` carries a row in `## Assumptions` still `open` or `cascaded` → STOP. `/a-story` is that ledger's deadline. Report the row and send the user to `/a-edit story <story-number> <guidance>`.

`design-<story-number>.md` already exists → read it. This run revises that document; NEVER start a second one, and NEVER discard an agreed decision without saying so.

Output:
```text
Story: <story-number> — <title>
Slug: <story-slug>
Epic: <epic name>
Epic dir: <EPIC_DIR>
Repos: <repo>, <repo>
Criteria: <count>
Has UI: <yes | no>
UI references: <list or none>
Existing design: <yes, revising | no, new>
```

## Step 2: Ground the design in the codebase

Scope the exploration with `architecture.md` and each touched repo's `README.md`, `CLAUDE.md`, `CONTRIBUTING.md` and `CONTEXT.md`.

These four axes are **independent** — dispatch one `Agent` with type `Explore` per axis, all in a single message so they run concurrently. Don't run them sequentially.

1. the code that must change to satisfy the story's acceptance criteria, with exact paths and symbols
2. the patterns, boundaries and dependency direction this story must follow
3. reuse: existing components, services, types, utilities and tests this story can use instead of writing
4. the contracts the story touches: current signatures, routes, types, schema and migrations

Each result reports paths, symbols, why they matter, and any conflict with `architecture.md` or a repo's `CONTEXT.md`.

NEVER accept a result without a file and a symbol behind it.

Display the findings, then write `design-<story-number>.md`'s `## File Structure`, `## Architecture` and `### Reuse Opportunities` sections. `### Extractions` holds decisions, not findings; it locks in Step 3.

## Step 3: Agree the design with the user

This is the command's core. Work the design out loud with the user, one decision at a time, and record what locks.

1. Propose the goal first: the problem and the solution, ELI5, one short paragraph each. Get it approved before anything else
1. Then propose each design decision in turn: a boundary, a module, a contract, a name, a data shape. Ask the user to approve or revise that decision before proposing the next
1. A decision that changes an earlier one → say what it supersedes, and update the earlier section
1. The user may lift the gate and ask for the rest in one pass, per conventions.md's Bulk approval rule. Print the whole batch together for one round of revision before it locks
1. Record every option considered, its trade-offs, and why the agreed one won, in `## Decision Registry`. A wording or naming back-and-forth is NOT a decision worth persisting; record it only when it changed the approach
1. The user decided with no stated reason → write `User decision.`, then your own reasoning, marked as yours

Reuse the canonical terminology from `architecture.md` and each touched repo's `CONTEXT.md`. A genuinely new name goes in `## New Glossary` with an example value.

Write `## Goal`, `## New Glossary`, `## Decision Registry` and the contract sections (`## API Endpoints`, `## DB Migrations`) as each one locks.

## Step 4: Define the UX

No UI in this story → write `- None` under `## UX Definition` and `## UI Sketch`, say so once, and go to Step 5.

Discover and invoke a project skill about UX per conventions.md, then define:
- the user flow, end to end
- the states, and the UI behaviour of each
- the feedback the user gets, including errors and empty states
- the accessibility requirements

Ground these in the followed UI references. NEVER invent UI behaviour that contradicts a referenced design artifact; surface the conflict instead.

Then draw the `## UI Sketch`: a compact ASCII layout showing the primary regions, key controls, important content and the main interaction affordances. Keep it implementation-oriented, and label it with the story's own terminology.

Write `## UX Definition` and `## UI Sketch` now.

## Step 5: Define the components

No UI in this story → write `- None` under `## Components` and go to Step 6.

Define:
- the component inventory, each marked new or existing, with its location
- the component hierarchy
- the props and the state boundaries: what owns which state, and what is passed
- the styling approach and the responsive behaviour

Every existing component named here comes from Step 2's reuse axis, with a real path.

Write `## Components` now.

## Step 6: Draw the diagrams

The `uml-diagram` agent is the only diagram author. NEVER draw one yourself, and NEVER edit what it returns.

1. Call `Agent` with `subagent_type: "uml-diagram"`, once per diagram section, every time the design changes what that section shows
1. The prompt carries these and nothing else:
   1. the mode: `design`, and the form: `sequence` or `class`
   1. the current design text the diagram depends on
   1. the repository paths of the existing code the design touches
1. Paste what the agent returns VERBATIM under the section heading. The agent validates its own diagram
1. The agent reports the section is undiagrammable → omit the section and say why in one clause

The two diagrams show different things. NEVER let one repeat the other:

| Section | Form | Shows |
| --- | --- | --- |
| `## Class Diagram` | `class` | The story-relevant entities, tables, value objects and components, and their relations. Each concept appears ONCE, in its DB representation. NEVER show both a table and its TypeScript interface for the same concept. Mark `((NEW))`, `((CHANGED))` and `((DELETED))` only for real persisted schema changes. An unchanged field appears only when the story needs it. The story changes no schema → show the structural relations anyway, never `None` |
| `## Sequence Diagram` | `sequence` | The story's runtime interactions ACROSS tech boundaries. Participants make the runtime and deployment boundaries obvious first: apps, API surfaces, workers, Lambdas, queues, databases, AWS services, third-party systems. Group participants by boundary. Arrow labels name the boundary-crossing contract: an HTTP route, a webhook, a queue publish or consume, an event, an SDK call, a SQL operation. Happy path first, then the `alt` and `opt` blocks for errors. NEVER let it collapse into an internal function-call trace |

`architecture.md` already holds the epic's diagrams. These two cover THIS story only.

## Step 7: Define the happy path automated tests

Describe the story's expected results as test lines. This is how the user and the implementer agree what the system does, before any code exists.

1. Dispatch one subagent. Pass it only the design text it needs, the acceptance criteria, and the repo's own testing conventions
1. Discover a project skill about testing per conventions.md, and embed its real text in that subagent's prompt
1. One spec line per acceptance criterion at minimum, in the repo's existing test format

Write `## Happy Path Automated Tests` now.

## Step 8: Review the agreed design on four axes

These four axes are **independent** — dispatch one `Agent` per axis, all in a single message.

1. Architecture and boundaries — coupling, dependency direction, ownership, patterns, smells
2. Contracts and data — endpoints, signatures, types, names, migrations, agreement between sections
3. Tests and verifiability — do the spec lines cover the outcome and the complex internals
4. Repo reality and reuse — every named path and symbol exists, conflicts with existing code, code to reuse

Give each axis the design text and the repo paths it needs, plus the project skills that match its subject, per conventions.md.

Each returns at most 5 findings, ordered by impact, as rows for `## Current Weaknesses & Risks` with its four columns. An axis edits nothing.

Then judge the findings yourself. Put the resolution of each one to the user when it changes the design, and move a resolved row to `## Decision Registry`.

Write `## Current Weaknesses & Risks` now.

## Step 9: Settle the assumption ledger

Per conventions.md's Assumptions rule.

1. Reprint every `verified` and `resolved` row `story-<story-number>.md` carries, under its original ID. NEVER renumber one, NEVER drop one by omission
1. Add a row under `STORY-<story-number>-<n>`, continuing that story's numbering, for every claim this design acts on without evidence
1. Step 2 and Step 8's fourth axis already reported what the codebase proves. Mark each new row `verified` or `invalidated`, citing the file, line or test
1. Put every row still `open` to the user, one at a time, with what it blocks and what changes if it is false
1. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`, in their words, with its impact
1. The user cannot settle a row → stop. That is a gate: report the row, what it blocks, and the decision needed. NEVER hand `/a-plan` an `open` row
1. An `invalidated` row already baked into `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` also goes to `## Upstream Findings`, per Step 10

Write `## Assumptions` now.

## Step 10: Record upstream findings

Designing the story against real code uncovers what `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` should eventually reflect: a boundary or contract the epic architecture states wrongly, a dependency that changes the story order, a durable domain name. NEVER write any of those three files from this command.

Append each finding to `story-<story-number>.md`'s `## Upstream Findings` section instead:
- the target doc: `epic.md`, `architecture.md`, or `<repo>/CONTEXT.md`
- the finding
- the suggested change

A story-order conflict is one of these findings, never a rewrite: target `epic.md`'s `## Story Order`, name the position this story must move to, and name the dependency that forces it.

Append only. NEVER edit a row `/a-story` already wrote, and NEVER touch another section of that file.

`/a-finish` applies whichever findings are still confirmed, once the story's last criterion lands.

## Step 11: Write `design-<story-number>.md`

Read `~/.claude/commands/a-templates/design.md` and follow it exactly. Its own frontmatter is not part of the document.

Write `$EPIC_DIR/design-<story-number>.md`.

Rules for the design artifact:
- omit a section the story genuinely has nothing for, except `## UX Definition`, `## UI Sketch` and `## Components`, which write `- None` explicitly when the story has no UI
- every speculation is marked `TODO`
- every path and symbol named is real, or is marked as planned by this design
- `## Decision Registry` is the ONLY place that holds how the design got here; every other section describes the agreed design alone
- accuracy here is paramount: `/a-plan` copies these contracts verbatim

## Step 12: Present to user

Summarize:
1. the design document path
2. the goal, in one sentence
3. the decisions that locked this run
4. the diagrams drawn, or the sections the agent called undiagrammable
5. what the four-axis review found, and what is still open in `## Current Weaknesses & Risks`
6. the assumption ledger: rows verified from code, rows the user resolved, rows invalidated
7. upstream findings appended to `story-<story-number>.md`
8. work still TODO in the design

Then stop. The next step is to finalize the design, not to plan the work and not to implement it. NEVER offer to proceed to `/a-plan`. The user says when the design is ready.

## Success Criteria

- [ ] `design-<story-number>.md` exists under `$EPIC_DIR`
- [ ] `story-<story-number>.md` was read, and its assumption ledger carried no `open` or `cascaded` row when this command started
- [ ] all required inputs and followed references were validated before design work continued
- [ ] every acceptance criterion in `story-<story-number>.md` is covered by the design
- [ ] every design decision was approved by the user before the next was proposed, or the user explicitly lifted the gate per conventions.md's Bulk approval rule
- [ ] `## Sequence Diagram` and `## Class Diagram` were authored by the `uml-diagram` agent and pasted verbatim, or omitted with a stated reason
- [ ] neither diagram repeats `architecture.md`'s epic-level diagrams
- [ ] UI stories carry `## UX Definition`, `## UI Sketch` and `## Components`; non-UI stories write `- None` in each
- [ ] the four-axis review ran, and its findings are rows in `## Current Weaknesses & Risks`
- [ ] every assumption this design coined is `verified`, `resolved`, or `invalidated`; none is left `open` or `cascaded`
- [ ] every inherited assumption row appears under its original ID
- [ ] any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` was appended to `story-<story-number>.md`'s `## Upstream Findings`, never applied directly
- [ ] no section of `story-<story-number>.md` other than `## Upstream Findings` changed
- [ ] every speculation in the document is marked `TODO`
- [ ] no implementation steps, task packets, waves, or model and effort tables appear in the document
- [ ] the user was asked to review, and no offer to proceed to `/a-plan` was made
- [ ] the story number is recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **`story-<story-number>.md` missing** — name `/a-story <story-number>` as the command that must run first, and stop
- **An assumption row is still `open` or `cascaded`** — print the row, and send the user to `/a-edit story <story-number> <guidance>`. NEVER settle it here
- **The story's criteria contradict `architecture.md`** — report the contradiction, append it to `## Upstream Findings`, and ask the user which one holds before designing against either
- **The `uml-diagram` agent returns no diagram** — omit that section, and record the agent's stated reason in one clause
- **No relevant code found** — say so explicitly, treat the area as greenfield, and still follow project-wide patterns
