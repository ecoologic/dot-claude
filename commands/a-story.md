---
description: Break a story into user-approved acceptance criteria grounded in the codebase
argument-hint: "[<story-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill, Bash(git rev-parse:*), Bash(date:*), Bash(git symbolic-ref:*), Bash(git branch:*)]
disable-model-invocation: true
---

# Story Breakdown

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `$EPIC_DIR/epic.md` | Read by `a-templates/epic.md`'s exact headings: this story's title, `### User Context` and `### Dependencies`, plus `## Repos`, `## UI Design References` and the other epic-level sections. `a-epic` never writes acceptance criteria, so none are extracted here |
| **In** | `$EPIC_DIR/epic-architecture.md` | Epic-specific architecture from `/a-architecture`, and the assumptions it cascaded to this story |
| **In** | `$EPIC_DIR/epic-personas.md` | Personas from `/a-epic` |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **Out** | `$EPIC_DIR/story-<story-number>.md` | Written per `a-templates/story.md`: user context, numbered acceptance criteria, UI references, the assumption ledger, and findings for `/a-design` and, eventually, `/a-finish` |

## Skills

Discover and invoke skills per conventions `## Skills`. A skill applies here only when it helps phrase or scope an acceptance criterion; the technical skills belong to `/a-design`. Use the `ask-user-question` skill for every question this command asks.

## Purpose

Break one story into user-approved, code-informed acceptance criteria. This command owns WHAT the story delivers; `/a-design` owns HOW.

This command should:
- draft and refine acceptance criteria with the user before locking them into the story artifact
- investigate the codebase far enough to prove each criterion is achievable and correctly named
- record any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` as a finding, for `/a-finish` to apply later
- settle, or cascade onward, every assumption it inherits or coins, per conventions `## Assumptions`, before `/a-design`
- produce a single story artifact with numbered acceptance criteria for `/a-design`

## Rules

- NEVER write or modify application code, create commits, or write files outside `$EPIC_DIR`
- NEVER design the solution here. Components, contracts, file structure, reuse, extractions, UX, UI and diagrams all belong to `/a-design`
- NEVER write `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md`; record the finding in `story-<story-number>.md`'s `## Findings` instead, per conventions `## Findings`
- NEVER change a story number, in this file's name, in its heading, or in `epic.md`, per conventions `## Story numbers`; an order conflict is a finding against `epic.md`'s `## Story Order`, never applied here
- NEVER skip codebase investigation; a criterion must be grounded in the real codebase
- NEVER finish this command with a row still `open`; a row this story does not require is `cascaded` onward instead, per conventions `## Assumptions`
- NEVER state an unverified claim as settled fact in any section; record it as a row in `## Assumptions` and cite its ID where it matters
- NEVER define synonyms; if a term exists in a touched repo's `CONTEXT.md`, use its canonical name
- NEVER abbreviate new names
- NEVER write unnumbered acceptance criteria; later stages select a specific criterion by number
- NEVER finalize the acceptance-criteria list without explicit user approval for each criterion in order, unless the user lifted the gate per conventions `## Bulk approval`
- NEVER accept a criterion that names a technology layer (eg: "add the table", "add the endpoint", "add the form") instead of a user-observable outcome
- write and update `story-<story-number>.md` incrementally, per conventions `## Write as you go`; every Edit refreshes `updated`, per conventions `## Document header`
- keep every table cell, finding, and question to the user within conventions `## Size caps`

## Step 1: Resolve the story

1. Read `~/.claude/commands/a-templates/conventions.md`. This is a planning stage: follow `## Where a command runs`, and resolve the selector per `## Selector resolution`'s Planning stages row — this command's own argument, then memory, then ask; never the current branch.
1. `$ARGUMENTS` = `[<story-number>] [details]`. A leading integer is the story number; the rest is high-priority guidance for this run.
1. No story number in `$ARGUMENTS` → memory holds one for this epic and its `story-N.md` is neither `status: done` nor `status: finished` → use it. Otherwise compute the default: read `epic.md`'s `## Story Order` in its listed sequence, and take the first entry whose `story-N.md` is missing or neither `status: done` nor `status: finished`. Present that number to the user for confirmation, alongside the other available numbers, per the `ask-user-question` skill.
1. Record the resolved story number in memory now.

Read (stop if any are missing):
- `$EPIC_DIR/epic.md`
- `$EPIC_DIR/epic-architecture.md`
- `$EPIC_DIR/epic-personas.md`

Follow all references from planning artifacts. Stop and report any unreadable reference.

Read `epic.md` by `a-templates/epic.md`'s exact headings. Extract this story's section — `## Story <n>: <title>` with its `### User Context` and `### Dependencies` — and the epic-level sections that apply across stories: `## Repos`, `## UI Design References`, `## Domain Concepts`, `## Requirements`, `## UX Considerations`, `## References`. Extract no acceptance criteria; `a-epic` never writes them.

