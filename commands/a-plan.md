---
description: Plan every acceptance criterion of one story, one subagent per criterion, then verify the set critically
argument-hint: "[<story-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash(git rev-parse:*), Bash(date:*), Bash(git symbolic-ref:*), Bash(git branch:*), Agent, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Story Plan

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `~/.claude/commands/a-templates/story-ac.md` | The template for every output document |
| **In** | `$EPIC_DIR/story-<story-number>.md` | The criteria verbatim, the story's assumption ledger, and its `## Findings` |
| **In** | `$EPIC_DIR/story-<story-number>-design.md` | The agreed design: contracts, file structure, components, reuse, migrations, test lines |
| **In** | `$EPIC_DIR/epic.md` | Touched repos and story dependencies |
| **In** | `$EPIC_DIR/story-<story-number>-ac-*.md` | The plans already on disk: resumed when `draft`, reviewed by the critic otherwise |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, `package.json`, `Makefile`, CI files, per touched repo | Repo conventions, naming baseline, and the verification commands |
| **In/Out** | `$EPIC_DIR/story-<story-number>.md` | Append to `## Findings` only. NEVER change any other section |
| **Out** | `$EPIC_DIR/story-<story-number>-ac-<criterion-number>.md`, one per criterion | The implementation plan for each acceptance criterion, and its criterion branch in the header |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Skills

Discover the repo and package skills per conventions `## Skills`. A skill about coding, APIs, testing, or the project's own stack applies to the procedure step it covers. Embed its real text in each subagent prompt that needs it.

## Purpose

Turn EVERY acceptance criterion of ONE story into an implementation plan a reader can execute without this conversation, then verify the plans as a set. This command should:
- plan each criterion in its own subagent, all in parallel, per `## Per-criterion procedure`
- give each plan its parent criteria, so independent criteria can ship in parallel, per conventions `## Criterion branches`
- run one critic over the whole set: overlaps, dependencies, and a better design, code reuse included, per `## Critic checks`
- route every design improvement through `/a-edit design`, never apply it here
- settle every assumption the plans coin, and cite by ID the rows they inherit
- record any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` as a finding

## Rules

- Plan the criteria of ONE story per run
- NEVER broaden scope into unrelated cleanup, opportunistic refactors, or another story
- NEVER change the design here. A design gap or a design improvement is a gate, see Step 4
- NEVER invent a contract, a name, a signature or a route the design does not carry
- NEVER phase a plan by layer, per conventions `## Vertical slicing`
- NEVER write application code, and NEVER create commits. `/a-implement` owns both
- NEVER write files outside `$EPIC_DIR`
- NEVER write `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md`; append the finding to `story-<story-number>.md`'s `## Findings` instead, per conventions `## Findings`
- NEVER edit any section of `story-<story-number>.md` except `## Findings`, and NEVER edit `story-<story-number>-design.md` at all
- NEVER apply a finding yourself; `/a-finish` applies them
- Only the main session asks the user, writes `story-<story-number>.md`, and assigns assumption IDs. A subagent does none of the three
- NEVER start the implementation, and NEVER offer to; the user runs `/a-implement` when the plans are right
- Prefer existing code patterns, file placement conventions and interfaces over inventing new ones
- Interactions in chat stay brief and follow the active output style; express the plans in the documents, not in chat

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<story-number>] [details]`. The first integer is the story number; the rest is high-priority guidance for this run, passed to every subagent. `$ARGUMENTS` never carries an epic slug — the epic itself resolves per conventions.md (branch, then memory, then ask).
1. No story number in `$ARGUMENTS` → fall through selector resolution: the current branch, then memory, then list the story numbers that have a `story-N-design.md` on disk and ask.
1. Record the resolved story number in memory, with criterion `none`.

Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>.md`
- `$EPIC_DIR/story-<story-number>-design.md`
- `$EPIC_DIR/epic.md`
- `~/.claude/commands/a-templates/story-ac.md`
- every `$EPIC_DIR/story-<story-number>-ac-*.md` already on disk

Follow all references from planning artifacts. Stop and report any unreadable reference.

`story-<story-number>-design.md` carries a row in `## Assumptions` still `open` or `cascaded` → STOP. `/a-design` is that ledger's deadline. Report the row and send the user to `/a-edit design <story-number> <guidance>`.

Sort every criterion in `story-<story-number>.md`'s `## Acceptance Criteria`:

| Plan on disk | Action |
| --- | --- |
| none | Plan it in Step 2 |
| `status: draft` | Resume it in Step 2 |
| `done`, or starting with `implemented` | Keep it. The critic reviews it in Step 3. Only `/a-edit plan` revises it |

No criterion to plan or resume → report each plan's `status`, name `/a-edit plan <story-number> <criterion-number> <guidance>` for a revision, and stop.

