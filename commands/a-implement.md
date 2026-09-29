---
description: Implement one acceptance criterion from its approved plan, on its own branch and worktree, then commit
argument-hint: "[<story-number>] [<criterion-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, Agent, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Criterion Implementation

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `~/.claude/commands/wt.md` | How the criterion worktree is created, when none exists yet |
| **In/Out** | `$EPIC_DIR/story-<story-number>-ac-<criterion-number>.md` | The approved plan, the only planning doc this command reads. Read its `branch` header, `> Repos:` and `> Skills:` lines. Tick `## Steps`, add rows to `## Assumptions` and `## Findings`, set the header's `status` and `pr`. NEVER change any other section |
| **In** | `$EPIC_DIR/story-<story-number>-ac-*.md` | The parent plans' headers only: `status` and `branch` |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **Out** | the criterion worktree, per touched repo | Code changes, tests, and commits on the criterion branch |

## Skills

Read and invoke the repo skills the plan's `> Skills:` line lists, per conventions `## Skills`. A skill about coding, APIs, testing, or the project's own stack applies to the step it covers.

## Purpose

Implement ONE acceptance criterion exactly as its approved plan says, then commit it. This command should:
- find the criterion worktree, or create it on its base, per conventions `## Criterion branches`
- execute the plan's steps in order, in the main session
- dispatch subagents only for the steps the plan marks independent
- validate up the ladder, using only the plan's verification commands, the `browser` row last
- commit every working increment on the criterion branch
- settle every assumption it coins, and cite by ID the rows it inherits
- record any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` as a finding
- mark the plan `implemented`, with its PR number
- print the `/compact` instructions for the next stage

## Rules

- NEVER implement a different acceptance criterion than the one requested
- NEVER broaden scope into unrelated cleanup, opportunistic refactors, or another acceptance criterion
- NEVER start without an approved plan. The plan's header reads `status: done`, see Step 1
- NEVER change the plan's steps, files, contracts or scope here. A plan gap is a gate, see Step 3
- NEVER propose speculative abstractions or extractions for future use
- Follow conventions `## Workflow jargon` in every comment, copy line, commit message and committed text
- Run only the plan's `## Verification` rows, see Step 5
- NEVER create a second worktree for a criterion, see Step 2
- NEVER read or write `story-<story-number>.md` or `story-<story-number>-design.md`. The plan carries everything this command needs
- NEVER write `epic.md`, `epic-architecture.md`, `epic-progress.md`, or a repo's `CONTEXT.md`; append the finding to the plan's `## Findings` instead, per conventions `## Findings`
- NEVER apply a finding yourself; `/a-finish` applies them
- NEVER auto-chain into the next criterion, and NEVER offer to
- Prefer existing code patterns, file placement conventions, and interfaces over inventing new ones
- Implementation steps may be story-coherent rather than artificially isolated; if the criterion needs a full table, all story-relevant fields belong in scope
- Add or update tests when the repo already has a relevant testing pattern and the criterion changes behavior
- write `story-<story-number>-ac-<criterion-number>.md` as each step settles, per conventions `## Write as you go`

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<story-number>] [<criterion-number>] [details]`. The first integer is the story number, the second is the criterion number; the rest is high-priority guidance for this run.
1. No story number in `$ARGUMENTS` → resolve it per conventions `## Selector resolution`. Its ask lists the story numbers that have a `story-N-ac-M.md` on disk with `status: done`.
1. No criterion number in `$ARGUMENTS` → resolve the lowest ready criterion of that story, per conventions `## Criterion branches`. Report which one that resolved to before continuing.

Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>-ac-<criterion-number>.md`
- each parent plan named by an `AC <criterion-number>` line of its `### Dependencies`: its header only

