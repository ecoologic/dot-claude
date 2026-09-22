---
description: Break a story into user-approved acceptance criteria grounded in the codebase
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
| **Out** | `$EPIC_DIR/story-<story-number>.md` | The story: slug, user context, numbered acceptance criteria, UI references, settled assumptions, and upstream findings for `/a-design` and, eventually, `/a-finish` |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. A skill applies here only when it helps phrase or scope an acceptance criterion; the technical skills belong to `/a-design`.

## Purpose

Break one story into user-approved, code-informed acceptance criteria. This command owns WHAT the story delivers; `/a-design` owns HOW.

This command should:
- draft and refine acceptance criteria with the user before locking them into the story artifact
- investigate the codebase far enough to prove each criterion is achievable and correctly named
- record any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` as an upstream finding, for `/a-finish` to apply later
- settle every assumption it inherits or coins, by codebase evidence or by the user, before `/a-design`
- produce a single story artifact with a stable slug and numbered acceptance criteria for `/a-design`

## Rules

- NEVER write or modify application code, create commits, or write files outside `$EPIC_DIR`
- NEVER design the solution here. Components, contracts, file structure, reuse, extractions, UX, UI and diagrams all belong to `/a-design`
- NEVER write `epic.md`, `architecture.md`, or a repo's `CONTEXT.md`; record the finding in `story-<story-number>.md`'s `## Upstream Findings` instead, per conventions.md's Upstream findings rule
- NEVER change a story number, in this file's name, in its heading, or in `epic.md`; an order conflict is recorded as an upstream finding against `epic.md`'s `## Story Order`, never applied here
- NEVER skip codebase investigation; a criterion must be grounded in the real codebase
- NEVER finish this command with an assumption still `open` or `cascaded`; `/a-design` inherits a settled ledger or this command gates
- NEVER state an unverified claim as settled fact in any section; record it as a row in `## Assumptions` and cite its ID where it matters
- NEVER define synonyms; if a term exists in a touched repo's `CONTEXT.md`, use its canonical name
- NEVER abbreviate new names
- NEVER write unnumbered acceptance criteria; later stages select a specific criterion by number
- NEVER finalize the acceptance-criteria list without explicit user approval for each criterion in order, unless the user lifted the gate per conventions.md's Bulk approval rule
- NEVER accept a criterion that names a technology layer (eg: "add the table", "add the endpoint", "add the form") instead of a user-observable outcome
- write and update `story-<story-number>.md` incrementally, per conventions.md's Incremental writes rule

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
6. the user may approve criterion `N` and ask for the rest in one pass (eg: "do the rest", "draft them all") — apply conventions.md's Bulk approval rule: draft every remaining criterion in one pass, still following the rules below, then print the whole batch together and let the user revise it before it locks. This lifts only the criterion-drafting gate; Steps 3 onward still run and still stop at their own checkpoints

While drafting:
- split overly broad source criteria into multiple numbered criteria when that improves implementation clarity
- merge duplicate or overlapping source criteria when the user agrees
- keep criteria implementation-relevant and testable, but do not turn them into tasks
- reject a criterion phrased as a technology layer; ask for a rephrase around the user-observable outcome before numbering it
- preserve canonical naming from each touched repo's `CONTEXT.md`

After the last criterion is approved, restate the full numbered list and treat it as the locked acceptance-criteria source for the rest of the command.

Once the list locks, write `story-<story-number>.md` now with its header, story statement, `## User Context`, `## Acceptance Criteria` and `## UI References` sections, per the shape in Step 6.

## Step 3: Ground the criteria in the codebase

Investigate only far enough to prove the locked criteria hold. `/a-design` does the deep technical exploration; this step does not record its findings in the story file.

Use `architecture.md` and each touched repo's `README.md`, `CLAUDE.md`, `CONTRIBUTING.md` and `CONTEXT.md` to scope the search.

The three axes below are **independent** — dispatch one `Agent` with type `Explore` per axis, all in a single message so they run concurrently. Don't run them sequentially.

1. feasibility: does the codebase support each criterion as worded, and does any criterion assume something that is not there
2. naming: does each criterion's terminology match each touched repo's `CONTEXT.md`, or does it conflict
3. evidence for or against every `open` and `cascaded` assumption this story inherits from `epic.md` and `architecture.md`, per conventions.md's Assumptions rule

Each result reports a verdict with a file, a line, or a test behind it. NEVER accept an opinion without one.

Use the results for three things only:
1. revise a criterion the codebase contradicts, with the user
2. settle an assumption row in Step 5
3. record an upstream finding in Step 4

Everything else the investigation turns up belongs to `/a-design`. NEVER record it here.

Display the findings before proceeding.

## Step 4: Record upstream findings

