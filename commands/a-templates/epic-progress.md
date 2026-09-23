---
description: "Template: epic-progress.md, the epic-wide state file seeded and driven by /a-cont"
disable-model-invocation: true
---

# Progress file template

`epic-progress.md` lives at `$EPIC_DIR/epic-progress.md`, beside `epic.md` and `epic-architecture.md`. `/a-cont` is the only writer.

## Shape

````md
---
updated: 2026-09-23T14:05+1000
---

# <epic-slug>

Epic dir: <EPIC_DIR>
Repos: <repo>, <repo>, ...

## Completion matrix

| Done | Stage | Artefact | Status | Updated | Branch |
| --- | --- | --- | --- | --- | --- |
| [x] | a-epic | epic.md | done | 2026-09-21T16:54+1000 | - |
| [x] | a-architecture | epic-architecture.md | done | 2026-09-22T10:02+1000 | - |
| [x] | a-story 3 | story-3.md | done | 2026-09-22T19:23+1000 | checkout-flow/3-guest-email |
| [ ] | a-design 3 | story-3-design.md | draft | 2026-09-23T09:40+1000 | checkout-flow/3-guest-email |

## Blocked

<empty, or the gate that stopped the run and what the user must decide>

## Findings

<empty, or what /a-cont found this run, one line per finding, newest last>
````

## Header fields

| Field | Content |
| --- | --- |
| `updated` | Per conventions `## Document header`. `epic-progress.md` carries no `status` |
| Epic dir | `$EPIC_DIR`, resolved per `~/.claude/commands/a-templates/conventions.md` |
| Repos | The touched-repos list from `epic.md`'s `## Repos` |

## Columns

| Column | Content |
| --- | --- |
| Done | `[x]` only when Status is `done`, else `[ ]`. One exception: the seeded `a-epic` row, per `## Legacy matrix` |
| Stage | The command and its selector, exactly as `/a-cont` prints it: `a-epic`, `a-architecture`, `a-story 3`, `a-design 3`, `a-plan 3-1`, `a-implement 3-1`, `a-finish 3` |
| Artefact | The doc's file name under `$EPIC_DIR`. `a-implement` and `a-finish` write no doc: `commit <7-char sha>` once they commit, else `-` |
| Status | Copied from the artefact's `status` header. `a-implement` and `a-finish`: the command's own report. A headerless artefact: `legacy` |
| Updated | Copied from the artefact's `updated` header, or `-` |
| Branch | `-` until the story's `story-N.md` sets its `branch` header, then that branch on every row of the story |

The matrix follows `## Story Order`, never the number sequence: story 3 above runs first because `epic.md` puts it first.

## Row shape

1. Row 1 is always `a-epic`, row 2 is always `a-architecture`
2. Then exactly ONE `a-story <n>` row: the first story in `epic.md`'s `## Story Order` whose `story-N.md` is missing or not `done`. NEVER seed a row per story, and NEVER seed more than one story ahead
3. A story's `a-story` row ticks → append that story's `a-design` row, immediately below it
4. A story's `a-story` row ticks → read `story-N.md`'s acceptance criteria list, and append one `a-plan` row and one `a-implement` row per criterion, in order, below the story's `a-design` row
5. A story's last criterion's `a-implement` row ticks → append that story's `a-finish` row
6. A story's `a-finish` row ticks → re-read `epic.md`'s `## Story Order` and append the next story's `a-story` row, chosen per rule 2. No entry left → the epic is complete

## Mutability

1. Stage and Artefact are set once. NEVER edit, move, or remove a row. Everything above the pending rows is the epic's history, in the order it actually happened
1. Status, Updated and Branch refresh from the artefact's header on every `/a-cont` run. Done follows Status
1. NEVER untick a row. A revised `done` doc keeps `status: done`, per conventions `## Document header`
1. The single trailing unticked `a-story` row is the only provisional row. `## Story Order` changed while it sat unticked → replace its Stage and Artefact with the new next story, on the next `/a-cont` run
1. Every other row is appended, never reordered, never removed

## Legacy matrix

An `epic-progress.md` without the header, or with the old `# | Stage | Selector | Evidence | Status` columns, is legacy. `/a-cont` rewrites it into this shape on its next write, once:

1. Stage = the old Stage plus the old Selector's numbers (`a-story` + `story 1` → `a-story 1`)
1. Artefact = the file the old Evidence names, else the path the stage's command writes
1. Done = the old tick, kept as it was. Status and Updated come from the artefact's header; `legacy` and `-` when it exists without one; `-` and `-` when it does not exist
1. Drop the old `#`, Selector and Evidence columns. Seed a missing `a-epic` row at the top, ticked when `epic.md` exists without a header: `/a-cont` only runs once `epic.md` exists, and it never runs `a-epic`
1. Keep `## Blocked` as it is. Move any other section outside this shape into `## Findings`, one line each
1. Record the migration as one line in `## Findings`

## Rules

1. Tick a row only on Status `done`. A `legacy` row keeps the tick it had and is never newly ticked, except the seeded `a-epic` row per `## Legacy matrix`
2. Every stage records the command's own report, never its prose
3. One row per stage per selector, in execution order
4. `## Blocked` is empty while the run is healthy. A gate writes the stage, the exact failure, and the decision the user must make
5. `$PLANNING_ROOT` is a git repository; the user commits `epic-progress.md` by hand, never `/a-cont`