Output:
```text
Story: <story-number> — <title>
Epic dir: <EPIC_DIR>
Repos: <repo>, <repo>
Design: loaded
Criteria: <count>; to plan: <list>; to resume: <list>; kept: <list or none>
```

## Step 2: Plan each criterion

Send one `Agent` per criterion to plan or resume, all in ONE message, with `model: sonnet`. Each prompt carries only:
1. the criterion number, and whether it plans or resumes
2. the absolute paths of `conventions.md`, `story-ac.md`, `story-<story-number>.md`, `story-<story-number>-design.md`, `epic.md`, and this file
3. the touched repos, as `<dev-root>/<repo>` paths
4. the real text of every repo skill that matches, per conventions `## Skills`
5. this run's guidance
6. the instruction: read this file's `## Per-criterion procedure` and follow it exactly

NEVER restate the procedure in the prompt. The subagent reads it, per conventions `## Single source of facts`.

Wait for every subagent. Collect each return, per the procedure's `### Return`.

## Step 3: Verify the set

Send ONE fresh `Agent`, `model: opus`: the critic. It gets the absolute paths of `story-<story-number>.md`, `story-<story-number>-design.md`, every `story-<story-number>-ac-*.md`, and the touched repos, plus the matching repo skill text. It gets none of the planners' returns or reasoning.

It follows `## Critic checks`, and returns proposals only. It edits nothing.

## Step 4: Resolve with the user

Put each item to the user, one at a time, per the `ask-user-question` skill: every critic proposal, then every design gap and open question the planners returned. Route each accepted item:

| Kind | Route |
| --- | --- |
| Plan fix | Re-run that criterion's subagent, per Step 2, with the accepted change as guidance |
| Design change, or design gap | Record it; the run stops at Step 5 |
| Story change: a cycle, or criteria to split or merge | Append a finding to `story-<story-number>.md`'s `## Findings`, targeting `story-<story-number>.md`; the run stops at Step 5 |
| Rejected | Nothing. Report it in Step 6 |

After any plan fix, run Step 3 again. Stop the loop when a critic round returns no proposal the user accepts.

## Step 5: Settle the ledger and the findings

Per conventions `## Assumptions`:
1. Number every new row the planners returned, one at a time, as `A-STORY-<story-number>-<n>`. Continue the highest number in `story-<story-number>.md`, `story-<story-number>-design.md` and every `story-<story-number>-ac-*.md`. NEVER renumber a row
1. Edit each row into its own plan's `## Assumptions`
1. Put every row still `open` to the user, one at a time, with what it blocks and what changes if it is false
1. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`, in their words, with its impact
1. The user cannot settle a row → that is a gate: report the row, what it blocks, and the decision needed. NEVER hand `/a-implement` an `open` row

Append every finding the planners returned to `story-<story-number>.md`'s `## Findings`: the target doc, the finding, the suggested change. A story-order conflict targets `epic.md`'s `## Story Order`, names the position this story must move to, and names the dependency that forces it. Append only. NEVER edit a row an earlier stage wrote.

A design change or a story change recorded in Step 4 → STOP now. Every plan stays `draft`. Print, in order:
1. `/a-edit design <story-number> <guidance>`, or `/a-edit story <story-number> <guidance>`
1. `/a-edit plan <story-number> <criterion-number> <guidance>`, once per affected criterion

## Step 6: Present to user

Summarize, per plan:

| Criterion | Plan | Parents | Files (create / edit) | Steps (independent) | Verification rows | `browser` row |
| --- | --- | --- | --- | --- | --- | --- |

Then:
1. the criteria ready to start in parallel: no parent, or every parent kept as `implemented`
1. the critic proposals accepted, and the ones rejected
1. the assumption ledger: rows verified from code, rows the user resolved, rows invalidated
1. findings appended to `story-<story-number>.md`
1. verification checks with no command found, as risks
1. anything the design left `TODO` that a criterion needs

Present every plan for one round of revision, per conventions `## Bulk approval`. Set `status: done` on each plan the user approves, per conventions `## Document header`. Then name the next commands: `/a-implement <story-number> <criterion-number>` for each ready criterion, one session each. Then stop. NEVER start the implementation, and NEVER offer to.

## Per-criterion procedure

A planning subagent follows this section for ONE criterion. It has no access to the main conversation. It NEVER asks the user, NEVER writes `story-<story-number>.md`, and NEVER assigns an assumption ID. It writes only `story-<story-number>-ac-<criterion-number>.md`, per conventions `## Write as you go`.

### P1: Start the plan

