---
description: "Template: the per-criterion procedure every /a-plan planning subagent follows"
disable-model-invocation: true
---

# Plan procedure template

`/a-plan` Step 2 hands this file to each planning subagent. The subagent reads it with conventions.md, and never reads `a-plan.md`.

## Per-criterion procedure

A planning subagent follows this section for ONE criterion. It has no access to the main conversation. It NEVER asks the user, NEVER writes `story-<story-number>.md`, and NEVER assigns an assumption ID. It writes only `story-<story-number>-ac-<criterion-number>.md`, per conventions `## Write as you go`.

### P1: Start the plan

1. Read conventions.md, `story-ac.md`, `story-<story-number>.md`, `story-<story-number>-design.md` and `epic.md`
1. Extract the criterion from `story-<story-number>.md`'s `## Acceptance Criteria`, verbatim
1. No plan on disk → create `story-<story-number>-ac-<criterion-number>.md` from the template with `status: draft`
1. Copy the design's `> Skills:` line into the plan's `> Skills:` line, per conventions `## Skills`
1. The plan's `branch` header is `-` or missing → set it now, per conventions `## Criterion branches`, with an AC slug per conventions `## Selector resolution`. A set `branch` NEVER changes

### P2: Reconcile the criterion against the codebase

The design already explored the story. This step checks only what this criterion touches: search around the criterion's own area, never the whole repo.

Read `story-<story-number>.md`'s `## Findings` and factor every confirmed finding into the plan. NEVER apply one upstream.

Resolve these before any step is written:
1. Which files will actually change
1. Whether supporting tests are required
1. Whether planned paths need adjustment to match real repo conventions
1. Which criteria of this story must land first: each is a parent. A parent may carry a higher number than this criterion

Then resolve the other dependencies. A dependency on another story is verified in the codebase.

1. The criterion conflicts with the codebase or the design in a way that changes scope → return it as a design gap
1. The criterion is underspecified but safely completable → return the interpretation as an assumption row, and keep the plan minimal
1. A dependency the codebase cannot verify → return it as a question

Write `## Criterion` now, with its `### Outcome` and `### Dependencies` subsections. Each parent is an `AC <criterion-number>` line, per the template.

### P3: List the files

One row per file, with its exact path, marked `create` or `edit`, and one clause on what changes in it.

1. Every path comes from `story-<story-number>-design.md`'s `## File Structure`, reconciled with P2
1. A path the design names that this criterion does not touch stays out; it belongs to another criterion
1. The design's paths contradict the repo's real conventions → correct the path here, and return it as an assumption row
1. The design is wrong in a way that changes this criterion's scope → return it as a design gap. NEVER silently plan around it

Write `## Files` now.

### P4: Copy the contracts

Copy the exact signatures, types, names, routes, schema and migrations this criterion implements, VERBATIM from `story-<story-number>-design.md`.

1. Copy only the contracts this criterion touches
1. NEVER paraphrase one, NEVER rename one, NEVER complete a partial one
1. The criterion needs a contract the design does not carry → return exactly what is missing as a design gap
1. A contract the design marks `TODO` is still `TODO` here. It is a gap, not a licence to invent

Write `## Contracts` now.

### P5: Order the steps

Numbered, in execution order, each one a coherent slice of the criterion.

1. The plan delivers the criterion through every layer it touches, per conventions `## Vertical slicing`. NEVER phase it by layer
1. A step may be story-coherent rather than artificially isolated. A step needing a new type, validation or helper to satisfy the slice keeps it in the same step
1. Every step names its files, its type, what it does, and the contract from `## Contracts` it implements
1. Mark a step `independent` ONLY when it shares no file with any other step in this plan. Exactly one step owns each file
1. A step marked `independent` carries every path, name and signature it needs in its own description. It runs in a subagent with no access to this conversation
1. A shared file — an index, a route table, a migration list, a barrel export — is owned by ONE step, and that step is never `independent`
1. Split a step only when it is too big to execute in one pass, NEVER to create false parallelism

Write `## Steps` now.

### P6: Name the tests

The spec lines this criterion must make pass.

1. Take them from `story-<story-number>-design.md`'s `## Happy Path Automated Tests`, verbatim, and keep only the lines this criterion covers
1. Add the error, edge and security lines this criterion's _Given_ / _When_ / _Then_ names, in the repo's own test format
1. Name the test file each line lives in, marked `create` or `edit`, matching `## Files`
1. The repo has no testing pattern for this area → say so in one clause, and name the manual check instead

Write `## Tests` now.

### P7: Find the verification commands

Per repo this criterion touches, find the test, lint, type and build commands.

1. Read, in order: the repo's `CLAUDE.md` (root and package level), `CONTRIBUTING.md`, `README.md`, then `package.json` scripts, `Makefile`, and CI files. The first source that names a command for a check wins
1. Record each command exactly as its source writes it, with the result that counts as a pass, and the source file
1. No command found for a check → `- None` for it. Return it as a risk
1. The criterion's _Then_ shows in a browser → add the `browser` row last, per the template: the command that starts the app, found the same way, and `### Browser` with the URL and the _Given_ / _When_ / _Then_ as browser steps. Otherwise no `browser` row

Write `## Verification` now.

### P8: Bound the scope

The explicit NEVERs for this plan. Every plan carries at least these:

1. `NEVER implement another criterion of this story`, naming each one by number and title
1. `NEVER broaden scope into unrelated cleanup or an opportunistic refactor`
1. `NEVER run any git command from a step marked independent`
1. Anything the design, the story or this run's guidance explicitly rules out

Write `## Out Of Scope` now.

### P9: Draft the assumption rows

Per conventions `## Assumptions`.

1. Cite by ID every row `story-<story-number>-design.md` carries that this criterion depends on. NEVER renumber one, NEVER drop one by omission. Write those citations into `## Assumptions` now
1. Draft a row, with no ID, for every claim this plan acts on without evidence: a corrected path, an interpretation of an underspecified criterion, an unverified dependency, a guessed repo convention
1. P2 already checked the criterion's own area. Mark each drafted row `verified` or `invalidated`, citing the file, line or test. A row the code cannot settle stays `open`
1. An `invalidated` row already baked into `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` also becomes a finding

Return the drafted rows. NEVER write them into the plan.

### P10: Check the plan

Read `story-ac.md` and follow it exactly. Its command frontmatter is not part of the document; the header inside `## Shape` is. Check the doc against the template and Edit in only missing sections, per conventions `## Write as you go`.

Rules for the plan artifact:
- the reader has no access to this conversation, to the design document, or to the story. Every path, name and signature it needs is in the plan
- every path is real, or is marked `create`
- every contract is copied from the design, never restated in other words
- text the plan tells the implementer to write into code, comments or user-facing copy follows conventions `## Workflow jargon`
- NEVER record how the plan got here. The design's `## Decision Registry` holds that
- NEVER write waves, task packets, subagent prompts, model tables or effort tables into the plan

### Return

```text
Criterion: <criterion-number>
Plan: <absolute path>
Parents: <AC numbers, or none>
Assumption rows: <one per line: claim | why it matters | status | evidence>
Design gaps: <one per line, or none>
Questions: <one per line, or none>
Findings: <one per line: target doc | finding | suggested change, or none>
Risks: <verification checks with no command, or none>
```
