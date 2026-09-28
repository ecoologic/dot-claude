---
description: Revise one workflow artifact from high-priority guidance using its original command contract
argument-hint: "<artifact-type> [selector] <instructions-or-suggestions>"
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash(git rev-parse:*), Bash(date:*), Bash(git symbolic-ref:*), Bash(git branch:*), Agent, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Artifact Revision

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | `~/.claude/commands/a-templates/conventions.md` | Shared path resolution, selector resolution, and repo conventions |
| **In** | `~/.claude/commands/<owner-command>.md` | The `a-*` command that owns the target artifact: its contract, required inputs, and allowed writes |
| **In** | the owner command's own required inputs | The same inputs the owner command reads for that artifact |
| **In/Out** | the target artifact under `$EPIC_DIR` | The one artifact this run revises |
| **Conditional In** | codebase | Read only when the owner command is code-informed, and only around the guidance |
| **Conditional In/Out** | `<repo>/CONTEXT.md` | Update only when the owner command itself is allowed to write it |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

This command is not a pipeline stage. It NEVER appears in `epic-progress.md`, and it NEVER writes `epic-progress.md`; `/a-cont` is that file's only writer.

## Supported Targets

| Artifact Type | Selector | Owner Command | Target Artifact |
| ------------- | -------- | ------------- | --------------- |
| `idea` | none | `/a-epic` | `$EPIC_DIR/epic-requirements.md` |
| `epic` | none | `/a-epic` | `$EPIC_DIR/epic.md` |
| `personas` | none | `/a-epic` | `$EPIC_DIR/epic-personas.md` |
| `stretch-goals` | none | `/a-epic` | `$EPIC_DIR/epic-stretch-goals.md` |
| `architecture` | none | `/a-architecture` | `$EPIC_DIR/epic-architecture.md` |
| `story` | `<story-number>` | `/a-story` | `$EPIC_DIR/story-<story-number>.md` |
| `design` | `<story-number>` | `/a-design` | `$EPIC_DIR/story-<story-number>-design.md` |
| `plan` | `<story-number> <criterion-number>` | `/a-plan` | `$EPIC_DIR/story-<story-number>-ac<criterion-number>.md` |

An artifact type whose owner command file does not exist under `~/.claude/commands/` is unsupported. Stop and say which command must be written first; NEVER reconstruct a contract from the artifact alone.

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. Invoke the same skills the owner command would have invoked for the sections this revision touches, and no others.

## Purpose

Revise one workflow artifact from concrete high-priority guidance, without breaking the contract that produced it.

This command should:
- reload the owner command contract instead of guessing the artifact's shape
- reread the inputs that justified the artifact originally
- compare the current artifact against the guidance and the owner contract
- apply the smallest durable revision that addresses the issue
- keep the assumption ledger and the story order intact under the same rules the owner command follows
- report which downstream artifacts the revision just made stale

## Rules

