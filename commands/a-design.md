---
description: Agree one story's design with the user - boundaries, contracts, UX, UI, diagrams, names
argument-hint: "[<story-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill, Bash(git rev-parse:*), Bash(git symbolic-ref:*), Bash(git branch:*), Bash(date:*)]
disable-model-invocation: true
---

# Story Design

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `~/.claude/commands/a-templates/design.md` | The template for the output document |
| **In** | `$EPIC_DIR/story-<story-number>.md` | The story: slug, numbered acceptance criteria, user context, UI references, settled assumptions, findings |
| **In** | `$EPIC_DIR/architecture.md` | The epic's architecture, its epic-level diagrams, and its terminology — a confirmed finding in `story-<story-number>.md`'s `## Findings` overrides it, per conventions `## Findings` |
| **In** | `$EPIC_DIR/epic.md` | Touched repos, epic-level UI references, and the domain concepts |
| **In** | `$EPIC_DIR/story-*.md` (every other story of the epic) | `## Findings` only, per conventions `## Findings` |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **In/Out** | `$EPIC_DIR/story-<story-number>.md` | Append to `## Findings` only. NEVER change any other section |
| **Out** | `$EPIC_DIR/design-<story-number>.md` | The agreed design: goal, UX, UI, components, file structure, reuse, contracts, diagrams, risks, decisions |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Skills

Global and plugin skills used in this command, per conventions `## Skills`: `ask-user-question` for every question asked to the user, `grill-me` in Step 3 and Step 8, `posthog-feature-flags` in Step 3 only when the story needs a rollout flag, `engineering:testing-strategy` in Step 7.

Discover and invoke repo and package skills per conventions `## Skills` lookup rule: file structure, reuse, test lines and contracts each draw on whichever matching skill exists. NEVER hard-code a repo skill's name.

The `diagrams` skill belongs to the `uml-diagram` agent, not to this command. NEVER read it here.

## Purpose

Agree ONE story's design with the user, then record it. This command should:
- agree boundaries, modules, classes, interactions, contracts and names
- define the story's UX, its UI, and the components that deliver them
- ground every path, symbol and pattern in the real codebase
- have the `uml-diagram` agent draw every diagram
- review the agreed design on four axes, and record what that review finds
- settle every assumption it coins, and inherit only what routes to this doc
- record any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` as a finding
- produce one design document that `/a-plan` turns into per-criterion plans

## Rules

- NEVER write implementation steps, work breakdowns, task packets, subagent instructions, model tables or effort tables; `/a-plan` owns all of those
- NEVER write application code, and NEVER create commits
- NEVER write files outside `$EPIC_DIR`, except the memory file, per conventions `## Path resolution`. This command never writes a repo's `CONTEXT.md`
- NEVER write `epic.md`, `architecture.md`, or a repo's `CONTEXT.md`; append the finding to `story-<story-number>.md`'s `## Findings` instead, per conventions `## Findings`
- NEVER edit any section of `story-<story-number>.md` except `## Findings`
- NEVER change a story number, in this file's name, in its heading, or in `epic.md`
- NEVER draw a diagram yourself; the `uml-diagram` agent is the only diagram author, see Step 6
- NEVER restate `architecture.md`'s epic-level diagrams; `design-<story-number>.md` is story altitude and shows only what this story changes
- NEVER start work with a required assumption still `open` or `cascaded` in `story-<story-number>.md`, per conventions `## Assumptions`; that is a gate, see Step 1
- NEVER design for an acceptance criterion the story does not carry, and NEVER design the next story
- NEVER define synonyms; if a term exists in a touched repo's `CONTEXT.md`, use its canonical name
- NEVER abbreviate new names
- NEVER propose extractions for hypothetical future use
- NEVER state a speculation as agreed; mark it `TODO` in the document
- NEVER store conversation history anywhere but `## Decision Registry`
- NEVER reprint a settled assumption row; cite it by ID, per conventions `## Assumptions`
- NEVER offer to proceed to implementation or to `/a-plan`; the user says when the design is ready
- The user can be wrong. Clarify and find the correct solution rather than following a mistaken instruction
- Asked to change an existing interface beyond this story's scope → explain the consequence and ask for confirmation first
- Interactions in chat stay brief and follow the active output style; express the design in the document, not in chat
- Write `design-<story-number>.md` per conventions `## Write as you go`: create it from the template on first write, Edit each section the moment it settles, and check it against the template only in the final step
- Set `status` to `done` only on the user's final "design is ready" approval, per conventions `## Document header`

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its `## Where a command runs` and, for a planning stage, its `## Selector resolution` order: argument, then memory, then ask.
1. `$ARGUMENTS` = `[<story-number>] [details]`. A leading integer is the story number; the rest is high-priority guidance for this run. `$ARGUMENTS` never carries an epic slug — the epic itself resolves per conventions (memory, then ask).
1. No story number in `$ARGUMENTS` → memory, then list the story numbers that have a `story-N.md` on disk and ask, using the ask-user-question skill, per conventions `## Skills`.
1. Record the resolved story number in memory, per conventions `## Memory`.

Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>.md`
- `$EPIC_DIR/architecture.md`
- `$EPIC_DIR/epic.md`
- `~/.claude/commands/a-templates/design.md`

Read `## Findings` only, in every other `story-*.md` under `$EPIC_DIR`, per conventions `## Findings`.