When `epic.md`'s `## UI Design References` is non-empty, treat those as required input. Read and follow them before working on any story with UI.

Output:
```text
Epic dir: <EPIC_DIR>
Story: <title>
Epic: <epic name>
Architecture: loaded
Personas: loaded
Epic-level context: loaded
Has UI: <yes | no>
UI references: <list or none>
```

`story-<story-number>.md` missing → create it now from `a-templates/story.md`'s `## Shape`: the header (`status: draft`), the title, the story statement, `## User Context` filled from `epic.md`, `## References`, and every other H2 heading present but empty, per conventions `## Write as you go`. Go to Step 2.

`story-<story-number>.md` exists and its `status` is `done` or `finished` → this command does not re-enter it; report that and stop.

`story-<story-number>.md` exists and its `status` is neither `done` nor `finished` (`draft`, `blocked`, or no header at all) → bring it current, then resume:
1. No header → add one now: `status: draft` and `updated` from `date`
2. `status: blocked` → Edit it back to `draft`
3. A heading still carrying the pre-rename findings name → Edit it to `## Findings`, keeping its existing rows
4. `## Acceptance Criteria` empty → go to Step 2, keeping any `## Findings` and `## Assumptions` rows already there; add to them, never duplicate one
5. `## Acceptance Criteria` holds at least one criterion → print them and ask the user, per the `ask-user-question` skill, whether to continue drafting at the next number (→ Step 3) or treat the list as already locked
6. List locked and a row in `## Assumptions` is still `open` → go to Step 4
7. Otherwise → go to Step 5

## Step 2: Ground the story in the codebase

Before investigating, inherit this story's routed assumption rows: the `open` and `cascaded` rows routed to `story-<story-number>.md`, per conventions `## Assumptions`' routing rule, reprinted under their original ID. NEVER drop a routed row by omission, NEVER inherit a row routed elsewhere, NEVER reprint a row already settled upstream — cite that one by ID instead, where it matters. Edit `## Assumptions` with these rows now.

Investigate only far enough to prove the story's canonical statement, user context and dependencies hold, and to settle what evidence can settle. `/a-design` does the deep technical exploration; this step does not record its findings for that purpose.

Use `epic-architecture.md` and each touched repo's `README.md`, `CLAUDE.md`, `CONTRIBUTING.md` and `CONTEXT.md` to scope the search. Also read `## Findings` in every other `story-N.md` in `$EPIC_DIR`, never its `-design` or `-ac` files, per conventions `## Findings`, since nothing has applied them upstream yet.

The three axes below are **independent** — dispatch one `Agent` with type `Explore` per axis, all in a single message so they run concurrently. Don't run them sequentially.

1. feasibility: does the codebase support the story's canonical statement and user context as worded, and does anything they assume not exist
2. naming: does the story's title, user context and dependencies match each touched repo's `CONTEXT.md`, or conflict
3. evidence for or against every row just inherited above

Each result reports a verdict with a file, a line, or a test behind it. NEVER accept an opinion without one.

Use the results for four things:
1. informing the acceptance criteria drafted next in Step 3, and revising one the codebase later contradicts, with the user
2. settling an inherited row: `verified` or `invalidated` when evidence allows; otherwise `open`, when this story's implementation requires it, or `cascaded`, when it does not, per conventions `## Assumptions`
3. recording a finding, per conventions `## Findings`, the moment it surfaces — including a story-order conflict, which targets `epic.md`'s `## Story Order` and names the dependency forcing the move, never a renumber
4. routing each `new` or `exists (extend with ...)` row of `epic-architecture.md`'s `## Terminology` that this story uses as a finding that targets that repo's `CONTEXT.md`, per conventions `## Terminology`. Skip a term another `story-N.md`'s `## Findings` already carries

Display the findings and the settled assumption rows before proceeding.

Edit `story-<story-number>.md`'s `## Findings` and `## Assumptions` sections now, per conventions `## Write as you go`. Add an `A-STORY-<story-number>-<n>` row for any new claim this step acts on without evidence.

## Step 3: Draft acceptance criteria with the user

Use the selected story's canonical statement from `epic.md`, its user context, dependencies, personas, Step 2's grounding, and any trailing guidance to propose the story's working acceptance criteria list.

Draft them interactively, using the `ask-user-question` skill for each question:
1. propose exactly one numbered acceptance criterion at a time, starting with `1`, phrased as _Given_ [precondition] / _When_ [action] / _Then_ [expected result]
2. ask the user to approve or revise that specific criterion before proposing the next one
3. if the user revises a criterion, fold the revision into the wording and confirm it before continuing
4. do not draft criterion `N + 1` until criterion `N` is explicitly approved, unless the user lifts the gate per conventions `## Bulk approval`
5. keep the numbering stable once a criterion is approved; if a later change forces renumbering, stop and get explicit user confirmation for the renumbered list
6. the user may lift the per-criterion gate per conventions `## Bulk approval`; drafting still stops at each later step's own checkpoint

