---
description: "Template: progress.md, the epic-wide state file seeded and driven by /a-cont"
disable-model-invocation: true
---

# Progress file template

`progress.md` lives at `$EPIC_DIR/progress.md`, beside `epic.md` and `architecture.md`. `/a-cont` is the only writer.

## Shape

````md
# <epic-slug>

Epic dir: <EPIC_DIR>
Repos: <repo>, <repo>, ...

## Completion matrix

| # | Stage | Selector | Evidence | Status |
| --- | --- | --- | --- | --- |
| 1 | a-architecture | - | architecture.md, hash 4f2a1c9 | [x] |
| 2 | a-story | story 1 | story-1.md, hash 9c1e0aa | [x] |
| 3 | a-design | story 1 | design-1.md, hash 0b7f2dd | [x] |
| 4 | a-plan | story 1, criterion 1 | plan-1-1.md, hash 71ac93e | [x] |
| 5 | a-implement | story 1, criterion 1 | commit a1b2c3d, 2 files | [x] |
| 6 | a-finish | story 1 | commit e4f5a6b | [x] |
| 7 | a-story | story 3 | - | [ ] |

## Blocked

<empty, or the gate that stopped the run and what the user must decide>
````

## Header fields

| Field | Content |
| --- | --- |
| Epic dir | `$EPIC_DIR`, resolved per `~/.claude/commands/a-templates/conventions.md` |
| Repos | The touched-repos list from `epic.md`'s `## Repos` |

Row 7 above is story 3, not story 2, because `epic.md`'s `## Story Order` puts story 3 next. The matrix follows that list, never the number sequence.

## Row shape

1. Row 1 is always `a-architecture`, with no selector
2. Then exactly ONE `a-story` row: the next story, the first entry in `epic.md`'s `## Story Order` that has no row in the matrix yet. NEVER seed a row per story, and NEVER seed more than one story ahead
3. A story's `a-story` row ticks → append that story's `a-design` row, immediately below it
4. A story's `a-story` row ticks → read `story-N.md`'s acceptance criteria list, and append one `a-plan` row and one `a-implement` row per criterion, in order, below the story's `a-design` row
5. A story's last criterion's `a-implement` row ticks → append that story's `a-finish` row
6. A story's `a-finish` row ticks → re-read `epic.md`'s `## Story Order` and append the next story's `a-story` row, chosen per rule 2. No entry left → the epic is complete

## Mutability

1. A ticked row is set in stone: NEVER edit it, move it, untick it, or remove it. Everything above the pending rows is the epic's history, in the order it actually happened
2. The single trailing unticked `a-story` row is the only provisional row. `## Story Order` changed while it sat unticked → replace its selector with the new next story, on the next `/a-cont` run
3. Every other row is appended, never reordered, never removed
4. The next story is always re-derived from `## Story Order` at the moment the previous story's `a-finish` ticks, NEVER from the number sequence

## Rules

1. NEVER tick a row without citable evidence: a commit SHA, a test name, an exit code, or, for a planning artifact with no commit, its path and the first 7 characters of `shasum -a 1 <file>`
2. Every stage records the command's own report, never its prose
3. One row per stage per selector, in execution order
4. `## Blocked` is empty while the run is healthy. A gate writes the stage, the exact failure, and the decision the user must make
5. `progress.md` is planning state. It is never committed
6. A row whose artefact already exists on disk gets ticked by `/a-cont`'s own reconciliation step, not by re-running the stage that would produce it again