Follow all references from planning artifacts. Stop and report any unreadable reference.

When `story-<story-number>.md` or `epic.md` lists UI references, treat them as required input. Read and follow them before designing any UI.

Every confirmed finding read above overrides the text it corrects, per conventions `## Findings`. Design against the finding, never against the text it corrects.

`story-<story-number>.md` carries a row this story's implementation requires still `open` or `cascaded` → STOP, per conventions `## Assumptions`. Report the row and send the user to `/a-edit story <story-number> <guidance>`. A row this story's implementation does not require stays cascaded; it is not a gate here.

`design-<story-number>.md` already exists → read it. This run revises that document; NEVER start a second one, and NEVER discard an agreed decision without saying so. It has no header → it is legacy; this run's first write adds one, per conventions `## Document header`.

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

`design-<story-number>.md` does not exist → Write it now from `~/.claude/commands/a-templates/design.md`'s `## Shape`, per conventions `## Write as you go`: the header with `status: draft`, the title, and every H2 heading, empty otherwise.

## Step 2: Ground the design in the codebase

Scope the exploration with `architecture.md` and each touched repo's `README.md`, `CLAUDE.md`, `CONTRIBUTING.md` and `CONTEXT.md`.

These four axes are **independent** — dispatch one `Agent` with type `Explore` per axis, all in a single message so they run concurrently. Don't run them sequentially.

1. the code that must change to satisfy the story's acceptance criteria, with exact paths and symbols
2. the patterns, boundaries and dependency direction this story must follow
3. reuse: existing components, services, types, utilities and tests this story can use instead of writing
4. the contracts the story touches: current signatures, routes, types, schema and migrations

Each result reports paths, symbols, why they matter, and any conflict with `architecture.md` or a repo's `CONTEXT.md`.

NEVER accept a result without a file and a symbol behind it.

Discover and invoke a repo or package skill about file structure, reuse or contracts per conventions `## Skills`, in each touched repo.

Display the findings, then Edit `design-<story-number>.md`'s `## File Structure`, `## Architecture` and `### Reuse Opportunities` sections, per conventions `## Write as you go`. `### Extractions` holds decisions, not findings; it locks in Step 3.

## Step 3: Agree the design with the user

This is the command's core. Work the design out loud with the user, one decision at a time, and record what locks.

1. Use the grill-me skill to work each decision with the user until it reaches shared understanding, per Skills above
1. Propose the goal first: the problem and the solution, ELI5, one short paragraph each. Get it approved before anything else
1. Then propose each design decision in turn: a boundary, a module, a contract, a name, a data shape. Ask the user to approve or revise that decision before proposing the next, using the ask-user-question skill, per conventions `## Skills`
1. A decision that changes an earlier one → say what it supersedes, and update the earlier section
1. A contract decision (`## API Endpoints`, `## DB Migrations`) → discover and invoke a repo or package skill about that contract per conventions `## Skills` first
1. The user may lift the gate and ask for the rest in one pass, per conventions `## Bulk approval`. Print the whole batch together for one round of revision before it locks
1. Record every option considered, its trade-offs, and why the agreed one won, in `## Decision Registry`. A wording or naming back-and-forth is NOT a decision worth persisting; record it only when it changed the approach
1. The user decided with no stated reason → write `User decision.`, then your own reasoning, marked as yours
1. The story needs a rollout flag → invoke the posthog-feature-flags skill for that decision, per Skills above