1. Read conventions.md, `story-ac.md`, `story-<story-number>.md`, `story-<story-number>-design.md` and `epic.md`
1. Extract the criterion from `story-<story-number>.md`'s `## Acceptance Criteria`, verbatim
1. No plan on disk → create `story-<story-number>-ac-<criterion-number>.md` from the template with `status: draft`
1. The plan's `branch` header is `-` or missing → set it now, per conventions `## Criterion branches`, with an AC slug per conventions `## Selector resolution`. A set `branch` NEVER changes

### P2: Reconcile the criterion against the codebase

The design already explored the story. This step checks only what this criterion touches: search around the criterion's own area, never the whole repo.

Read `story-<story-number>.md`'s `## Findings` and factor every confirmed finding into the plan. NEVER apply one upstream.

Resolve these before any step is written:
1. Which files will actually change
1. Whether supporting tests are required
1. Whether planned paths need adjustment to match real repo conventions
1. Which criteria of this story must land first: each is a parent. A parent may carry a higher number than this criterion

Then resolve the other dependencies. A dependency on another story is verified in the codebase.

1. The criterion conflicts with the codebase or the design in a way that changes scope → return it as a design gap
1. The criterion is underspecified but safely completable → return the interpretation as an assumption row, and keep the plan minimal
1. A dependency the codebase cannot verify → return it as a question

Write `## Criterion` now, with its `### Outcome` and `### Dependencies` subsections. Each parent is an `AC <criterion-number>` line, per the template.

### P3: List the files

One row per file, with its exact path, marked `create` or `edit`, and one clause on what changes in it.

1. Every path comes from `story-<story-number>-design.md`'s `## File Structure`, reconciled with P2
1. A path the design names that this criterion does not touch stays out; it belongs to another criterion
1. The design's paths contradict the repo's real conventions → correct the path here, and return it as an assumption row
1. The design is wrong in a way that changes this criterion's scope → return it as a design gap. NEVER silently plan around it

Write `## Files` now.

### P4: Copy the contracts

Copy the exact signatures, types, names, routes, schema and migrations this criterion implements, VERBATIM from `story-<story-number>-design.md`.

1. Copy only the contracts this criterion touches
1. NEVER paraphrase one, NEVER rename one, NEVER complete a partial one
1. The criterion needs a contract the design does not carry → return exactly what is missing as a design gap
1. A contract the design marks `TODO` is still `TODO` here. It is a gap, not a licence to invent

Write `## Contracts` now.

### P5: Order the steps

Numbered, in execution order, each one a coherent slice of the criterion.

1. The plan delivers the criterion through every layer it touches, per conventions `## Vertical slicing`. NEVER phase it by layer
1. A step may be story-coherent rather than artificially isolated. A step needing a new type, validation or helper to satisfy the slice keeps it in the same step
1. Every step names its files, its type, what it does, and the contract from `## Contracts` it implements
1. Mark a step `independent` ONLY when it shares no file with any other step in this plan. Exactly one step owns each file
1. A step marked `independent` carries every path, name and signature it needs in its own description. It runs in a subagent with no access to this conversation
1. A shared file — an index, a route table, a migration list, a barrel export — is owned by ONE step, and that step is never `independent`
1. Split a step only when it is too big to execute in one pass, NEVER to create false parallelism

Write `## Steps` now.

### P6: Name the tests

The spec lines this criterion must make pass.

1. Take them from `story-<story-number>-design.md`'s `## Happy Path Automated Tests`, verbatim, and keep only the lines this criterion covers
1. Add the error, edge and security lines this criterion's _Given_ / _When_ / _Then_ names, in the repo's own test format
1. Name the test file each line lives in, marked `create` or `edit`, matching `## Files`
1. The repo has no testing pattern for this area → say so in one clause, and name the manual check instead

Write `## Tests` now.

### P7: Find the verification commands

Per repo this criterion touches, find the test, lint, type and build commands.

1. Read, in order: the repo's `CLAUDE.md` (root and package level), `CONTRIBUTING.md`, `README.md`, then `package.json` scripts, `Makefile`, and CI files. The first source that names a command for a check wins
1. Record each command exactly as its source writes it, with the result that counts as a pass, and the source file
1. No command found for a check → `- None` for it. Return it as a risk
1. The criterion's _Then_ shows in a browser → add the `browser` row last, per the template: the command that starts the app, found the same way, and `### Browser` with the URL and the _Given_ / _When_ / _Then_ as browser steps. Otherwise no `browser` row

Write `## Verification` now.

### P8: Bound the scope

The explicit NEVERs for this plan. Every plan carries at least these:

1. `NEVER implement another criterion of this story`, naming each one by number and title
1. `NEVER broaden scope into unrelated cleanup or an opportunistic refactor`
1. `NEVER run any git command from a step marked independent`
1. Anything the design, the story or this run's guidance explicitly rules out

Write `## Out Of Scope` now.

