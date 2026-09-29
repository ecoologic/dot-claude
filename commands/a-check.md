---
description: Simplify, then review with fixes, one implemented acceptance criterion on its criterion branch, then ready it for push
argument-hint: "[<story-number>] [<criterion-number>] [details]"
allowed-tools: [Read, Glob, Grep, Edit, Bash, Agent, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Criterion Check

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In/Out** | `$EPIC_DIR/story-<story-number>-ac-<criterion-number>.md` | The implemented plan, the only planning doc this command writes. Read its header, `### Dependencies`, `## Verification` and `## Out Of Scope`. Append to the header's `status` and to `## Findings` only. NEVER change any other section |
| **In** | `$EPIC_DIR/story-<story-number>-ac-*.md` | The parent plans' headers, for the base; every plan's header, for the next ready criteria |
| **Out** | the criterion worktree, per touched repo | The fixes `simplify` and `code-review` apply, their commits on the criterion branch, and the rebase before push |

## Skills

Global skills used in this command, per conventions `## Skills`: `simplify` in Step 3, `code-review` in Step 4, `run` and `claude-in-chrome` for the `browser` row in Step 5, `ask-user-question` for every question asked to the user.

Discover repo and package skills per conventions `## Skills` lookup rule. A skill about coding or testing applies to the fixes Steps 3 and 4 make.

## Purpose

Check ONE implemented acceptance criterion, once the user has verified it, on its criterion branch. This command should:
- run `simplify` on the criterion branch, validate, and commit
- run `code-review high --fix` on the criterion branch, validate, and commit
- append `simplified`, then `reviewed`, to the plan's `status`
- record any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` as a finding
- rebase onto the default branch once the parent criterion has merged, per conventions `## Criterion branches`

## Rules

- NEVER check a criterion whose plan `status` does not start with `implemented`
- NEVER switch branch, and NEVER create a worktree. The criterion worktree already exists
- NEVER broaden scope into unrelated cleanup, opportunistic refactors, or another acceptance criterion
- NEVER apply a fix that breaks a line of the plan's `## Out Of Scope`
- Run only the plan's `## Verification` rows, see Step 5
- NEVER mention epic, story, acceptance criteria, AC, or similar workflow jargon in code comments, user-facing copy, or committed implementation text
- NEVER read or write `story-<story-number>.md` or `story-<story-number>-design.md`. The plan carries everything this command needs
- NEVER write `epic.md`, `epic-architecture.md`, `epic-progress.md`, or a repo's `CONTEXT.md`; append the finding to the plan's `## Findings` instead, per conventions `## Findings`
- NEVER auto-chain into the next criterion, and NEVER offer to

## Step 1: Resolve required inputs

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<story-number>] [<criterion-number>] [details]`. The first integer is the story number, the second is the criterion number; the rest is high-priority guidance for this run, passed to both skills.
1. No story number in `$ARGUMENTS` → fall through selector resolution: the current branch, then memory, then ask.
1. No criterion number in `$ARGUMENTS` → resolve the lowest criterion of that story whose `story-<story-number>-ac-<criterion-number>.md` `status` starts with `implemented` and does not end with `reviewed`. Report which one that resolved to before continuing.
1. Record the resolved story number and criterion number in memory.

Read (stop if any are missing):
- `$EPIC_DIR/story-<story-number>-ac-<criterion-number>.md`: its header, `### Dependencies`, `## Verification` and `## Out Of Scope`
- each parent plan named by an `AC <criterion-number>` line of its `### Dependencies`: its header only

Gates, before any change:
1. `status` is `implemented, simplified, reviewed` → skip Steps 3 to 7. Only the rebase, Step 8, runs
1. `status` is `implemented, simplified` → skip Step 3
1. `status` does not start with `implemented` → STOP. Send the user to `/a-implement <story-number> <criterion-number>`

Output:
```text
Plan: <the plan's # title>
Branch: <branch>
Status: <status>
Next: <simplify | code-review | rebase>
```

## Step 2: Enter the criterion worktree

The repos are the ones the plan's `> Repos:` line and the Repo column of its `## Verification` name. Each resolves to `<dev-root>/<repo>`, the sibling of `$PLANNING_ROOT`, per conventions `## Folder layout`. `<branch>` is the plan's `branch` header.

Once per touched repo:
1. Run `git -C <dev-root>/<repo> worktree list --porcelain`. The `branch refs/heads/<branch>` entry's `worktree` line is the criterion worktree
1. No entry → STOP. Report the branch, and send the user to `/a-implement <story-number> <criterion-number>`
1. Run `git -C <worktree> status --porcelain`. Uncommitted changes → STOP. Report them. NEVER stash, reset or discard them
1. The fork point is per conventions `## Criterion branches`. On a stacked branch, the parent criterion's commits stay out of every range below

From here on, every Read and Edit uses an absolute path inside the worktree. Every Bash command runs with the worktree as its working directory.

## Step 3: Simplify

Invoke the `simplify` skill in each worktree. Its target is the criterion branch's changes since the fork point. Pass the plan's `## Out Of Scope` list and this run's guidance as its arguments.

1. Validate, per Step 5
1. Commit, per Step 6. No change → no commit
1. Append `, simplified` to the plan's `status`, with one Edit, per conventions `## Document header`. Refresh `updated`

