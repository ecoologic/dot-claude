---
description: Implement one acceptance criterion from its approved plan, in the story worktree, then commit
argument-hint: "[<story-number>] [<criterion-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, Agent, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Criterion Implementation

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `~/.claude/commands/wt.md` | How the story worktree is created, when none exists yet |
| **In/Out** | `$EPIC_DIR/story-<story-number>-ac<criterion-number>.md` | The approved plan. Tick `## Steps`, add rows to `## Assumptions`, set the header's `status`, `branch` and `pr`. NEVER change any other section |
| **In/Out** | `$EPIC_DIR/story-<story-number>.md` | The `branch` header, and `## Findings`. Append to `## Findings` only. NEVER change any other section |
| **In** | `$EPIC_DIR/epic.md` | Touched repos |
| **In** | `<repo>/README.md`, `<repo>/CLAUDE.md` (root and package level), `<repo>/CONTRIBUTING.md`, `<repo>/CONTEXT.md`, per touched repo | Existing repo conventions and naming baseline |
| **Out** | the story worktree, per touched repo | Code changes, tests, and commits on the story branch |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. A skill about coding, APIs, testing, or the project's own stack applies to the step it covers.

## Purpose

Implement ONE acceptance criterion exactly as its approved plan says, then commit it. This command should:
- find the story worktree, or create it when this is the story's first criterion
- execute the plan's steps in order, in the main session
- dispatch subagents only for the steps the plan marks independent
- validate up the ladder, using only the plan's verification commands
- commit every working increment on the story branch
- settle every assumption it coins, and cite by ID the rows it inherits
- record any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` as a finding
- mark the plan `implemented`, with its branch and PR number
- print the `/compact` instructions for the next stage

## Rules

- NEVER implement a different acceptance criterion than the one requested
- NEVER broaden scope into unrelated cleanup, opportunistic refactors, or the next acceptance criterion
- NEVER start without an approved plan. The plan's header reads `status: done`, see Step 1
- NEVER change the plan's steps, files, contracts or scope here. A plan gap is a gate, see Step 3
- NEVER propose speculative abstractions or extractions for future use
- NEVER mention epic, story, acceptance criteria, AC, or similar workflow jargon in code comments, user-facing copy, or committed implementation text; use plain language that still makes sense later without process context
- NEVER introduce in comments or UI outdated history context that refers to implementation detail changes eg: The rename of a model
- NEVER detect a verification command. Run only the plan's `## Verification` rows, see Step 5
- NEVER create a second worktree for a story, see Step 2
- NEVER push, and NEVER pass `--no-verify`. The hooks run
- NEVER write `epic.md`, `epic-architecture.md`, `epic-progress.md`, or a repo's `CONTEXT.md`; append the finding to `story-<story-number>.md`'s `## Findings` instead, per conventions `## Findings`
- NEVER apply a finding yourself; `/a-finish` applies them
- NEVER auto-chain into the next criterion, and NEVER offer to
- Prefer existing code patterns, file placement conventions, and interfaces over inventing new ones
- Implementation steps may be story-coherent rather than artificially isolated; if the criterion needs a full table, all story-relevant fields belong in scope
- Add or update tests when the repo already has a relevant testing pattern and the criterion changes behavior
- Interactions in chat stay brief and follow the active output style
- write `story-<story-number>-ac<criterion-number>.md` as each step settles, per conventions `## Write as you go`

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<story-number>] [<criterion-number>] [details]`. The first integer is the story number, the second is the criterion number; the rest is high-priority guidance for this run. `$ARGUMENTS` never carries an epic slug — the epic itself resolves per conventions.md (branch, then memory, then ask).
1. No story number in `$ARGUMENTS` → fall through selector resolution: the current branch, then memory, then list the story numbers that have a `story-N-acM.md` on disk with `status: done`, and ask.
1. No criterion number in `$ARGUMENTS` → resolve the lowest criterion of that story whose `story-<story-number>-ac<criterion-number>.md` has `status: done`. Report which one that resolved to before continuing.
1. Record the resolved story number and criterion number in memory.

Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>-ac<criterion-number>.md`
- `$EPIC_DIR/story-<story-number>.md`: its header and its `## Findings` only
- `$EPIC_DIR/epic.md`: its `## Repos` only

Gates, before any code changes:
1. The plan's header `status` starts with `implemented` → report the plan's `branch` and `pr`, and stop. This criterion is done
1. The plan's header reads anything but `status: done` → STOP. Send the user to `/a-plan <story-number> <criterion-number>`
1. The plan carries a row in `## Assumptions` still `open` or `cascaded` → STOP. Report the row and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`
1. `story-<story-number>.md` has no `branch` header → STOP. Send the user to `/a-edit story <story-number> <details: set the branch header>`
1. The plan's `### Dependencies` names an earlier criterion whose `story-<story-number>-ac<n>.md` has no `status` starting with `implemented` → STOP. Report that criterion, and name `/a-implement <story-number> <n>` as the command that must run first