Gates, before any code changes:
1. The plan's header `status` starts with `implemented` → report the plan's `branch` and `pr`, and stop. This criterion is done
1. The plan's header reads anything but `status: done` → STOP. Send the user to `/a-plan <story-number>`
1. The plan carries a row in `## Assumptions` still `open` or `cascaded` → STOP. Report the row and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`
1. The plan's `branch` header is `-` or missing → STOP. Send the user to `/a-edit plan <story-number> <criterion-number> <details: set the branch header>`
1. A parent plan has no `status` starting with `implemented` → STOP. Report that parent, and name `/a-implement <story-number> <parent-criterion-number>` as the command that must run first

Output:
```text
Plan: <the plan's # title>
Parents: <criterion numbers, or none>
Branch: <branch>
Epic dir: <EPIC_DIR>
Repos: <the plan's > Repos: line>
Plan: approved, <step count> steps, <independent count> independent
```

## Step 2: Enter the criterion worktree

Find each criterion worktree per conventions `### Criterion worktree lookup`. No entry → create it:
1. No local `<branch>` → resolve the base per conventions `## Criterion branches`. Run `git -C <dev-root>/<repo> fetch origin <default-branch>`, then `git -C <dev-root>/<repo> branch <branch> <base>`
1. Then create the worktree, per that lookup's create rule

From here on, every Read, Edit and Write uses an absolute path inside the worktree. Every Bash command runs with the worktree as its working directory.

Report each worktree path, its base, and whether this run created it.

## Step 3: Reconcile the plan against the worktree

The plan was written against the main repo. Check that it still holds in the worktree, where the parent criteria, merged to the default branch or stacked below this one, already landed.

1. A path the plan marks `edit` does not exist → create it only if the repo's conventions confirm the path is correct; otherwise follow the nearest valid convention, and record it as an assumption row in Step 7
1. A path the plan marks `create` already exists → read it. If part of the criterion is already implemented, reuse it and finish only the missing coverage
1. A contract in `## Contracts` no longer matches the code → STOP. Report the mismatch and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`
1. The plan misses a file or a step the criterion needs → STOP, and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`. NEVER silently plan around it

## Step 4: Execute the steps

Read the skills the plan's `> Skills:` line lists, per conventions `## Skills`, before the first code change.

1. Execute the plan's `## Steps` in order, in the main session
1. Consecutive steps marked `**Independent**: yes` run in subagents, all dispatched in one message, with `model: sonnet`. Every other step runs in the main session
1. Each subagent prompt carries the step verbatim, the contracts it implements from `## Contracts`, the absolute worktree path, the matching skill text, and the plan's `## Out Of Scope` list
1. Modify only the files the step names, plus minimal supporting files (tests, wiring)
1. Preserve existing working behavior outside scope
1. Write every comment per conventions `## Workflow jargon`
1. A step finishes → tick its checkbox in the plan's `## Steps` now, with one Edit, and refresh the header's `updated`

Git rules for subagents:
1. The main session owns git. It runs every `git` command, single-threaded, after the independent steps join
1. A subagent NEVER calls `git`. Put `NEVER run any git command` in the out-of-scope list of EVERY subagent prompt
1. A subagent writes its owned files, then reports the exact paths it wrote. Nothing else
1. NEVER tell a subagent to commit, stage, stash, branch, pull or push
1. Parallel subagents share one `.git/index`. Two concurrent `git add` calls give `fatal: Unable to create '.git/index.lock'`, and one subagent's `git add -A` stages another's half-written files

## Step 5: Validate

Validate per conventions `## Validation`. Its summary step is Step 10.

A failure is in scope → fix, rerun, repeat.

On merge conflicts, continue only if the criterion's scope remains intact. Otherwise stop and report.

## Step 6: Commit

1. Commit in each touched worktree, on the criterion branch only
1. Every commit is a working increment, per conventions.md's Vertical slicing rule. NEVER commit a half-wired criterion
1. Commit per conventions `### Committing in a criterion worktree`
1. Stage every file this run wrote: the plan's files, plus each supporting or corrected path recorded in Step 7

## Step 7: Settle the assumption ledger

Per conventions `## Assumptions`.

1. Cite by ID every plan row this implementation depends on. NEVER renumber one, NEVER drop one by omission
1. Add a row under `A-AC-<story-number>-<criterion-number>-<n>`, continuing this plan's own numbering, for every claim this run acted on without evidence: a created path, a followed convention, a reused partial implementation
1. Settle every row per conventions `### Settle`. Its evidence is the worktree's files, tests and commits. A finding goes in Step 8

Write the plan's `## Assumptions` rows now.