Investigation may uncover something `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` should eventually reflect: a story wording, boundary, sequencing, or dependency correction; an epic-specific detail other stories should inherit; a durable domain name, code name, source, or status. NEVER write any of those three files from this command.

Record each finding in `story-<story-number>.md`'s `## Upstream Findings` section instead:
- the target doc: `epic.md`, `architecture.md`, or `<repo>/CONTEXT.md`
- the finding
- the suggested change

A story-order conflict is one of these findings, never a rewrite: target `epic.md`'s `## Story Order`, name the position this story must move to, and name the dependency that forces it. NEVER renumber a story — the number is identity, and `story-N.md`, `design-N.md`, `plan-N-M.md`, the branch name, and the memory selector all key on it.

`/a-finish` reads this section once the story's last criterion lands and applies whichever findings are still confirmed.

Update `story-<story-number>.md`'s `## Upstream Findings` section now.

## Step 5: Settle the assumption ledger

`/a-design` NEVER starts with an unsettled assumption. This step is the deadline, per conventions.md's Assumptions rule.

1. Inherit every `open` and `cascaded` row from `epic.md` and `architecture.md` that this story touches, under its original ID. NEVER renumber one, NEVER drop one by omission
2. Add a row under `STORY-<story-number>-<n>` for every claim this run acted on without evidence
3. Step 3's third axis already reported what the codebase proves or disproves. Mark each row `verified` or `invalidated` now, citing the file, line, or test that settled it
4. Put every row still `open` to the user, one at a time, with what it blocks and what changes if it is false. NEVER batch them into one question, unless the user lifts the gate per conventions.md's Bulk approval rule
5. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`: record their decision in their words, and its impact. NEVER a silent pass
6. The user cannot settle a row → stop. That is a gate: report the row, what it blocks, and the decision needed. NEVER hand `/a-design` an `open` or `cascaded` row
7. An `invalidated` row already baked into `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` also goes to `## Upstream Findings`, per Step 4

Update `story-<story-number>.md`'s `## Assumptions` section now.

## Step 6: Write `story-<story-number>.md`

Derive `<story-slug>` as the kebab-case form of the title. `story-<story-number>.md` already exists → reuse its existing `Slug:` value instead of re-deriving it, so the slug survives a later title reword.

Write `$EPIC_DIR/story-<story-number>.md` with this structure:

This file is the single source of truth for WHAT the story delivers. It captures the slug, the story context, the UI references, the settled assumptions, the upstream findings, and the user-approved numbered acceptance criteria that `/a-design` reads next.

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

## UI References
- Story-relevant subset of the epic-level UI references, plus any story-local UI references followed during this run
- If none exist, write `- None`

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
- every criterion must be phrased as _Given_ / _When_ / _Then_, per conventions.md's Canonical blocks rule, so it stays testable without becoming a task
- every criterion must describe a user-observable outcome, never a technology layer
- the file carries no technical design. Components, contracts, file structure, reuse, extractions, UX, UI and diagrams all live in `design-<story-number>.md`
- `## Upstream Findings` lists every incongruity found against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md`, with no rows when none were found; NEVER apply one of those files' changes directly from this command
- `## Assumptions` carries every inherited and own assumption, each one `verified`, `resolved`, or `invalidated` by the time this command finishes; no row may stay `open` or `cascaded`

`/a-design` appends to `## Upstream Findings`. It NEVER edits any other section of this file.

## Step 7: Present to user

Summarize:
1. number of acceptance criteria
2. what the codebase investigation changed about them
3. upstream findings recorded, for `/a-finish` to apply
4. the assumption ledger: rows verified from code, rows the user resolved, rows invalidated, and the evidence behind each
5. risks and open questions

Ask the user to review the completed story artifact before moving to `/a-design`.

## Success Criteria

- [ ] `story-<story-number>.md` exists
- [ ] all required inputs and followed references were validated before story work continued
- [ ] `story-<story-number>.md` carries a `Slug:` header
- [ ] `story-<story-number>.md` contains numbered acceptance criteria, each phrased as _Given_ / _When_ / _Then_
- [ ] each acceptance criterion was explicitly approved by the user before the next criterion was drafted, or the user explicitly lifted the gate to bulk-draft the rest, per conventions.md's Bulk approval rule
- [ ] acceptance criteria cover the story's happy path plus important errors, failures, and security constraints
- [ ] every acceptance criterion describes a user-observable outcome, not a technology layer
- [ ] the criteria were checked against the real codebase, and every revision that check forced was approved by the user
- [ ] the file carries no technical design; no components, contracts, file structure, reuse, extractions, UX, UI or diagrams
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
- **A criterion the codebase contradicts** — report the contradiction with its file and line, and revise the criterion with the user before locking the list