While drafting:
- split overly broad source criteria into multiple numbered criteria when that improves implementation clarity
- merge duplicate or overlapping source criteria when the user agrees
- keep criteria implementation-relevant and testable, but do not turn them into tasks
- reject a criterion phrased as a technology layer; ask for a rephrase around the user-observable outcome before numbering it
- preserve canonical naming from each touched repo's `CONTEXT.md`
- a criterion resting on something Step 2 didn't check → a quick Grep or Read before it locks, using the same feasibility and naming checks as Step 2
- a criterion the codebase contradicts, in Step 2 or in this step's own check, is revised with the user now, citing the file and line

Edit `story-<story-number>.md`'s `## Acceptance Criteria` section with each criterion the moment the user approves it — the whole approved batch at once when the user lifted the per-criterion gate, per conventions `## Write as you go`. Add an `A-STORY-<story-number>-<n>` row for any new claim this step acts on without evidence.

After the last criterion is approved, restate the full numbered list and treat it as the locked acceptance-criteria source for the rest of the command. Edit `## UI References` now.

## Step 4: Settle the assumption ledger

Settle every row still `open`, per conventions `## Assumptions`; `/a-story` is their deadline, so none may reach `/a-design` `open`. A row this story does not require was already `cascaded` in Step 2 — never gated here.

1. Put every row still `open` to the user, one at a time, using the `ask-user-question` skill, with what it blocks and what changes if it is false. NEVER batch them into one question, unless the user lifts the gate per conventions `## Bulk approval`
2. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`: record their decision in their words, and its impact. NEVER a silent pass
3. The user cannot settle a row → set `status: blocked` in the header, per conventions `## Document header`, and stop. Report the row, what it blocks, and the decision needed
4. An `invalidated` row already baked into `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` is also a finding, per Step 2

Edit `story-<story-number>.md`'s `## Assumptions` section now.

## Step 5: Check, present, and approve

Compare `story-<story-number>.md` against `a-templates/story.md`'s `## Shape`. Edit in only the sections still missing or empty; NEVER rewrite a section already written.

Summarize:
1. number of acceptance criteria
2. what the codebase investigation changed about them
3. findings recorded, for `/a-finish` to apply
4. the assumption ledger: rows verified from code, rows the user resolved, rows invalidated, rows cascaded onward and to which doc, and the evidence behind each
5. risks and open questions

Ask the user to review the completed story artifact before moving to `/a-design`.

On approval, Edit the header's `status` to `done`, per conventions `## Document header`.

## Success Criteria

- [ ] `story-<story-number>.md` exists, built from `a-templates/story.md`'s `## Shape`
- [ ] all required inputs and followed references were validated before story work continued
- [ ] `story-<story-number>.md` contains numbered acceptance criteria, each phrased as _Given_ / _When_ / _Then_
- [ ] Step 1 extracted no acceptance criteria from `epic.md`
- [ ] each acceptance criterion was explicitly approved by the user before the next criterion was drafted, or the user explicitly lifted the gate to bulk-draft the rest, per conventions `## Bulk approval`
- [ ] acceptance criteria cover the story's happy path plus important errors, failures, and security constraints
- [ ] every acceptance criterion describes a user-observable outcome, not a technology layer
- [ ] the codebase grounding in Step 2 ran before criteria drafting, and every revision it forced was approved by the user
- [ ] the file carries no technical design; no components, contracts, file structure, reuse, extractions, UX, UI or diagrams
- [ ] story-relevant UI references were carried into `story-<story-number>.md`, or `- None` was written explicitly
- [ ] any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` found this run was recorded in `## Findings`, never applied directly
- [ ] any story-order conflict found this run was recorded as a finding against `epic.md`'s `## Story Order`; no story was renumbered
- [ ] every `open` and `cascaded` assumption routed to this story appears in `## Assumptions` under its original ID, and no row routed elsewhere was inherited
- [ ] every assumption the codebase could settle is `verified` or `invalidated`, with a file, line, or test cited
- [ ] every remaining `open` row was put to the user and is `resolved` in their words; none is left `open`. A row this story does not require was `cascaded` in Step 2 instead, per conventions `## Assumptions`
- [ ] the user reviewed the output before the pipeline advanced, and the header's `status` is `done`
- [ ] the story number is recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **Story not found in `epic.md`** — list available story numbers and ask the user to pick one
- **No relevant code found** — say so explicitly and treat the story as a greenfield area while still following project-wide patterns
- **A criterion the codebase contradicts** — report the contradiction with its file and line, and revise the criterion with the user before locking the list
- **An open assumption row the user cannot settle** — set `status: blocked` and stop, per Step 4