## Step 8: Record findings

Implementing the criterion against real code uncovers what `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` should eventually reflect. NEVER write any of those three files from this command.

Append each finding to the plan's `## Findings` section instead, per conventions `## Findings`. NEVER touch another section of the plan in this step.

## Step 9: Mark the plan implemented

Only when every step is ticked, validation passed per Step 5, and every touched worktree has its commit and a clean `git status --porcelain`. Otherwise leave `status: done`, and report the gate in Step 10.

Per conventions `## Document header`, one Edit per key of the plan's header:
1. `pr` → per touched repo, the open PR for the criterion branch, from `gh pr list --head <branch> --state open --json number` run in its worktree: `<repo>#<number>`, comma-separated. No open PR → `none`
1. `status` → `implemented`
1. `updated` → now

`/a-cont` reads this header to tick the criterion's `a-implement` row. NEVER write `epic-progress.md` here.

## Step 10: Present to user

Summarize:
1. files changed, per worktree
2. the criterion covered, in one sentence
3. the `browser` result first, with the GIF path, or why it did not run. Then the validation result, per `## Verification` row, and every rung skipped
4. the commits, as `<repo> <7-char sha> <subject>`
5. the plan's header: `status`, `branch`, `pr`, and the base per worktree
6. the assumption ledger: rows verified, rows the user resolved, rows invalidated
7. findings appended to the plan
8. blockers or risks
9. whether another criterion is unblocked

Then print the `/compact` instructions, as one fenced block the user pastes after `/compact`:

```text
Keep: epic slug, story <story-number>, criterion <criterion-number>, branch <branch>, worktree paths, files changed, commits, verification commands, blockers.
Drop: diff content, test output, exploration, subagent reports.
```

Then name the next command: `/a-check <story-number> <criterion-number>`, once the user has verified the criterion. Then stop. NEVER start the next criterion, and NEVER offer to.

## Success Criteria

- [ ] the plan's header read `status: done` when this command started, and its `## Assumptions` carried no `open` or `cascaded` row
- [ ] exactly one acceptance criterion is implemented: the one requested
- [ ] one worktree per touched repo holds the criterion branch, created on its base per conventions `## Criterion branches`; none was created when one existed
- [ ] the steps ran in order; only steps marked independent ran in subagents, dispatched in one message
- [ ] no subagent ran a `git` command
- [ ] validation followed conventions `## Validation`, with the `browser` row, when present, last in Chrome
- [ ] every commit is a working increment on the criterion branch, per conventions `### Committing in a criterion worktree`; nothing was pushed, and no hook was skipped
- [ ] no code, comment, copy or commit message breaks conventions `## Workflow jargon`
- [ ] only the plan's `## Steps` ticks, `## Assumptions` and `## Findings` rows and header changed in `story-<story-number>-ac-<criterion-number>.md`; no other planning doc changed
- [ ] every assumption this run coined is `verified`, `resolved`, or `invalidated`; none is left `open` or `cascaded`
- [ ] any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` was appended to the plan's `## Findings`, never applied directly
- [ ] `status: implemented` is set only after every step ticked, validation passed, and every commit landed, with `pr` set
- [ ] `epic-progress.md` did not change
- [ ] the `/compact` instructions were printed, and no offer to start the next criterion was made

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **`story-<story-number>-ac-<criterion-number>.md` missing** — name `/a-plan <story-number>` as the command that must run first, and stop
- **The plan is not `status: done`** — print its status, name `/a-plan <story-number>`, and stop
- **An assumption row in the plan is still `open` or `cascaded`** — print the row, and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`. NEVER settle it here
- **The plan does not match the worktree** — report exactly what differs, and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`. NEVER invent a step
- **A worktree has uncommitted changes** — print `git status --porcelain`, and stop. NEVER stash, reset or discard
- **The base does not resolve, or `git branch` fails** — report the command and its output, and stop
- **`/wt` fails or the user declines its confirmation** — report the step `wt.md` stopped at, and stop
- **An in-scope failure stays red after fixing** — leave `status: done`, report the command and its output, and stop
- **`gh` is missing or unauthenticated** — set `pr: none`, and report it as a risk