- NEVER edit more than one target artifact per run
- NEVER regenerate the artifact from scratch unless the current one is unusable
- NEVER bypass the owner contract; read the owner command file first
- NEVER write application code, create commits, or write files outside `$EPIC_DIR` and whatever the owner command is itself allowed to write
- NEVER write `epic-progress.md`
- NEVER write a file the owner command is forbidden to write. Revising `story-<story-number>.md` or `story-<story-number>-design.md` carries the same ban on `epic.md`, `epic-architecture.md`, and a repo's `CONTEXT.md`; record the change in `story-<story-number>.md`'s `## Findings` instead, per conventions `## Findings`
- NEVER edit any section of `story-<story-number>.md` except `## Findings` while revising `story-<story-number>-design.md` or `story-<story-number>-ac<criterion-number>.md`; `/a-design` and `/a-plan` are bound by the same rule
- NEVER edit `story-<story-number>-design.md` while revising `story-<story-number>-ac<criterion-number>.md`; a design gap is revised with `/a-edit design <story-number>` first, then the plan is revised against it
- NEVER detect a verification command while revising a plan; it comes from the user or from an earlier `story-<story-number>-ac*.md`, per `/a-plan`'s own rule
- NEVER change a story number. Sequencing guidance rewrites `epic.md`'s `## Story Order`, per conventions.md
- NEVER drop, renumber, or silently re-status a row in `## Assumptions`, per conventions.md's Assumptions rule
- NEVER collapse a canonical _As a_ / _I want_ / _So that_ or _Given_ / _When_ / _Then_ block, per conventions.md's Canonical blocks rule
- NEVER define synonyms; a touched repo's `CONTEXT.md` term stays canonical
- NEVER widen scope into unrelated cleanup or speculative improvement
- Preserve still-correct content; revise only the sections the guidance reaches
- Treat the freeform argument as the highest-priority guidance. It NEVER overrides the resolved target, the owner contract, canonical terminology, or any hard rule in conventions.md
- Every write refreshes the doc's `updated` header per conventions `## Document header`
- A revision keeps `status` as it is: `done` stays `done`
- A legacy doc with no header gets the header added from its template on this write, per conventions `## Document header`
- Read the target's shape from its template in `~/.claude/commands/a-templates/<type>.md`, per conventions `## Templates`

## Step 1: Resolve the target

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its selector resolution for the epic.
1. `$ARGUMENTS` = `<artifact-type> [selector] <instructions-or-suggestions>`. Parse left to right: the artifact type, its selector when the target takes one, then the guidance text.
1. Empty guidance text → stop and ask what to revise.
1. Unsupported artifact type → print the Supported Targets table and stop.
1. `story` or `design` with no selector → fall through selector resolution: the current branch, then memory, then list the story numbers on disk and ask.
1. `plan` takes two numbers. Missing the story number → resolve it as above. Missing the criterion number → list the `story-<story-number>-ac*.md` files on disk and ask which one to revise.
1. Resolve `$EPIC_DIR`. Record the resolved selector in memory.

## Step 2: Load the owner contract and the artifact

1. Read `~/.claude/commands/<owner-command>.md` in full, before reading the artifact.
1. Read the target artifact.
1. The artifact does not exist → report the exact absolute path checked, name the owner command that must produce it, and stop.

Extract from the owner command:
- its Pipeline I/O contract and required inputs
- its followed-reference requirements
- the artifact sections it owns, and the order it writes them in
- every file it is allowed to write, and every file it is forbidden to write
- its own success criteria, which this revision must still satisfy afterwards

Resolve any section, story, criterion, or assumption ID the guidance names by reading the artifact. Ask for clarification only when the artifact does not contain it, when several matches remain, or when the guidance conflicts with the owner contract.

Output:
```text
Target type: <artifact-type>
Owner command: </a-...>
Target artifact: <absolute path>
Epic dir: <EPIC_DIR>
Guidance: <one-line summary>
```

## Step 3: Reload the owner's inputs

Reload exactly what the owner command's Pipeline I/O lists as **In** for this artifact, and follow the references it requires. Derive the list from the contract, never from the user's prompt.

1. Any required input or followed reference missing or unreadable → stop and print the exact absolute path or reference
1. Owner command is code-informed → explore only around the guidance, never the whole repo
1. Read the target's `## Assumptions` section, when it has one, so the revision can be checked against what was already settled

## Step 4: Diagnose the revision

Compare the guidance, the current artifact, the owner contract, and the reloaded inputs. Classify before editing:

| Class | Means |
| ----- | ----- |
| missing content | required content the owner contract calls for was omitted |
| incorrect content | the artifact contradicts its inputs or the codebase |
| scope correction | boundaries, sequencing, or dependencies are wrong |
| naming correction | a term conflicts with a touched repo's `CONTEXT.md` |
| stale artifact | a later discovery invalidated part of it |

1. The guidance conflicts with a prior approval, canonical terminology, or a resolved decision already recorded in the artifact → surface the conflict and ask before editing
1. The guidance is really a request to rerun the whole stage → say so and stop. NEVER fake a narrow edit

## Step 5: Apply the revision

