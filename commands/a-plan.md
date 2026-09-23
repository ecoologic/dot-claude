---
description: Turn one acceptance criterion into an ordinary implementation plan grounded in the design
argument-hint: "[<story-number>] [<criterion-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Criterion Plan

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `~/.claude/commands/a-templates/plan.md` | The template for the output document |
| **In** | `$EPIC_DIR/story-<story-number>.md` | The criterion verbatim, the story's assumption ledger, and its `## Upstream Findings` |
| **In** | `$EPIC_DIR/design-<story-number>.md` | The agreed design: contracts, file structure, components, reuse, migrations, test lines |
| **In** | `$EPIC_DIR/epic.md` | Touched repos and story dependencies |
| **In** | `$EPIC_DIR/plan-<story-number>-*.md` | The criteria of this story already planned, and the verification commands already recorded |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **In/Out** | `$EPIC_DIR/story-<story-number>.md` | Append to `## Upstream Findings` only. NEVER change any other section |
| **Out** | `$EPIC_DIR/plan-<story-number>-<criterion-number>.md` | The implementation plan for ONE acceptance criterion |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. A skill about coding, APIs, testing, or the project's own stack applies to the step it covers.

## Purpose

Turn ONE acceptance criterion into an implementation plan a reader can execute without this conversation. This command should:
- state the criterion verbatim and what must be true when it is done
- name the exact files it changes, each marked create or edit
- order the work into numbered steps that deliver the criterion through every layer it touches
- copy the contracts it implements verbatim from the design
- name the test lines the criterion must make pass, and the exact verification commands
- bound the scope, the next criterion included
- settle every assumption it coins, and reprint the ledger it inherits
- record any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` as an upstream finding

## Rules

- NEVER plan more than one acceptance criterion per run
- NEVER broaden scope into unrelated cleanup, opportunistic refactors, or the next acceptance criterion
- NEVER change the design here. A design gap is a gate, see Step 4
- NEVER invent a contract, a name, a signature or a route the design does not carry
- NEVER let a step float without the criterion as its parent
- NEVER split a step by technology layer alone when one coherent story-slice step would be clearer
- NEVER phase the plan by layer, per conventions.md's Vertical slicing rule
- NEVER detect a verification command. Ask once, record the answer, see Step 7
- NEVER write application code, and NEVER create commits. `/a-implement` owns both
- NEVER write files outside `$EPIC_DIR`
- NEVER write `epic.md`, `architecture.md`, or a repo's `CONTEXT.md`; append the finding to `story-<story-number>.md`'s `## Upstream Findings` instead, per conventions.md's Upstream findings rule
- NEVER edit any section of `story-<story-number>.md` except `## Upstream Findings`, and NEVER edit `design-<story-number>.md` at all
- NEVER apply an upstream finding yourself; `/a-finish` applies them
- NEVER write waves, task packets, subagent prompts, model tables or effort tables
- NEVER start the implementation, and NEVER offer to; the user runs `/a-implement` when the plan is right
- a step needing a new type, validation or helper to satisfy the slice keeps it in the same step, instead of splitting it into a separate pseudo-step
- Prefer existing code patterns, file placement conventions and interfaces over inventing new ones
- Interactions in chat stay brief and follow the active output style; express the plan in the document, not in chat
- write and update `plan-<story-number>-<criterion-number>.md` incrementally, per conventions.md's Incremental writes rule

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<story-number>] [<criterion-number>] [details]`. The first integer is the story number, the second is the criterion number; the rest is high-priority guidance for this run. `$ARGUMENTS` never carries an epic slug — the epic itself resolves per conventions.md (branch, then memory, then ask).
1. No story number in `$ARGUMENTS` → fall through selector resolution: the current branch, then memory, then list the story numbers that have a `design-N.md` on disk and ask.
1. No criterion number in `$ARGUMENTS` → resolve the lowest criterion in `story-<story-number>.md` with no `plan-<story-number>-<criterion-number>.md` on disk. Report which one that resolved to before continuing.
1. Record the resolved story number and criterion number in memory.

Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>.md`
- `$EPIC_DIR/design-<story-number>.md`
- `$EPIC_DIR/epic.md`
- `~/.claude/commands/a-templates/plan.md`
- every `$EPIC_DIR/plan-<story-number>-*.md` already on disk

Follow all references from planning artifacts. Stop and report any unreadable reference.

Extract the requested criterion from `story-<story-number>.md`'s `## Acceptance Criteria`, verbatim. The criterion number is not in the file → list the criterion numbers that are, and stop.

`design-<story-number>.md` carries a row in `## Assumptions` still `open` or `cascaded` → STOP. `/a-design` is that ledger's deadline. Report the row and send the user to `/a-edit design <story-number> <guidance>`.

`plan-<story-number>-<criterion-number>.md` already exists → read it. This run revises that document; NEVER start a second one.

