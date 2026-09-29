---
description: Close one story after its last criterion - apply its findings upstream, record drift, remove the criterion worktrees
argument-hint: "[<story-number>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Story Finish

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In/Out** | `$EPIC_DIR/story-<story-number>.md` | The criteria and `## Findings`. Mark findings applied or rejected, and set `status: finished`. NEVER change any other section |
| **In** | `$EPIC_DIR/story-<story-number>-design.md` | What the story was designed to change |
| **In/Out** | `$EPIC_DIR/story-<story-number>-ac-*.md` | Every criterion's plan. Read the header, its criterion `branch` included, and `## Findings`. Set `pr`, and mark `## Findings` cells applied or rejected. NEVER change any other section |
| **In/Out** | `$EPIC_DIR/epic.md` | Apply the confirmed findings that target it |
| **In/Out** | `$EPIC_DIR/epic-architecture.md` | Apply the confirmed findings that target it. Bring `## Change Inventory` and `## Story Mapping` in line with what shipped |
| **In/Out** | `<worktree>/CONTEXT.md`, per touched repo | Apply the confirmed term findings, committed on the context branch, per conventions `## Criterion branches` |

## Skills

Global skills used in this command, per conventions `## Skills`: `ask-user-question` for every question asked to the user.

## Purpose

Close ONE story once every criterion is checked. This command should:
- apply the story's confirmed findings to `epic.md`, `epic-architecture.md`, and each touched repo's `CONTEXT.md`
- record what the story actually changed against what its design said
- set each plan's `pr`
- remove each criterion worktree, only on the user's confirmation, and only when nothing would be lost
- mark the story `finished`, and name the next story from `## Story Order`

## Rules

- NEVER finish a story with a criterion whose plan `status` is not `implemented, simplified, reviewed`
- NEVER apply a finding the user did not confirm
- NEVER remove a worktree with uncommitted changes or unpushed commits, and NEVER pass `--force`
- NEVER remove a worktree without the user's confirmation in this run
- NEVER delete a branch
- NEVER renumber a story, per conventions `## Story numbers`. A story-order finding rewrites `## Story Order` only
- NEVER remove a `CONTEXT.md` entry, and NEVER rename one without the user's explicit approval, per conventions `## Terminology`
- NEVER write `epic-progress.md`
- A revised `done` doc keeps its status and refreshes `updated`, per conventions `## Document header`

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. Run from the main repo root. Started inside a worktree → stop and say so, per conventions `## Where a command runs`. A worktree cannot remove itself.
1. `$ARGUMENTS` = `[<story-number>] [details]`. The first integer is the story number; the rest is high-priority guidance for this run.
1. No story number in `$ARGUMENTS` → fall through selector resolution, per conventions `## Selector resolution`.
1. Memory records `Criterion: none`, per conventions `## Memory`.

Read, with Grep or a ranged Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>.md`: its header, `#` title, `## Acceptance Criteria` and `## Findings`
- every `$EPIC_DIR/story-<story-number>-ac-*.md`: its header and its `## Findings`

Check that these exist with Glob, and NEVER read them here:
- `$EPIC_DIR/story-<story-number>-design.md`
- `$EPIC_DIR/epic.md`
- `$EPIC_DIR/epic-architecture.md`

A later step reads one of them only when it needs it, and only the section it names: Step 4 a finding's target section, Step 5 the design's `## File Structure` and `epic-architecture.md`'s `## Change Inventory` and `## Story Mapping`, Step 7 `epic.md`'s `## Story Order`.

Gates:
1. `story-<story-number>.md` reads `status: finished` → report it, and stop. This story is closed
1. A criterion in `story-<story-number>.md`'s `## Acceptance Criteria` has no `story-<story-number>-ac-<criterion-number>.md` → STOP. Name `/a-plan <story-number>`
1. A plan's `status` is not `implemented, simplified, reviewed` → STOP. Name `/a-implement` or `/a-check` for that criterion, per its status

Output:
```text
Story: <story-number> — <title>
Branches: <criterion branch>, <criterion branch>
Epic dir: <EPIC_DIR>
Criteria: <count>, all reviewed
Findings: <count not yet marked Applied or Rejected, in story-<story-number>.md and every plan>
```

## Step 2: Locate the criterion worktrees

Find each criterion worktree per conventions `### Criterion worktree lookup`, with these batching rules:

1. Run `git -C <dev-root>/<repo> worktree list --porcelain` once per repo, NEVER once per plan. Match every plan's `branch` in that one output
1. Run `git status --porcelain` once per worktree found. Step 6 reuses it
1. No entry → record `none` for that plan and repo

## Step 3: Set each plan's `pr`

Per plan, per repo it touches, run `gh pr list --head <branch> --state all --json number,state` from `<dev-root>/<repo>`. Send every call in ONE message, as parallel Bash calls.

1. Set `pr` in each `story-<story-number>-ac-*.md` header: `<repo>#<number>` per repo, comma-separated, else `none`. One Edit per plan, per conventions `## Document header`. Refresh `updated`
1. `gh` is missing or unauthenticated → leave `pr` as it is, and report it as a risk
1. No PR for a branch → report it. `/draft-pr` has not run there

## Step 4: Apply the findings

Use the `## Findings` rows Step 1 read, in `story-<story-number>.md` and in every `story-<story-number>-ac-*.md`. Skip every row already marked, per conventions `## Findings`.