Output:
```text
Story: <story-number> — <title>
Criterion: <criterion-number> of <count>
Branch: <branch>
Epic dir: <EPIC_DIR>
Repos: <repo>, <repo>
Plan: approved, <step count> steps, <independent count> independent
```

## Step 2: Enter the story worktree

The repos this criterion touches are the ones the plan's `> Repos:` line and the Repo column of its `## Verification` name. Each resolves to `<dev-root>/<repo>`, the sibling of `$PLANNING_ROOT`, per conventions `## Folder layout`.

Once per touched repo:
1. Run `git -C <dev-root>/<repo> worktree list --porcelain`. A `branch refs/heads/<branch>` entry → its `worktree` line is the story worktree. Use it
1. No entry → read `~/.claude/commands/wt.md` and follow its text from `<dev-root>/<repo>`, with `<branch>` as its argument. Then run `./scripts/setup-worktree.sh` from the new worktree when it exists
1. Run `git -C <worktree> status --porcelain`. Uncommitted changes → STOP. Report them. NEVER stash, reset or discard them

From here on, every Read, Edit and Write uses an absolute path inside the worktree. Every Bash command runs with the worktree as its working directory.

Report each worktree path and whether this run created it.

## Step 3: Reconcile the plan against the worktree

The plan was written against the main repo. Check that it still holds in the worktree, where earlier criteria of this story already landed.

1. A path the plan marks `edit` does not exist → create it only if the repo's conventions confirm the path is correct; otherwise follow the nearest valid convention, and record it as an assumption row in Step 7
1. A path the plan marks `create` already exists → read it. If part of the criterion is already implemented, reuse it and finish only the missing coverage
1. A contract in `## Contracts` no longer matches the code → STOP. Report the mismatch and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`
1. The plan misses a file or a step the criterion needs → STOP, and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`. NEVER silently plan around it
1. Read `story-<story-number>.md`'s `## Findings`. A confirmed finding that changes this criterion's files, contracts or steps, and that the plan does not reflect → STOP, and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`

## Step 4: Execute the steps

Discover the repo and package skills per conventions `## Skills`, once per touched repo, before the first code change.

1. Execute the plan's `## Steps` in order, in the main session
1. Consecutive steps marked `**Independent**: yes` run in subagents, all dispatched in one message. Every other step runs in the main session
1. Each subagent prompt carries the step verbatim, the contracts it implements from `## Contracts`, the absolute worktree path, the matching skill text, and the plan's `## Out Of Scope` list
1. Modify only the files the step names, plus minimal supporting files (tests, wiring)
1. Preserve existing working behavior outside scope
1. Write only durable comments that describe behavior or business rules directly — never reference workflow artifacts
1. A step finishes → tick its checkbox in the plan's `## Steps` now, with one Edit, and refresh the header's `updated`

Git rules for subagents:
1. The main session owns git. It runs every `git` command, single-threaded, after the independent steps join
1. A subagent NEVER calls `git`. Put `NEVER run any git command` in the out-of-scope list of EVERY subagent prompt
1. A subagent writes its owned files, then reports the exact paths it wrote. Nothing else
1. NEVER tell a subagent to commit, stage, stash, branch, pull or push
1. Parallel subagents share one `.git/index`. Two concurrent `git add` calls give `fatal: Unable to create '.git/index.lock'`, and one subagent's `git add -A` stages another's half-written files

## Step 5: Validate

Run the plan's `## Verification` rows only, in this order:
1. Targeted tests for the changed module, component or endpoint
2. Targeted lint, format, or type checks
3. The full test suite

If a failure is in scope: fix, rerun, repeat. If a failure is pre-existing or unrelated: report the command and the failure, explain why it is out of scope, and do not block completion.

A rung has no `## Verification` row, or its row is `- None` → skip it, and report it as a risk in Step 10. NEVER substitute a detected command. No automated validation at all → state this, and review the code against the criterion's _Given_ / _When_ / _Then_ manually.

On merge conflicts, continue only if the criterion's scope remains intact. Otherwise stop and report.

## Step 6: Commit

