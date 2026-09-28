---
description: Drive the epic pipeline one gate at a time, from architecture through finish
argument-hint: "[<epic-slug>] [details]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, AskUserQuestion, Skill, Bash(git rev-parse:*), Bash(date:*), Bash(git symbolic-ref:*), Bash(git branch:*)]
disable-model-invocation: true
---

# Continue the epic pipeline

Run the next unticked stage of one epic, then stop. `/a-epic` owns the epic and its story list; this command never creates them.

## Core rules

1. `epic-progress.md` is the state. Read it first, then seed or extend it, editing it row by row, section by section — NEVER rewrite the whole file, except the one-time legacy migration, per the template's `## Legacy matrix`
1. Every write to `epic-progress.md` refreshes its own `updated` header, per conventions `## Document header`
1. Tick a row only when Step 2 or Step 4 sets a Status that ticks it, per the Done rule in the template's `## Columns`, or when seeding the `a-epic` row per its `## Legacy matrix`. NEVER a hash, a SHA, or any other manufactured evidence
1. NEVER record a command's prose. Record what it actually produced
1. A doc's `status: done` means the user approved the doc, per conventions `## Document header` — NEVER that its code exists or its criteria pass. Only a ticked `a-implement` or `a-finish` row records delivery. NEVER report a `done` story or design as delivered
1. A gate stops the WHOLE run. Write `## Blocked`. Tick nothing further. Report. NEVER retry
1. A command cannot invoke another command. READ the command file, then follow its text
1. Run exactly ONE stage per invocation, then stop and print the next command to type
1. `a-cont` never runs `a-epic`. Its row is always a gate, per Step 3
1. NEVER push. Every push stays explicit, from the user
1. NEVER pass `--no-verify`. The hooks run

## Step 0: Resolve the epic

1. Read `~/.claude/commands/a-templates/conventions.md`. `a-cont` is not a planning stage: resolve the epic slug per conventions `## Selector resolution`'s "every other `a-*` command" row (argument → branch → memory → ask), and per `## Where a command runs`, run from the main repo or a worktree — the stage it runs enforces its own rule
1. `$ARGUMENTS` = `[<epic-slug>] [details]`. A leading token naming an existing `$PLANNING_ROOT/<token>` folder is the epic slug; the rest is `details`, passed verbatim to whichever command runs this turn
1. No slug resolves → stop and ask. NEVER guess, NEVER create `$EPIC_DIR`
1. `$EPIC_DIR/epic.md` is missing → stop. `/a-epic` has not produced its output yet
1. Record the resolved epic slug in memory

## Step 1: Seed or extend `epic-progress.md`

Read `~/.claude/commands/a-templates/epic-progress.md` and follow its `## Row shape`, `## Mutability`, and `## Legacy matrix` exactly.

1. `$EPIC_DIR/epic-progress.md` is missing → create it from the template, seeded per `## Row shape`
1. It exists and is legacy, per the template's `## Legacy matrix` → migrate it into the new shape on this write, once
1. It exists and is current shape → read it whole, then apply every `## Row shape` and `## Mutability` rule that now applies

## Step 2: Reconcile against disk

Stages also run outside `/a-cont`. Before trusting the matrix, refresh every row from its artefact's header, so this command stays idempotent no matter how it drifted.

1. Every row's Artefact is a doc (`epic.md`, `epic-architecture.md`, `story-N.md` for the `a-story` and `a-finish` rows, `story-N-design.md`, `story-N-acM.md` for the `a-plan`, `a-implement` and `a-check` rows) → Read only its header, `limit: 6`, never the whole file, never `shasum`
1. The header's `updated` matches the row's Updated cell → the row is current, leave Status and Updated alone
1. It differs, or the row has no Updated yet → copy `status` and `updated` from the header into the row
1. No header at all → the artefact is legacy: Status becomes `legacy`, Updated `-`. Keep any tick the row already had; NEVER newly tick a legacy row
1. The artefact is missing from disk → leave the row `[ ]`, Status and Updated unchanged
1. Every row of a story copies its Branch from `story-N.md`'s own `branch` header, once that header sets one — never from the row's own artefact
1. Tick a row `[x]` only when its refreshed Status ticks it, per the Done rule in the template's `## Columns`. NEVER downgrade or remove a tick already present
1. A row refreshed here, or newly ticked, triggers the same `## Row shape` appends a tick in Step 4 triggers. Append those rows, then reconcile them too
1. Repeat until a pass changes nothing further

## Step 3: Find the next stage