1. Put the remaining rows to the user one at a time: apply, reject with a reason, or leave for later. The user may lift this gate, per conventions `## Bulk approval`
1. Apply each confirmed row to its target doc, with Edit on the section it names:
   - `epic.md` → the section the finding names. A story-order finding rewrites `## Story Order` only
   - `epic-architecture.md` → the section the finding names
   - `<repo>/CONTEXT.md` → the copy in the context worktree below, per conventions `## Terminology`
1. Refresh the target doc's `updated`, and keep its `status`
1. Append the row's mark to its Suggested Change cell, per conventions `## Findings`. Use one Edit, now, in the file that holds the row
1. A left row stays as it is. It blocks nothing; a later stage reads it, per conventions `## Findings`

Per repo with a confirmed `CONTEXT.md` row, before its first Edit there, enter the context worktree, on the context branch `<epic-slug>/story-<story-number>-context`, per conventions `## Criterion branches`:
1. A worktree holds the context branch → use it
1. No local context branch → run `git -C <dev-root>/<repo> fetch origin <default-branch>`, then `git -C <dev-root>/<repo> branch <context-branch> origin/<default-branch>`
1. No worktree → create it on the context branch, per conventions `### Criterion worktree lookup`'s create rule

Commit every `CONTEXT.md` change in the context worktree. Stage it by exact path; follow the repo's own commit message convention.

## Step 5: Record the drift

Compare what the story shipped with what `story-<story-number>-design.md` said.

1. Per plan, per repo, list the changed files: `git diff --name-status <fork-point>..HEAD` in its criterion worktree, with the fork point per conventions `## Criterion branches`. A worktree that is `none` → use the plan's merged PR, `gh pr diff <number> --name-only`. Merge the lists
1. Compare them with the design's `## File Structure`: a file shipped but not designed, a file designed but not shipped, a file whose role changed
1. Bring `epic-architecture.md`'s `## Change Inventory` and this story's row of `## Story Mapping` in line with what shipped, with Edit on those two sections only. Per conventions `## Single source of facts`, NEVER copy the design into them
1. No drift → leave both sections as they are, and say so in Step 7

## Step 6: Remove the worktrees

Once per criterion worktree, and per context worktree Step 4 created:
1. Run `git -C <worktree> rev-list --count @{u}..HEAD`. Reuse Step 2's `git status --porcelain` for a criterion worktree. Run it for a context worktree only
1. The branch is merged, per conventions `## Criterion branches`, and the tree is clean → it is safe, even with no upstream left
1. Otherwise: uncommitted changes, no upstream, or a count above `0` → do not remove it. Report why, and the exact line to run once it is pushed: `git -C <dev-root>/<repo> worktree remove <worktree>`
1. Clean and pushed → print the worktree path, then ask the user to confirm the removal. Anything but a yes → keep it, and report the line above
1. Confirmed → run `git -C <dev-root>/<repo> worktree remove <worktree>`. NEVER `--force`. NEVER delete the branch

## Step 7: Mark the story finished

1. Set `story-<story-number>.md`'s `status` to `finished`, and refresh `updated`, per conventions `## Document header`
1. Name the next story per `~/.claude/commands/a-templates/epic-progress.md`'s `## Row shape` rule 2

Summarize:
1. each plan's `pr`
2. findings applied, rejected, and left, per target doc
3. `CONTEXT.md` commits, as `<repo> <branch> <7-char sha> <subject>`, and whether they still need a push: `/draft-pr` from that worktree
4. the drift: files shipped but not designed, designed but not shipped, changed role
5. each worktree: removed, or kept with its reason and its `git worktree remove` line
6. the next story, and the command to type: `/clear`, `/a-story <n>`. None left → the epic is complete

Then stop. NEVER start the next story, and NEVER offer to.

## Success Criteria

- [ ] every criterion's plan read `implemented, simplified, reviewed` when this command started
- [ ] this command ran from the main repo root
- [ ] every plan's `pr` is set, or the reason it is not is reported
- [ ] every finding applied was confirmed by the user in this run, and is marked `Applied to <doc> on <YYYY-MM-DD>`
- [ ] every rejected finding is marked `Rejected on <YYYY-MM-DD>: <reason>`
- [ ] `CONTEXT.md` changes are committed on the context branch; nothing was pushed, and no hook was skipped
- [ ] only `## Change Inventory` and this story's `## Story Mapping` row changed for drift in `epic-architecture.md`
- [ ] no worktree was removed with uncommitted changes, unpushed commits, or without the user's confirmation; no `--force` was used, and no branch was deleted
- [ ] `story-<story-number>.md` reads `status: finished`, and only its header and its `## Findings` cells changed; in each plan, only the `pr` header and `## Findings` cells changed
- [ ] the next story was named from `## Story Order`, never by incrementing the number
- [ ] `epic-progress.md` did not change

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **Started inside a worktree** — print the main repo path, and stop
- **A criterion has no plan, or its plan is not reviewed** — print the criterion and its status, name the command that must run first, and stop
- **A worktree has uncommitted changes** — print `git status --porcelain`, and stop. NEVER stash, reset or discard
- **A finding names a section its target doc does not have** — report it, and leave the row as it is. NEVER invent the section
- **`git worktree remove` fails** — report the command and its output, keep the worktree, and carry on to Step 7