Output:
```text
Story: <story-number> — <title>
Criterion: <criterion-number> of <count>
Slug: <story-slug>
Epic dir: <EPIC_DIR>
Repos: <repo>, <repo>
Design: loaded
Criteria already planned: <list or none>
Existing plan: <yes, revising | no, new>
```

## Step 2: Reconcile the criterion against the codebase

The design already explored the story. This step checks only what this criterion touches: search around the criterion's own area, never the whole repo.

Read `story-<story-number>.md`'s `## Upstream Findings` and factor every confirmed finding into the plan. NEVER apply one upstream — `/a-finish` does that.

Resolve these four before any step is written:
1. Which files will actually change
2. Whether supporting tests are required
3. Whether planned paths need adjustment to match real repo conventions
4. Whether the criterion can be completed without pulling in another criterion

Then resolve the criterion's dependencies. A dependency that is not `none` — an earlier criterion of this story, or another story — is verified in the codebase, or asked about, before work starts.

1. The criterion conflicts with the codebase or the design in a way that changes scope → stop and ask
1. The criterion is underspecified but safely completable → record the interpretation as an assumption row in Step 9, and keep the plan minimal
1. The criterion needs another criterion to land first → stop and report the dependency

Write `## Criterion` now, with its `### Outcome` and `### Dependencies` subsections.

## Step 3: List the files

One row per file, with its exact path, marked `create` or `edit`, and one clause on what changes in it.

1. Every path comes from `design-<story-number>.md`'s `## File Structure`, reconciled with Step 2
1. A path the design names that this criterion does not touch stays out; it belongs to another criterion
1. The design's paths contradict the repo's real conventions → correct the path here, and record it as an assumption row in Step 9
1. The design is wrong in a way that changes this criterion's scope → STOP, and send the user to `/a-edit design <story-number> <guidance>`. NEVER silently plan around it

Write `## Files` now.

## Step 4: Copy the contracts

Copy the exact signatures, types, names, routes, schema and migrations this criterion implements, VERBATIM from `design-<story-number>.md`.

1. Copy only the contracts this criterion touches
1. NEVER paraphrase one, NEVER rename one, NEVER complete a partial one
1. The criterion needs a contract the design does not carry → that is a design gap. STOP, report exactly what is missing, and send the user to `/a-edit design <story-number> <guidance>`
1. A contract the design marks `TODO` is still `TODO` here. It is a gate, not a licence to invent

Write `## Contracts` now.

## Step 5: Order the steps

Numbered, in execution order, each one a coherent slice of the criterion.

1. The plan delivers the criterion through every layer it touches, per conventions.md's Vertical slicing rule. NEVER phase it by layer
1. A step may be story-coherent rather than artificially isolated. A step needing a new type, validation or helper to satisfy the slice keeps it in the same step
1. Every step names its files, its type, what it does, and the contract from `## Contracts` it implements
1. Mark a step `independent` ONLY when it shares no file with any other step in this plan. Exactly one step owns each file
1. A step marked `independent` carries every path, name and signature it needs in its own description. It runs in a subagent with no access to this conversation
1. A shared file — an index, a route table, a migration list, a barrel export — is owned by ONE step, and that step is never `independent`
1. Split a step only when it is too big to execute in one pass, NEVER to create false parallelism

Write `## Steps` now.

## Step 6: Name the tests

The spec lines this criterion must make pass.

1. Take them from `design-<story-number>.md`'s `## Happy Path Automated Tests`, verbatim, and keep only the lines this criterion covers
1. Add the error, edge and security lines this criterion's _Given_ / _When_ / _Then_ names, in the repo's own test format
1. Name the test file each line lives in, marked `create` or `edit`, matching `## Files`
1. The repo has no testing pattern for this area → say so in one clause, and name the manual check instead

Write `## Tests` now.

## Step 7: Record the verification commands

NEVER detect a verification command, and NEVER infer one from a `package.json`, a `Makefile` or a CI file.

1. An earlier `plan-<story-number>-*.md` already records a command for this repo → reuse its rows verbatim
1. No command is recorded for a repo this criterion touches → ask the user ONCE, for that repo: the test command, the lint command, the type command, and the build command when one applies
1. Record each one exactly as the user gave it, with the result that counts as a pass
1. The user names no command for a check → record `- None` for it. NEVER substitute a guess

Write `## Verification` now.

## Step 8: Bound the scope

The explicit NEVERs for this plan. Every plan carries at least these:

1. `NEVER implement acceptance criterion <criterion-number + 1>`, naming it, and every later criterion of this story
1. `NEVER broaden scope into unrelated cleanup or an opportunistic refactor`
1. `NEVER run any git command from a step marked independent`
1. Anything the design, the story or this run's guidance explicitly rules out

Write `## Out Of Scope` now.

## Step 9: Settle the assumption ledger

Per conventions.md's Assumptions rule.