1. Read the completion matrix top to bottom. The first row with `[ ]` is the next stage
1. That row is `a-epic` → `a-cont` never runs `a-epic`. Read `epic.md`'s header: `status: draft` → the next command is `/a-epic <slug>`; headerless (legacy) → the next command is `/a-edit epic <details: add the document header>`. Go to Step 5 and gate with that reason and command
1. Every row ticked and `## Story Order` has no story left without rows → the epic is complete. Go to Step 6
1. Every row ticked but a story remains in `## Story Order` → append that story's `a-story` row per the template's `## Row shape`, and take it as the next stage
1. Extract the stage's command name and selector from the Stage cell

## Step 4: Run the stage

1. Read `~/.claude/commands/<stage>.md`. Follow its text in THIS session, with the row's selector and `[details]` from Step 0 as its `$ARGUMENTS`. Never `a-epic` — Step 3 gates before any such row reaches here
1. It finishes and reports its output → re-read the artefact's header, per Step 2, and refresh the row from it. Tick only if Status now ticks it, per the Done rule in the template's `## Columns`. Empty `## Blocked` if it held an earlier gate, then go to Step 6
1. It stops or asks the user something → that is a gate, not a failure. Go to Step 5

## Step 5: Gate

1. Write `## Blocked` in `epic-progress.md`: the stage, the exact reason, the decision the user must make — or, from Step 3's `a-epic` case, that reason and the command to run instead
1. Tick nothing further this turn. Leave every earlier tick alone
1. Report the stage and the reason, then go to Step 6. NEVER retry, NEVER work around a gate

## Step 6: Append findings

Before printing the next command, append one line per finding this run produced to `epic-progress.md`'s `## Findings`, newest last, per the template's `## Shape`: any drift Step 2 found, a legacy migration Step 1 performed, any row refreshed, and any other anomaly this run hit. Nothing new this run → leave `## Findings` unchanged. Then go to Step 7.

## Step 7: Report the next command

Print the exact command to type next, using the row that is now first unticked, then stop. Render its Stage cell as a slash command: prefix `/`, and a hyphenated number pair (story-criterion) becomes two space-separated numbers — `a-plan 3-1` renders as `/a-plan 3 1`, per `a-plan`'s argument-hint.

| Next unticked row | Print |
| --- | --- |
| `a-epic`, the first unticked row (always a gate, per Step 3) | `/a-epic <slug>` when `epic.md` is `draft`, or `/a-edit epic <details: add the document header>` when it is legacy |
| `a-story <n>` | `/clear`, `/rtd`, `/a-story <n>`, with `<n>` read from the row's Stage cell, never `<previous> + 1` |
| `a-design <n>` | `/a-design <n>` |
| `a-plan <n-m>` | `/a-plan <n> <m>` |
| `a-implement <n-m>` | `/a-implement <n> <m>` |
| `a-check <n-m>`, right after its `a-implement` row ticks | the `/compact` instructions `a-implement` already printed, then: verify the criterion yourself, then `/a-check <n> <m>` |
| `a-check <n-m>`, reached directly | `/a-check <n> <m>` |
| `a-finish <n>`, right after the story's last `a-check` row ticks | `/clear`, `/pr-draft`, `/security-review` (optional), then `/a-finish <n>` from the main repo root |
| `a-finish <n>`, reached directly (`/pr-draft` already ran) | `/a-finish <n>`, from the main repo root |
| none — every row ticked and `## Story Order` is exhausted | nothing to run; report the epic complete |

## Important notes

1. NEVER run two stages in one `/a-cont` invocation
1. NEVER create `$EPIC_DIR` or `epic.md`. `/a-epic` creates them
1. NEVER infer the next story by incrementing the last one; per conventions `## Story numbers`, `## Story Order` is the only sequence
1. NEVER edit `epic.md`, `epic-architecture.md`, `story-N.md`, or `story-N-design.md` as inputs; each owning command edits its own output only
1. NEVER detect a test, lint, or verification command. The owning command's own contract is the only source
1. Per conventions `## Git`: `$PLANNING_ROOT` is a git repository; the user commits it by hand; `a-cont` never commits
1. DO NOT do anything beyond the steps above

## Report

1. The stage that ran, and the status its artefact's header now shows, labelled as doc approval
1. Delivery per story: the story's ticked `a-implement` rows by criterion, or `no code yet` when none is ticked
1. Any row refreshed this run, and the artefact behind it
1. The stage that gated, or `complete`
1. The path of `epic-progress.md`
1. The exact next command to type, per Step 7

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)