### P9: Draft the assumption rows

Per conventions `## Assumptions`.

1. Cite by ID every row `story-<story-number>-design.md` carries that this criterion depends on. NEVER renumber one, NEVER drop one by omission. Write those citations into `## Assumptions` now
1. Draft a row, with no ID, for every claim this plan acts on without evidence: a corrected path, an interpretation of an underspecified criterion, an unverified dependency, a guessed repo convention
1. P2 already checked the criterion's own area. Mark each drafted row `verified` or `invalidated`, citing the file, line or test. A row the code cannot settle stays `open`
1. An `invalidated` row already baked into `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` also becomes a finding

Return the drafted rows. NEVER write them into the plan.

### P10: Check the plan

Read `story-ac.md` and follow it exactly. Its command frontmatter is not part of the document; the header inside `## Shape` is. Check the doc against the template and Edit in only missing sections, per conventions `## Write as you go`.

Rules for the plan artifact:
- the reader has no access to this conversation, to the design document, or to the story. Every path, name and signature it needs is in the plan
- every path is real, or is marked `create`
- every contract is copied from the design, never restated in other words
- NEVER mention epic, story, acceptance criterion, AC, or any other workflow jargon in text the plan tells the implementer to write into code, comments or user-facing copy
- NEVER record how the plan got here. The design's `## Decision Registry` holds that
- NEVER write waves, task packets, subagent prompts, model tables or effort tables into the plan

### Return

```text
Criterion: <criterion-number>
Plan: <absolute path>
Parents: <AC numbers, or none>
Assumption rows: <one per line: claim | why it matters | status | evidence>
Design gaps: <one per line, or none>
Questions: <one per line, or none>
Findings: <one per line: target doc | finding | suggested change, or none>
Risks: <verification checks with no command, or none>
```

## Critic checks

The critic reads the design, every plan of the story, and the codebase around the planned files. The list is open: any other overlap, or any better design, is a proposal too.

| # | Check | Kind of proposal |
| --- | --- | --- |
| 1 | Two plans build the same code | Design change: one extraction, owned by one criterion |
| 2 | A plan builds code the repo already has | Design change: reuse it |
| 3 | Two plans own the same file | Plan fix: one owner; the other plan names it as a parent |
| 4 | One contract, two shapes across plans | Design change: one contract |
| 5 | A plan consumes what another plan produces, with no `AC <criterion-number>` line for it | Plan fix: add the parent, a later criterion included |
| 6 | The parents form a cycle | Story change: split or merge the criteria |
| 7 | Two `### Outcome` sections overlap in behaviour | Plan fix: one owner |
| 8 | A simpler contract, fewer layers, or fewer files would deliver the same criteria | Design change |
| 9 | Duplicated test lines across plans | Plan fix: one owner |
| 10 | A plan misses a `browser` row its _Then_ needs | Plan fix |

Each proposal returns: the check number, the affected criteria, the problem, the proposed change, and its kind. At most 60 words each, per conventions `## Size caps`.

## Success Criteria

- [ ] every criterion of the story has a `story-<story-number>-ac-<criterion-number>.md` under `$EPIC_DIR`
- [ ] each plan's `branch` header follows conventions `## Criterion branches`, set once and never changed
- [ ] each plan names every parent as an `AC <criterion-number>` line, and the parents form no cycle
- [ ] every plan was written by its own subagent, all dispatched in one message; no prompt restated `## Per-criterion procedure`
- [ ] the critic ran after every planning round, with none of the planners' reasoning
- [ ] every design change went to `/a-edit design`; `story-<story-number>-design.md` did not change
- [ ] every contract in `## Contracts` is copied verbatim from the design; no name, signature or route was invented
- [ ] every verification row names its source file; a criterion whose _Then_ shows in a browser has a `browser` row
- [ ] every new assumption row got its ID from the main session, in sequence; none is left `open` or `cascaded` in a `done` plan
- [ ] any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` was appended to `story-<story-number>.md`'s `## Findings`, never applied directly
- [ ] no section of `story-<story-number>.md` other than `## Findings` changed
- [ ] the user was asked to review, and no offer to proceed to `/a-implement` was made
- [ ] the story number is recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **`story-<story-number>-design.md` missing** — name `/a-design <story-number>` as the command that must run first, and stop
- **An assumption row in `story-<story-number>-design.md` is still `open` or `cascaded`** — print the row, and send the user to `/a-edit design <story-number> <guidance>`. NEVER settle it here
- **The design does not carry a contract a criterion needs** — report exactly what is missing, and send the user to `/a-edit design <story-number> <guidance>`. NEVER invent it
- **A subagent fails or returns no plan** — report the criterion, keep the other plans, and name `/a-plan <story-number>` to resume it
