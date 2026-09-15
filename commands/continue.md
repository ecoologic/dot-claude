---
description: Drive the story pipeline after the design, through handoff, waves, verify, simplify, code-review, recommit and the draft PR
argument-hint: [<story-slug>]
disable-model-invocation: true
---

# Continue the story pipeline

Run every stage of one story after the design. Stop at the first failed gate, or at the end. `/architect` owns the design. This command NEVER touches it.

## Core rules

1. The orchestrator owns git. THIS session runs every `git` command, single-threaded
1. A task subagent NEVER calls `git`. It writes its owned files, then reports the paths
1. `progress.md` is the state. Read it first. Rewrite it after every stage
1. NEVER tick a row without citable evidence: a commit SHA (Secure Hash Algorithm), a test name, or an exit code
1. NEVER record an agent's prose. Record the command string and its exit code
1. A gate stops the WHOLE run. Write `## Blocked`. Tick nothing further. Report. NEVER retry
1. A command cannot invoke another command. READ the command file, then follow its text
1. NEVER push. Stage 9 follows `pr-draft.md`, which owns the only push
1. NEVER pass `--no-verify`. The hooks run

## Stage map

| # | Stage | Runs in | Model |
| --- | --- | --- | --- |
| 1 | preflight | main session | - |
| 2 | resume checks | main session | - |
| 3 | handoff | main session | - |
| 4 | wave tasks | one subagent per task | from the packet |
| 5 | verify | subagent | haiku |
| 6 | simplify | subagent | fable |
| 7 | code-review | subagent | opus |
| 8 | recommit | main session | - |
| 9 | pr-draft | main session | - |

Three stages stay in the main session for a reason:

1. `handoff` spawns four quality subagents of its own. Nested subagents are not guaranteed
1. `recommit` rewrites history, and the orchestrator owns git
1. `pr-draft` needs the Atlassian MCP (Model Context Protocol) tools, and spawns the `uml-diagram` agent

## 0. Resolve the story

1. `$ARGUMENTS` holds the slug. No argument → the slug is the current branch, from `git rev-parse --abbrev-ref HEAD`
1. Find the folder with `ls -d ~/dev/plans/*/<slug>/`
1. No hit → STOP. Print the slug you looked for. NEVER create the folder. NEVER guess
1. More than one hit → STOP. List every hit. Ask which epic. NEVER pick one
1. One hit is the story folder. Call it `STORY`
1. `STORY/design.md` is missing → STOP. The design stage has not run
1. `STORY/progress.md` is missing → stage 3 has not run. Start at stage 3
1. `STORY/progress.md` exists → read it whole. Start at the first unticked row

## 1. Preflight

Stop at the first failure. Report the exact reason.

1. Inside a git repository, from `git rev-parse --show-toplevel`
1. `progress.md` exists → its `Repo` MUST equal that toplevel, and its `Branch` MUST equal `git rev-parse --abbrev-ref HEAD`. A mismatch → STOP
1. `progress.md` is missing → the current branch MUST equal the slug. A mismatch → STOP
1. No rebase, merge, cherry-pick or bisect in progress, from `git status`. One is → STOP
1. Clean tree. `git status --porcelain` MUST print nothing. It prints something → STOP. The orchestrator's commits are the only allowed source of change
1. The repo has `scripts/setup-worktree.sh` → run it. It is idempotent. A fresh worktree fails the pre-commit hook without it
1. Read the repository's commit rules NOW, exactly as `~/.claude/commands/recommit.md` step 2 says. Every message you write later MUST pass them

## 2. Resume checks

Run these only when `progress.md` already carries ticked rows.

1. Every SHA in the Evidence column MUST exist and MUST be an ancestor of HEAD. Check each with `git cat-file -e <sha>^{commit}` and `git merge-base --is-ancestor <sha> HEAD`
1. Either check fails → mark that row STALE. `/recommit` rewrites SHAs out of reach, so STALE rows are expected after it
1. Any STALE row → run stage 5 FIRST, before any other stage
1. Stage 5 passes → replace each stale SHA with the current HEAD SHA, keep the tick, drop the STALE mark
1. Stage 5 fails → gate. The work behind the stale rows is gone, not merely renamed
1. NEVER re-run a ticked task. An `Action: create` row fails or double-applies on a second run

## 3. Stage: handoff

Skip this stage when `STORY/handoff.md` exists.

1. Read `~/.claude/commands/architect-handoff.md`. Follow its text, with `STORY/design.md` as the argument
1. It writes `STORY/handoff.md`, then it seeds `STORY/progress.md`
1. Gate: `## Open questions` is not empty
1. Gate: one file appears in two ownership rows owned by tasks in the SAME wave
1. The **Final verification** section names no command → ask the user ONCE for the exact test and lint commands. Record them in `Verify`. Then carry on
1. NEVER detect a verification command. A probe like `npm run lint` finds nothing in a repo with no `lint` script, and ticks green

## 4. Stage: waves

One wave at a time, in the order of the handoff **Execution waves** table. NEVER start the next wave before this one commits.

### 4.1 Launch

1. Spawn one `Agent` per task in the wave, ALL in one message, so they run at the same time
1. `model` comes from the packet header table. The `Agent` tool takes no effort parameter, so name the packet's effort in the first line of the prompt
1. The prompt carries these, in this order, and nothing else:
   1. The packet body VERBATIM
   1. The handoff **Shared context** section
   1. The real text of every skill the packet lists. Read its `SKILL.md`, or, for a built-in skill with no file, tell the subagent to call `Skill` itself. NEVER paraphrase a skill
   1. `NEVER run any git command. Write your owned files. Then report every path you wrote, one per line.`