Reuse the canonical terminology from `architecture.md` and each touched repo's `CONTEXT.md`. A genuinely new name goes in `## New Glossary` with an example value.

Edit `## Goal`, `## New Glossary`, `## Decision Registry`, `### Extractions` and the contract sections (`## API Endpoints`, `## DB Migrations`) as each one locks.

## Step 4: Define the UX

No UI in this story → write `- None` under `## UX Definition` and `## UI Sketch`, say so once, and go to Step 5.

Discover and invoke a project skill about UX per conventions `## Skills`, then define:
- the user flow, end to end
- the states, and the UI behaviour of each
- the feedback the user gets, including errors and empty states
- the accessibility requirements

Ground these in the followed UI references. NEVER invent UI behaviour that contradicts a referenced design artifact; surface the conflict instead.

Then draw the `## UI Sketch`: a compact ASCII layout showing the primary regions, key controls, important content and the main interaction affordances. Keep it implementation-oriented, and label it with the story's own terminology.

Edit `## UX Definition` and `## UI Sketch` now.

## Step 5: Define the components

No UI in this story → write `- None` under `## Components` and go to Step 6.

Define:
- the component inventory, each marked new or existing, with its location
- the component hierarchy
- the props and the state boundaries: what owns which state, and what is passed
- the styling approach and the responsive behaviour

Every existing component named here comes from Step 2's reuse axis, with a real path.

Edit `## Components` now.

## Step 6: Draw the diagrams

The `uml-diagram` agent is the only diagram author. NEVER draw one yourself, and NEVER edit what it returns. The `diagrams` skill belongs to that agent; this command never reads it, per Skills above.

1. Call `Agent` with `subagent_type: "uml-diagram"`, once per diagram section, every time the design changes what that section shows
1. The prompt carries these and nothing else:
   1. the mode: `design`, and the form: `sequence` or `class`
   1. the current design text the diagram depends on
   1. the repository paths of the existing code the design touches
1. Edit what the agent returns VERBATIM under its section heading, the moment it returns it. NEVER hold a diagram back for a later write
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
1. Embed the `engineering:testing-strategy` skill's text, plus any matching repo skill found per conventions `## Skills`, in that subagent's prompt
1. One spec line per acceptance criterion at minimum, in the repo's existing test format

Edit `## Happy Path Automated Tests` now.

## Step 8: Review the agreed design on four axes

These four axes are **independent** — dispatch one `Agent` per axis, all in a single message.

1. Architecture and boundaries — coupling, dependency direction, ownership, patterns, smells
2. Contracts and data — endpoints, signatures, types, names, migrations, agreement between sections
3. Tests and verifiability — do the spec lines cover the outcome and the complex internals
4. Repo reality and reuse — every named path and symbol exists, conflicts with existing code, code to reuse

Give each axis the design text and the repo paths it needs, plus the project skills that match its subject, per conventions `## Skills`.

Each returns at most 5 findings, ordered by impact, as rows for `## Current Weaknesses & Risks` with its four columns, capped per conventions `## Size caps`. An axis edits nothing.

Then judge the findings yourself. Use the grill-me skill to work each finding to resolution with the user, per Skills above. Put the resolution of each one to the user, using the ask-user-question skill, when it changes the design, and move a resolved row to `## Decision Registry`.

Edit `## Current Weaknesses & Risks` now.

## Step 9: Settle the assumption ledger

Per conventions `## Assumptions`.

1. Inherit only the rows routed to `design-<story-number>.md`, per conventions `## Assumptions`, and reprint each under its original ID. Cite every other settled row by ID; NEVER reprint it
1. Add a row under `A-STORY-<story-number>-<n>`, continuing that story's numbering, for every claim this design acts on without evidence
1. Step 2 and Step 8's fourth axis already reported what the codebase proves. Mark each new row `verified` or `invalidated`, citing the file, line or test
1. Put every row still `open` to the user, one at a time, with what it blocks and what changes if it is false, using the ask-user-question skill, per conventions `## Skills`
1. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`, in their words, with its impact
1. The user cannot settle a row → stop. That is a gate: report the row, what it blocks, and the decision needed. NEVER hand `/a-plan` an `open` row
1. An `invalidated` row already baked into `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` also goes to `## Findings`, per Step 10