Edit the target artifact in place, preserving its structure and every section the guidance does not reach.

Then reconcile what the revision disturbed:

1. Sequencing changed and the target is `epic.md` → rewrite `## Story Order` only. NEVER renumber a story, NEVER rename `story-N.md`
1. Sequencing changed and the target is `story-<story-number>.md` → record it in `## Findings` against `epic.md`'s `## Story Order`. NEVER edit `epic.md` from a story revision
1. The revision invalidates a `verified` or `resolved` assumption → re-status that row `invalidated`, record what is true instead, and carry it forward per conventions.md's Assumptions rule
1. The revision acts on a new claim without evidence → add it as a new row under the artifact's own ID prefix, and settle it under the owner command's rules. A `story` revision settles it in this run, because `/a-design` inherits no open row; a `design` revision settles it too, because `/a-plan` inherits none either; a `plan` revision settles it as well, because `/a-implement` inherits none
1. A canonical block is reworded → keep one clause per line and keep its trailing hard breaks
1. A durable confirmed term changed → update the relevant repo's `CONTEXT.md` only when the owner command is itself allowed to write it, and only additively

Write each section as it finalizes, per conventions `## Write as you go`.

## Step 6: Assess downstream impact

Report what this revision just made stale. Do not rewrite any of it in this run.

| Edited | May now be stale |
| ------ | ---------------- |
| `epic.md` | `epic-architecture.md`, every `story-N.md`, and any assumption row cascaded out of `epic.md` |
| `epic-personas.md` | `epic-architecture.md` and every `story-N.md` |
| `epic-stretch-goals.md` | nothing in the active pipeline, unless a now-versus-later boundary moved |
| `epic-architecture.md` | every `story-N.md`, its own cascaded assumption rows, and every later stage for this epic |
| `story-N.md` | that story's `story-N-design.md`, its `story-N-acM.md` files, and every later stage for that story |
| `story-N-design.md` | that story's `story-N-acM.md` files, and every later stage for that story |
| `story-N-acM.md` | that criterion's `/a-implement` and `/a-check` runs, and that story's `a-finish` |

Also report, every run:
1. the artifact's row in `epic-progress.md` now lags the doc header; `/a-cont` refreshes its Status and Updated on its next run
1. every assumption row this revision re-statused, and where it now has to be settled
1. whether the owner command's success criteria still hold for the revised artifact

## Step 7: Present the revision

Summarize:
1. the artifact revised, with its absolute path
2. the exact issue addressed
3. the sections changed
4. story-order and assumption-ledger effects
5. any `CONTEXT.md` update applied
6. affected artifacts and suggested reruns
7. remaining conflicts or risks

Always print:

```text
Affected artifacts / suggested reruns:
- <artifact or none>: <why>
```

Ask the user to review the revision before advancing the pipeline again.

## Success Criteria

- [ ] the target resolved to a supported artifact type whose owner command file exists
- [ ] `conventions.md` and the owner command file were both read before the artifact was revised
- [ ] the owner command's required inputs and followed references were reloaded, or the run stopped with an exact path
- [ ] the guidance was addressed without broad regeneration
- [ ] no file the owner command is forbidden to write was written, and `epic-progress.md` was not touched
- [ ] no story number changed; any sequencing change landed in `epic.md`'s `## Story Order` or in `## Findings`
- [ ] every assumption row the revision disturbed was re-statused, never dropped; a `story`, `design` or `plan` revision left none `open` or `cascaded`
- [ ] canonical blocks kept one clause per line
- [ ] downstream impact and stale `epic-progress.md` evidence were reported explicitly
- [ ] the user was asked to review before the pipeline advanced

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **Unsupported artifact type** — print the Supported Targets table and stop
- **Owner command file missing** — name it and stop; NEVER infer its contract from the artifact
- **Guidance conflicts with canonical terminology or a recorded decision** — surface the conflict and ask before editing
- **Guidance too broad for a constrained revision** — recommend rerunning the owner command, and say why
- **Guidance would require application code** — stop; this command revises workflow artifacts only
