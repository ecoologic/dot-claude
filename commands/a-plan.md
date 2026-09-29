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
| **In** | `~/.claude/commands/a-templates/plan-procedure.md` | The per-criterion procedure. Passed to each planning subagent; the main session never follows it |
| **In** | `$EPIC_DIR/story-<story-number>.md` | The criteria verbatim, the story's assumption ledger, and its `## Findings` |
| **In** | `$EPIC_DIR/story-<story-number>-design.md` | The agreed design: contracts, file structure, components, reuse, migrations, test lines |
| **In** | `$EPIC_DIR/epic.md` | Touched repos and story dependencies |
| **In** | `$EPIC_DIR/story-<story-number>-ac-*.md` | The plans already on disk: resumed when `draft`, reviewed by the critic otherwise |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, `package.json`, `Makefile`, CI files, per touched repo | Repo conventions, naming baseline, and the verification commands |
| **In/Out** | `$EPIC_DIR/story-<story-number>.md` | Append to `## Findings` only. NEVER change any other section |
| **Out** | `$EPIC_DIR/story-<story-number>-ac-<criterion-number>.md`, one per criterion | The implementation plan for each acceptance criterion, and its criterion branch in the header |

## Skills

Read the repo and package skills the design's `> Skills:` line lists, per conventions `## Skills`. A skill about coding, APIs, testing, or the project's own stack applies to the procedure step it covers. Embed its real text in each subagent prompt that needs it.

## Purpose

Turn EVERY acceptance criterion of ONE story into an implementation plan a reader can execute without this conversation, then verify the plans as a set. This command should:
- plan each criterion in its own subagent, all in parallel, per `plan-procedure.md`
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
- Express the plans in the documents, not in chat

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<story-number>] [details]`. The first integer is the story number; the rest is high-priority guidance for this run, passed to every subagent.
1. No story number in `$ARGUMENTS` → resolve it per conventions `## Selector resolution`. Its ask lists the story numbers that have a `story-N-design.md` on disk.
1. Memory records `Criterion: none`, per conventions `## Memory`.

Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>.md`
- `$EPIC_DIR/story-<story-number>-design.md`
- `$EPIC_DIR/epic.md`
- `~/.claude/commands/a-templates/story-ac.md`
- every `$EPIC_DIR/story-<story-number>-ac-*.md` already on disk

Follow all references from planning artifacts. Stop and report any unreadable reference.

Check `story-<story-number>-design.md`'s ledger per conventions `### Entry gate`, with `/a-edit design <story-number> <guidance>`.

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
2. the absolute paths of `conventions.md`, `plan-procedure.md`, `story-ac.md`, `story-<story-number>.md`, `story-<story-number>-design.md`, and `epic.md`. NEVER pass this file
3. the touched repos, as `<dev-root>/<repo>` paths
4. the real text of every repo skill that matches, per conventions `## Skills`
5. this run's guidance
6. the instruction: read `plan-procedure.md` and follow it exactly

NEVER restate the procedure in the prompt. The subagent reads it, per conventions `## Single source of facts`.

Wait for every subagent. Collect each return, per `plan-procedure.md`'s `### Return`.

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
1. Settle every row per conventions `### Settle`. The planners already marked what the code settles. Its gate protects `/a-implement`

Append every finding the planners returned to `story-<story-number>.md`'s `## Findings`, per conventions `## Findings`, a story-order conflict included.

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

Present every plan together for one round of revision. This batch is the default here, not a lifted gate; the rest of conventions `## Bulk approval` still applies. Set `status: done` on each plan the user approves, per conventions `## Document header`. Then name the next commands: `/a-implement <story-number> <criterion-number>` for each ready criterion, one session each. Then stop. NEVER start the implementation, and NEVER offer to.

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
- [ ] every plan was written by its own subagent, all dispatched in one message; no prompt restated `plan-procedure.md`
- [ ] the critic ran after every planning round, with none of the planners' reasoning
- [ ] every design change went to `/a-edit design`; `story-<story-number>-design.md` did not change
- [ ] every contract in `## Contracts` is copied verbatim from the design; no name, signature or route was invented
- [ ] every verification row names its source file; a criterion whose _Then_ shows in a browser has a `browser` row
- [ ] every new assumption row got its ID from the main session, in sequence; none is left `open` or `cascaded` in a `done` plan
- [ ] any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` was appended to `story-<story-number>.md`'s `## Findings`, never applied directly
- [ ] no section of `story-<story-number>.md` other than `## Findings` changed
- [ ] the user was asked to review, and no offer to proceed to `/a-implement` was made

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **`story-<story-number>-design.md` missing** — name `/a-design <story-number>` as the command that must run first, and stop
- **An assumption row in `story-<story-number>-design.md` is still `open` or `cascaded`** — print the row, and send the user to `/a-edit design <story-number> <guidance>`. NEVER settle it here
- **The design does not carry a contract a criterion needs** — report exactly what is missing, and send the user to `/a-edit design <story-number> <guidance>`. NEVER invent it
- **A subagent fails or returns no plan** — report the criterion, keep the other plans, and name `/a-plan <story-number>` to resume it