Edit `## Assumptions` now.

## Step 10: Record findings

Designing the story against real code uncovers what `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` should eventually reflect: a boundary or contract the epic architecture states wrongly, a dependency that changes the story order, a durable domain name. NEVER write any of those three files from this command.

Append each finding to `story-<story-number>.md`'s `## Findings` section instead, per conventions `## Findings`, capped per conventions `## Size caps`: the target doc, the finding, the suggested change.

A story-order conflict is one of these findings, never a rewrite: target `epic.md`'s `## Story Order`, name the position this story must move to, and name the dependency that forces it.

Append only. NEVER edit a row `/a-story` already wrote, and NEVER touch another section of that file.

`/a-finish` applies whichever findings are still confirmed, once the story's last criterion lands.

## Step 11: Finalize `design-<story-number>.md`

Read `~/.claude/commands/a-templates/design.md`'s `## Shape` and check `design-<story-number>.md` against it. Edit in only the sections still missing; every other section was already written as it settled, per conventions `## Write as you go`.

Summarize for the user:
1. the design document path
2. the goal, in one sentence
3. the decisions that locked this run
4. the diagrams drawn, or the sections the agent called undiagrammable
5. what the four-axis review found, and what is still open in `## Current Weaknesses & Risks`
6. the assumption ledger: rows verified from code, rows the user resolved, rows invalidated
7. findings appended to `story-<story-number>.md`
8. work still TODO in the design

Then stop. The next step is to finalize the design, not to plan the work and not to implement it. NEVER offer to proceed to `/a-plan`. The user says when the design is ready.

The user's final "design is ready" approval → Edit the header's `status` line to `done`, per conventions `## Document header`. Any other response leaves `status` unchanged for the next revision.

## Success Criteria

- [ ] `design-<story-number>.md` was created from its template on the first write, then Edited section by section as each one settled, per conventions `## Write as you go`
- [ ] `story-<story-number>.md` was read, and no row this story's implementation requires was left `open` or `cascaded` when this command started, per conventions `## Assumptions`
- [ ] all required inputs and followed references were validated before design work continued, including `## Findings` in `story-<story-number>.md` and in every other `story-*.md` of the epic
- [ ] every acceptance criterion in `story-<story-number>.md` is covered by the design
- [ ] every design decision was approved by the user before the next was proposed, or the user explicitly lifted the gate per conventions `## Bulk approval`
- [ ] `## Sequence Diagram` and `## Class Diagram` were authored by the `uml-diagram` agent and pasted verbatim, or omitted with a stated reason
- [ ] neither diagram repeats `architecture.md`'s epic-level diagrams
- [ ] UI stories carry `## UX Definition`, `## UI Sketch` and `## Components`; non-UI stories write `- None` in each
- [ ] the four-axis review ran, and its findings are rows in `## Current Weaknesses & Risks`
- [ ] every assumption this design coined is `verified`, `resolved`, or `invalidated`; none is left `open` or `cascaded`
- [ ] every assumption row routed to this doc appears under its original ID; every other settled row is cited by ID, never reprinted
- [ ] any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` was appended to `story-<story-number>.md`'s `## Findings`, never applied directly
- [ ] no section of `story-<story-number>.md` other than `## Findings` changed
- [ ] every speculation in the document is marked `TODO`
- [ ] no implementation steps, task packets, waves, or model and effort tables appear in the document
- [ ] the user was asked to review, and no offer to proceed to `/a-plan` was made
- [ ] `status` was set to `done` only on the user's final "design is ready" approval
- [ ] the story number is recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **`story-<story-number>.md` missing** — name `/a-story <story-number>` as the command that must run first, and stop
- **A required assumption row is still `open` or `cascaded`, per conventions `## Assumptions`** — print the row, and send the user to `/a-edit story <story-number> <guidance>`. NEVER settle it here
- **The story's criteria contradict `architecture.md`, with no confirmed finding covering it yet** — report the contradiction, append it to `## Findings`, and ask the user which one holds before designing against either
- **The `uml-diagram` agent returns no diagram** — omit that section, and record the agent's stated reason in one clause
- **No relevant code found** — say so explicitly, treat the area as greenfield, and still follow project-wide patterns