1. Reprint every row `design-<story-number>.md` carries that this criterion depends on, under its original ID. NEVER renumber one, NEVER drop one by omission
1. Add a row under `STORY-<story-number>-<n>`, continuing that story's numbering, for every claim this plan acts on without evidence: a corrected path, an interpretation of an underspecified criterion, an unverified dependency, a guessed repo convention
1. Step 2 already checked the criterion's own area. Mark each new row `verified` or `invalidated`, citing the file, line or test
1. Put every row still `open` to the user, one at a time, with what it blocks and what changes if it is false
1. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`, in their words, with its impact
1. The user cannot settle a row → stop. That is a gate: report the row, what it blocks, and the decision needed. NEVER hand `/a-implement` an `open` row
1. An `invalidated` row already baked into `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` also goes to `## Upstream Findings`, per Step 10

Write `## Assumptions` now.

## Step 10: Record upstream findings

Planning the criterion against real code uncovers what `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` should eventually reflect: a contract the epic architecture states wrongly, a dependency that changes the story order, a durable domain name. NEVER write any of those three files from this command.

Append each finding to `story-<story-number>.md`'s `## Upstream Findings` section instead:
- the target doc: `epic.md`, `architecture.md`, or `<repo>/CONTEXT.md`
- the finding
- the suggested change

A story-order conflict is one of these findings, never a rewrite: target `epic.md`'s `## Story Order`, name the position this story must move to, and name the dependency that forces it.

Append only. NEVER edit a row `/a-story` or `/a-design` already wrote, and NEVER touch another section of that file.

## Step 11: Write `plan-<story-number>-<criterion-number>.md`

Read `~/.claude/commands/a-templates/plan.md` and follow it exactly. Its own frontmatter is not part of the document.

Write `$EPIC_DIR/plan-<story-number>-<criterion-number>.md`.

Rules for the plan artifact:
- the reader has no access to this conversation, to the design document, or to the story. Every path, name and signature it needs is in the plan
- every path is real, or is marked `create`
- every contract is copied from the design, never restated in other words
- NEVER mention epic, story, acceptance criterion, AC, or any other workflow jargon in text the plan tells the implementer to write into code, comments or user-facing copy
- NEVER record how the plan got here. The design's `## Decision Registry` holds that

## Step 12: Present to user

Summarize:
1. the plan document path
2. the criterion, in one sentence
3. the files it creates and the files it edits, by count
4. the step count, and which steps are marked `independent`
5. the verification commands recorded, and which ones the user supplied this run
6. the assumption ledger: rows verified from code, rows the user resolved, rows invalidated
7. upstream findings appended to `story-<story-number>.md`
8. anything the design left `TODO` that this criterion needs

Then stop. NEVER start the implementation, and NEVER offer to. The user runs `/a-implement` when the plan is right.

## Success Criteria

- [ ] `plan-<story-number>-<criterion-number>.md` exists under `$EPIC_DIR`
- [ ] exactly one acceptance criterion is planned, and it appears verbatim in `## Criterion`
- [ ] `design-<story-number>.md` was read, and its assumption ledger carried no `open` or `cascaded` row when this command started
- [ ] `story-<story-number>.md`'s `## Upstream Findings` was read, and every confirmed finding is reflected in the steps; none was applied upstream
- [ ] every dependency that is not `none` was verified in the codebase or put to the user before the plan was written
- [ ] every file in `## Files` carries an exact path marked `create` or `edit`
- [ ] every contract in `## Contracts` is copied verbatim from the design; no name, signature or route was invented
- [ ] every step names its files and its parent criterion; no step is phased by technology layer alone
- [ ] a step marked `independent` shares no file with any other step, and is self-contained
- [ ] every verification command came from the user or from an earlier plan file; none was detected
- [ ] `## Out Of Scope` names the next criterion explicitly
- [ ] every assumption this plan coined is `verified`, `resolved`, or `invalidated`; none is left `open` or `cascaded`
- [ ] any incongruity against `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` was appended to `story-<story-number>.md`'s `## Upstream Findings`, never applied directly
- [ ] no section of `story-<story-number>.md` other than `## Upstream Findings` changed, and `design-<story-number>.md` did not change
- [ ] no waves, task packets, subagent prompts, model tables or effort tables appear in the document
- [ ] the user was asked to review, and no offer to proceed to `/a-implement` was made
- [ ] the story number and the criterion number are recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **`design-<story-number>.md` missing** — name `/a-design <story-number>` as the command that must run first, and stop
- **The criterion number is not in `story-<story-number>.md`** — list the criterion numbers that are, and stop
- **An assumption row in `design-<story-number>.md` is still `open` or `cascaded`** — print the row, and send the user to `/a-edit design <story-number> <guidance>`. NEVER settle it here
- **The design does not carry a contract this criterion needs** — report exactly what is missing, and send the user to `/a-edit design <story-number> <guidance>`. NEVER invent it
- **The criterion needs another criterion to land first** — report the dependency and the criterion number that must run first, and stop
- **The user names no verification command** — record `- None` for that check, and report it as a risk in the summary. NEVER substitute a detected command