1. Commit in each touched worktree, on the story branch only
1. Every commit is a working increment, per conventions.md's Vertical slicing rule. NEVER commit a half-wired criterion
1. Stage by exact path every file this run wrote: the plan's files, plus each supporting or corrected path recorded in Step 7. NEVER `git add -A`
1. After each commit, `git status --porcelain` in that worktree prints nothing. Anything left → commit it, or stop and report it
1. Follow the repo's own commit message convention, from its `CLAUDE.md` or `CONTRIBUTING.md`. The message follows the workflow-jargon rule above
1. A hook fails → fix the cause, then commit again. NEVER pass `--no-verify`
1. NEVER push

## Step 7: Settle the assumption ledger

Per conventions.md's Assumptions rule.

1. Cite by ID every plan row this implementation depends on. NEVER renumber one, NEVER drop one by omission
1. Add a row under `A-STORY-<story-number>-<n>`, continuing that story's numbering, for every claim this run acted on without evidence: a created path, a followed convention, a reused partial implementation
1. Mark each new row `verified` or `invalidated`, citing the file, line, test or commit
1. Put every row still `open` to the user, one at a time, with what it blocks and what changes if it is false
1. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`, in their words, with its impact
1. The user cannot settle a row → stop. That is a gate: report the row, what it blocks, and the decision needed
1. An `invalidated` row already baked into `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` also goes to `## Findings`, per Step 8

Write the plan's `## Assumptions` rows now.

## Step 8: Record findings

Implementing the criterion against real code uncovers what `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` should eventually reflect. NEVER write any of those three files from this command.

Append each finding to `story-<story-number>.md`'s `## Findings` section instead:
- the target doc: `epic.md`, `epic-architecture.md`, or `<repo>/CONTEXT.md`
- the finding
- the suggested change

Append only. NEVER edit a row an earlier stage already wrote, and NEVER touch another section of that file.

## Step 9: Mark the plan implemented

Only when every step is ticked, validation passed per Step 5, and every touched worktree has its commit and a clean `git status --porcelain`. Otherwise leave `status: done`, and report the gate in Step 10.

Per conventions `## Document header`, one Edit per key of the plan's header:
1. `branch` → the story branch
1. `pr` → per touched repo, the open PR for the branch, from `gh pr list --head <branch> --state open --json number` run in its worktree: `<repo>#<number>`, comma-separated. No open PR → `none`
1. `status` → `implemented`
1. `updated` → now

`/a-cont` reads this header to tick the criterion's `a-implement` row. NEVER write `epic-progress.md` here.

## Step 10: Present to user

Summarize:
1. files changed, per worktree
2. the criterion covered, in one sentence
3. the validation result, per `## Verification` row, and every rung skipped
4. the commits, as `<repo> <7-char sha> <subject>`
5. the plan's header: `status`, `branch`, `pr`
6. the assumption ledger: rows verified, rows the user resolved, rows invalidated
7. findings appended to `story-<story-number>.md`
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
- [ ] one worktree per touched repo holds the story branch; none was created when one existed
- [ ] the steps ran in order; only steps marked independent ran in subagents, dispatched in one message
- [ ] no subagent ran a `git` command
- [ ] every verification command came from the plan's `## Verification`; none was detected
- [ ] every commit is a working increment on the story branch, staged by exact path; nothing was pushed, and no hook was skipped
- [ ] no code, comment, copy or commit message mentions epic, story, acceptance criterion, AC, or workflow history
- [ ] only the plan's `## Steps` ticks, `## Assumptions` rows and header changed in `story-<story-number>-ac<criterion-number>.md`
- [ ] every assumption this run coined is `verified`, `resolved`, or `invalidated`; none is left `open` or `cascaded`
- [ ] any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` was appended to `story-<story-number>.md`'s `## Findings`, never applied directly
- [ ] `status: implemented` is set only after every step ticked, validation passed, and every commit landed, with `branch` and `pr` set
- [ ] `epic-progress.md` did not change
- [ ] the `/compact` instructions were printed, and no offer to start the next criterion was made
- [ ] the story number and the criterion number are recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **`story-<story-number>-ac<criterion-number>.md` missing** — name `/a-plan <story-number> <criterion-number>` as the command that must run first, and stop
- **The plan is not `status: done`** — print its status, name `/a-plan <story-number> <criterion-number>`, and stop
- **An assumption row in the plan is still `open` or `cascaded`** — print the row, and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`. NEVER settle it here
- **The plan does not match the worktree** — report exactly what differs, and send the user to `/a-edit plan <story-number> <criterion-number> <guidance>`. NEVER invent a step
- **A worktree has uncommitted changes** — print `git status --porcelain`, and stop. NEVER stash, reset or discard
- **`/wt` fails or the user declines its confirmation** — report the step `wt.md` stopped at, and stop
- **An in-scope failure stays red after fixing** — leave `status: done`, report the command and its output, and stop
- **`gh` is missing or unauthenticated** — set `pr: none`, and report it as a risk