## Step 4: Review with fixes

Invoke the `code-review` skill in each worktree, with `high --fix` and the criterion branch's changes since the fork point as its target. Pass the plan's `## Out Of Scope` list and this run's guidance.

1. A finding the skill did not fix → report it in Step 9. NEVER fix it outside the skill's own pass
1. Validate, per Step 5
1. Commit, per Step 6. No change → no commit
1. Append `, reviewed` to the plan's `status`, with one Edit, per conventions `## Document header`. Refresh `updated`

## Step 5: Validate

Run the plan's `## Verification` rows only, in this order:
1. Targeted tests for the changed module, component or endpoint
2. Targeted lint, format, or type checks
3. The full test suite
4. The `browser` row, when the plan has one: invoke the `run` skill to start the app with the row's command, then the `claude-in-chrome` skill to follow `### Browser` step by step. Record a GIF of the run as evidence

A failure a skill's fix caused → revert that fix only, rerun, and report it in Step 9. A failure that is pre-existing or unrelated → report the command and the failure, and do not block completion.

A rung has no `## Verification` row, or its row is `- None` → skip it, and report it as a risk in Step 9. The Chrome extension is not connected → skip the `browser` rung, and report that the user must check it by hand.

## Step 6: Commit

1. Commit in each worktree with changes, on the criterion branch only
1. Stage by exact path every file the skill changed. NEVER `git add -A`
1. After each commit, `git status --porcelain` in that worktree prints nothing. Anything left → commit it, or stop and report it
1. Follow the repo's own commit message convention, from its `CLAUDE.md` or `CONTRIBUTING.md`. The message follows the workflow-jargon rule above
1. A hook fails → fix the cause, then commit again, per conventions `## Git`

## Step 7: Record findings

A fix or a review finding may show what `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` should eventually reflect. NEVER write any of those three files from this command.

Append each finding to the plan's `## Findings` section instead:
- the target doc: `epic.md`, `epic-architecture.md`, or `<repo>/CONTEXT.md`
- the finding
- the suggested change

Append only. NEVER edit a row an earlier stage already wrote, and NEVER touch another section of that file.

## Step 8: Rebase before push

Once per worktree, per conventions `## Criterion branches`:
1. Stacked, and the parent branch is merged → rebase onto `origin/<default-branch>` from the fork point. Then validate, per Step 5
1. Stacked, and the parent branch is not merged → no rebase. The PR stacks on the parent branch
1. Not stacked → no rebase
1. A conflict → abort, report the files, and stop. `status` keeps `reviewed`; this step reruns on the next `/a-check`

Record the base per worktree for Step 9.

## Step 9: Present to user

Summarize:
1. what `simplify` changed, per worktree, or `nothing`
2. what `code-review` fixed, and every finding it left unfixed
3. the `browser` result first, with the GIF path, or why it did not run. Then the validation result, per `## Verification` row, every rung skipped, and every fix reverted
4. the commits, as `<repo> <7-char sha> <subject>`
5. the plan's `status`
6. findings appended to the plan
7. the rebase, and the base, per worktree

Then name the next commands, in each worktree: `/draft-pr`, or `/draft-pr --base <parent-branch>` when the base is the parent branch, then `/security-review` (optional). Then `/clear`, and `/a-implement <story-number> <criterion-number>` for every ready criterion, per conventions `## Criterion branches`, one session each. No criterion left without `implemented, simplified, reviewed` → `/a-finish <story-number>` from the main repo root. Then stop. NEVER start them, and NEVER offer to.

## Success Criteria

- [ ] the plan's `status` started with `implemented` when this command started
- [ ] `simplify` ran before `code-review`, and each ran on the criterion branch's changes since the fork point, in its existing worktree
- [ ] no worktree was created, and no branch was switched
- [ ] every verification command came from the plan's `## Verification`; the `browser` row, when present, ran last in Chrome
- [ ] every commit is on the criterion branch, staged by exact path; nothing was pushed, and no hook was skipped
- [ ] every worktree has a clean `git status --porcelain` at the end
- [ ] a stacked branch whose parent branch merged was rebased onto the default branch from its fork point, and validated
- [ ] only the header's `status` and `updated`, and `## Findings` rows, changed in `story-<story-number>-ac-<criterion-number>.md`; no other planning doc changed
- [ ] `status` reads `implemented, simplified, reviewed` only after both skills ran, validated and committed
- [ ] any incongruity against `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` was appended to the plan's `## Findings`, never applied directly
- [ ] `epic-progress.md` did not change
- [ ] the story number and the criterion number are recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **`story-<story-number>-ac-<criterion-number>.md` missing** — name `/a-plan <story-number>` as the command that must run first, and stop
- **The plan's `status` does not start with `implemented`** — print it, name `/a-implement <story-number> <criterion-number>`, and stop
- **No worktree holds the criterion branch** — print `git worktree list --porcelain`, and stop
- **A worktree has uncommitted changes** — print `git status --porcelain`, and stop. NEVER stash, reset or discard
- **A skill is not available** — name it, leave `status` as it is, and stop
- **The rebase conflicts** — run `git rebase --abort`, print the conflicting files, and stop. NEVER resolve them by guessing
- **A fix stays red after reverting it** — leave `status` as it is, report the command and its output, and stop