1. A subagent that reports it ran `git` → gate, whatever else it says

### 4.2 Join

1. Any task reports failure → gate. Name the task
1. Run `git status --porcelain`. Every path it prints MUST appear in a **File ownership** row owned by a task in THIS wave
1. A path outside those rows → gate. Name the path, and its owner, or `unowned`
1. An `Action: create` row whose file is absent → gate
1. Run the wave's **Integration checks** commands. Any non-zero exit → gate. Record the command and the exit code

### 4.3 Commit

1. One commit per wave. THIS session runs `git add -A`, then `git commit -m "<message>"`
1. The message comes from the wave's `Why` clause, rewritten to pass the stage 1 commit rules. Commitlint rejects a prose subject
1. A hook that rewrites files → `git add -A`, then `git commit --amend --no-edit`
1. A hook that fails → gate. Report the hook and its output verbatim
1. Read the short SHA from `git rev-parse --short HEAD`
1. Tick EVERY task row of the wave, each with its own file count and the shared wave SHA

## 5. Stage: verify

1. One subagent, model `haiku`. It runs in a subagent because test output is large, and the orchestrator keeps its context for the gates
1. The prompt carries the `Verify` commands from `progress.md`, verbatim
1. It reports, per command: the command string, the exit code, and at most 20 lines of failure output
1. Gate: any non-zero exit
1. Evidence: the command string, the exit code, and the pass count

## 6. Stage: simplify

1. One subagent, model `fable`. Tell it to call `Skill` with `simplify`, then follow it
1. `simplify` changes files in the working tree. It does NOT commit
1. Re-run stage 5. Gate: any non-zero exit
1. The tree is dirty → commit it HERE, with `git add -A` and `git commit -m "<message>"`. Write the message from the actual diff, under the stage 1 commit rules
1. `pr-draft` hard-stops on a dirty tree, so nothing downstream can absorb these changes
1. The tree is clean → `simplify` found nothing. Tick the row with `no changes`. Commit nothing

## 7. Stage: code-review

1. One subagent, model `opus`. Tell it to call `Skill` with `code-review` and the arguments `high --fix`
1. NEVER split this into a find pass and a fix pass. `--fix` re-runs the whole review, so two calls pay for the review twice, and the two passes can disagree
1. Tell the subagent to write its finding table to `STORY/review.md` BEFORE it returns, one row per finding:

   | Severity | Location | Finding | Outcome |
   | --- | --- | --- | --- |

1. `Location` is `file:line`. `Outcome` is `fixed` or `skipped`. A `skipped` row carries the reason
1. The subagent overwrites `STORY/review.md`. It holds the latest review, never a history
1. The file is missing when the subagent returns → gate. The stage has no evidence
1. Read `STORY/review.md`. Gate: any row at or above the `Review gate` severity in `progress.md` whose outcome is `skipped`
1. `/code-review` emits no machine-readable result, so the table is the subagent's own account. It is weaker than the exit-code gates. Say so in the final report
1. Re-run stage 5. Gate: any non-zero exit
1. Commit exactly as stage 6 says. A clean tree means no finding was applied
1. Evidence: the `STORY/review.md` path, the finding count, and the count at or above the gate

## 8. Stage: recommit

Skip this stage when `progress.md` says `Recommit: no`.

1. Read `~/.claude/commands/recommit.md`. Follow its text in THIS session
1. Gate: the `IDENTICAL` tree check fails
1. Gate: the rebase aborts on a conflict
1. Every SHA already in `progress.md` is now unreachable. Mark each row `recommitted <new-sha>`, with the new commit that carries its work
1. Evidence: the new commit list, one line each, and the backup ref name

## 9. Stage: pr-draft

1. Read `~/.claude/commands/pr-draft.md`. Follow its text in THIS session
1. Gate: the tree is dirty. Stage 6 or stage 7 failed to commit
1. Gate: the branch is the default branch
1. Gate: `gh auth status` fails
1. The Atlassian tools are unavailable → say so in the report. Without them `pr-draft` files against a fallback epic silently
1. Evidence: the PR (Pull Request) URL (Uniform Resource Locator)

## Gates

1. A gate stops the run at that point. No later stage runs
1. Write the stage name, the exact command or check that failed, and its output, into `## Blocked` in `progress.md`
1. Tick nothing for the failed stage. Leave every earlier tick alone
1. Report the stage, the reason, and the decision the user must make
1. NEVER retry a gate. NEVER work around one. NEVER edit a test to make it pass

## Important notes

1. NEVER run two `/continue` runs on one story. No lock stops you, and the second run double-commits
1. NEVER create a story folder. `/architect` creates it
1. NEVER edit `design.md` or `handoff.md`. They are the input
1. NEVER detect a test or lint command. `Verify` in `progress.md` is the only source
1. NEVER push outside stage 9
1. `progress.md` is not version-controlled. `~/dev/plans` is not a git repository
1. DO NOT do anything beyond the stages above

## Report

1. The stages that ran, with their evidence, one line each
1. The stage that stopped the run, or `complete`
1. The path of `progress.md`
1. The PR URL, when stage 9 ran
