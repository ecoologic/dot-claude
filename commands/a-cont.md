---
description: Drive the epic pipeline one gate at a time, from architecture through finish
argument-hint: "[<epic-slug>] [details]"
disable-model-invocation: true
---

# Continue the epic pipeline

Run the next unticked stage of one epic, then stop. `/a-epic` owns the epic and its story list; this command never creates them.

## Core rules

1. `progress.md` is the state. Read it first, seed or extend it, then rewrite it after every stage
1. NEVER tick a row without citable evidence: a commit SHA, a test name, an exit code, or, for a planning artifact with no commit, its path and the first 7 characters of `shasum -a 1 <file>`
1. NEVER record a command's prose. Record what it actually produced
1. A gate stops the WHOLE run. Write `## Blocked`. Tick nothing further. Report. NEVER retry
1. A command cannot invoke another command. READ the command file, then follow its text
1. Run exactly ONE stage per invocation, then stop and print the next command to type
1. NEVER push. Every push stays explicit, from the user
1. NEVER pass `--no-verify`. The hooks run

## Step 0: Resolve the epic

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution.
1. `$ARGUMENTS` = `[<epic-slug>] [details]`. A leading token naming an existing `$PLANNING_ROOT/<token>` folder is the epic slug; the rest is `details`, passed verbatim to whichever command runs this turn.
1. No slug resolves → stop and ask. NEVER guess, NEVER create `$EPIC_DIR`
1. `$EPIC_DIR/epic.md` is missing → stop. `/a-epic` has not produced its output yet
1. Record the resolved epic slug in memory

## Step 1: Seed or extend `progress.md`

Read `~/.claude/commands/a-templates/progress.md`, the template for this file, and follow its **Row shape** rules exactly.

1. `$EPIC_DIR/progress.md` is missing → create it: row 1 is `a-architecture`, then one `a-story` row per Actionable and Blocked story in `epic.md`, in story order
1. `$EPIC_DIR/progress.md` exists → read it whole, then apply every **Row shape** rule that now applies: a newly-ticked `a-story` row gets its `a-design` row and its `a-plan`/`a-implement` pairs appended below it; a newly-ticked last-criterion `a-implement` row gets its story's `a-finish` row appended
1. Only append rows. NEVER remove or reorder one

## Step 2: Find the next stage

1. Read the completion matrix top to bottom. The first row with `[ ]` is the next stage
1. Every row ticked → the epic is complete. Report it and stop
1. Extract the stage's command name and its selector column

## Step 3: Run the stage

1. Read `~/.claude/commands/<stage>.md`. Follow its text in THIS session, with the row's selector and `[details]` from Step 0 as its `$ARGUMENTS`
1. It finishes and reports its output → tick the row with citable evidence, per **Core rules**
1. It stops or asks the user something → that is a gate, not a failure. Go to Step 4

## Step 4: Gate

1. Write `## Blocked` in `progress.md`: the stage, the exact reason, the decision the user must make
1. Tick nothing further this turn. Leave every earlier tick alone
1. Report the stage, the reason, and stop. NEVER retry, NEVER work around a gate

## Step 5: Report the next command

Print the exact command to type next, using the row that is now first unticked:

| Next unticked row | Print |
| --- | --- |
| `a-story`, the first story, right after `a-architecture` ticks | `/clear`, `/rtd`, `/a-story` |
| `a-story`, a later story, right after the previous story's `a-finish` ticks | `/clear`, `/rtd`, `/a-story <n>` |
| `a-design` | `/a-design` |
| `a-plan` | `/a-plan` |
| `a-implement` | `/a-implement` |
| `a-plan`, for the SAME story, right after an `a-implement` tick | the `/compact` instructions `a-implement` already printed, then `/a-plan` |
| `a-finish`, right after the story's last `a-implement` tick | the `/compact` instructions `a-implement` already printed, then `/simplify`, `/clear`, `/code-review high --fix`, `/clear`, `/pr-draft`, `/security-review` (optional), then `/a-finish` |
| `a-finish`, reached directly (the review chain already ran) | `/a-finish` |
| none — every row ticked | nothing to run; report the epic complete |

## Important notes

1. NEVER run two stages in one `/a-cont` invocation
1. NEVER create `$EPIC_DIR` or `epic.md`. `/a-epic` creates them
1. NEVER edit `epic.md`, `architecture.md`, `story-N.md`, or `design-N.md` as inputs; each owning command edits its own output only
1. NEVER detect a test, lint, or verification command. The owning command's own contract is the only source
1. `progress.md` is not committed. `$PLANNING_ROOT` is not a git repository
1. DO NOT do anything beyond the steps above

## Report

1. The stage that ran, with its evidence
1. The stage that gated, or `complete`
1. The path of `progress.md`
1. The exact next command to type, per Step 5

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)
