---
description: Implement one acceptance criterion in the codebase with focused validation
argument-hint: "<story-number> <criterion-number> [\"instructions-or-suggestions\"]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, Agent, AskUserQuestion, Skill]
---

# Criterion Implementation

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In/Out** | `./planning/<epic-slug>/story-<story-number>.md` | Story context, completion status, acceptance criteria, and execution tasks; update only the selected criterion's state |
| **In** | `./planning/architecture/<epic-slug>.md` | Epic-specific architecture and constraints |
| **In/Out** | `./planning/glossary.md` | Shared naming baseline; update only with durable confirmed names |
| **Conditional In/Out** | `./planning/global-architecture.md` | Read/update only when implementation reveals durable cross-epic structure |
| **Out** | codebase | Code changes, tests, and implementation artifacts |

## Skills

Invoke when relevant:
- `ecoologic-code` before writing or modifying application code
- `react-best-practices` for React components
- `ux-laws` for user-facing interaction flows
- `explore` for tightly scoped discovery in multiple code areas
- All relevant project-specific rules and skills

## Rules

- NEVER start coding before loading the selected criterion, the epic architecture, and the glossary
- NEVER implement a different acceptance criterion than the one requested
- NEVER confuse the acceptance-criterion selector with the implementation tasks listed under it
- NEVER broaden scope into unrelated cleanup, opportunistic refactors, or the next acceptance criterion
- NEVER define synonyms; if a glossary term exists, use its canonical name
- NEVER propose speculative abstractions or extractions for future use
- NEVER mention epic, story, acceptance criteria, AC, or similar workflow jargon in code comments, user-facing copy, or committed implementation text; use plain language that still makes sense later without process context
- NEVER introduce in comments or UI outdated history context that refers to implementation detail changes eg: The rename of a model
- NEVER rewrite workflow artifacts without a durable reason
- NEVER update any story file except `./planning/<epic-slug>/story-<story-number>.md`
- NEVER create commits or auto-chain into the next criterion
- Prefer existing code patterns, file placement conventions, and interfaces over inventing new ones
- Internal implementation tasks are execution guidance, not separate command entrypoints
- Implementation tasks may be story-coherent rather than artificially isolated; if the criterion needs a full table, all story-relevant fields belong in scope
- Add or update tests when the repo already has a relevant testing pattern and the criterion changes behavior
- Run the smallest meaningful validation that can prove the criterion works
## Step 1: Resolve required inputs

`$ARGUMENTS` = `<story-number> <criterion-number> [instructions-or-suggestions]`

Two required numeric arguments. Remaining text is optional high-priority guidance. Epic comes from `./planning/current.json`. Stop if missing or malformed.

Read (stop if any are missing):
- `./planning/<epic-slug>/story-<story-number>.md`
- `./planning/<epic-slug>/architecture.md`
- `./planning/glossary.md`

Follow all references from workflow artifacts. Stop and report any unreadable reference.

When `story-<story-number>.md` contains a `UI References` section, read and follow those references before implementing UI behavior.

Extract from the story file:
- `## Status` and completion marker
- The numbered acceptance criterion `<criterion-number>. [ ] ...`
- The matching `### Acceptance Criterion <criterion-number>` section from `## Execution Process` (if missing, report malformed file and stop)
- Criterion outcome, files likely to change, dependencies, implementation tasks, notes

If the criterion is not found, list available criterion numbers and stop.

If `Dependencies` is not `none`, verify the prerequisite exists in the codebase or ask before proceeding.

Before editing code, confirm the required workflow artifacts were reviewed and approved by the user in this conversation.

## Step 2: Investigate and reconcile

Inspect the criterion's listed files, nearest collaborating code, and current patterns. Use targeted search only around the criterion's area — no broad exploration.

Before editing, resolve:
1. Which files will actually change
2. Whether supporting tests are required
3. Whether planned paths need adjustment to match real repo conventions
4. Whether the criterion can be completed without pulling in another criterion

If the criterion conflicts with the codebase or architecture in a way that changes scope, stop and ask. If it's underspecified but safely completable, document your interpretation and keep the change minimal. If it requires another criterion first, stop and report the dependency.

## Step 3: Implement the criterion

Invoke `ecoologic-code` before making application code changes. Invoke language/UI-specific skills when relevant.

Implement by:
1. Modifying only the files required, plus minimal supporting files (tests, wiring)
2. Preserving existing working behavior outside scope
3. Following codebase naming and placement conventions
4. Keeping abstractions criterion-justified, not future-proofed
5. Using implementation tasks as work organization, not separate stopping points
6. Writing only durable comments that describe behavior or business rules directly — never reference workflow artifacts

If a listed path doesn't exist, create it only if architecture and conventions confirm it's correct; otherwise follow the nearest valid convention.

If part of the criterion is already implemented, reuse it and finish only the missing coverage.

## Step 4: Validate

Run the smallest meaningful verification first:
1. Targeted tests for the changed module/component/endpoint
2. Targeted lint, format, or type checks when available
3. Broader checks only when focused checks are insufficient

If failure is in scope: fix, rerun, repeat. If failure is pre-existing/unrelated: report the command and failure, explain why it's out of scope. If no automated validation exists, state this and review the code against the acceptance criteria manually.

After targeted validation passes, run the full test suite. If a failure is caused by this criterion's changes: fix it. If pre-existing or unrelated: report it but do not block completion.

On merge conflicts, invoke `conflict-resolution` and continue only if criterion scope remains intact.

## Step 5: Update story progress

After validation passes, update only `./planning/<epic-slug>/story-<story-number>.md`:

1. In `## Acceptance Criteria`, check only the selected criterion
2. In `## Execution Process`, check only completed tasks under `### Acceptance Criterion <criterion-number>`
3. If every acceptance criterion is now checked, set `## Status` to `- [x] Story complete`; otherwise ensure it remains `- [ ] Story complete`
4. If `## Status` is missing, add it near the top before applying state

Do not mark complete if validation is failing or implementation is partial.

## Step 6: Apply durable workflow updates

Update workflow artifacts only when implementation reveals durable knowledge for later work:
- `architecture.md` — epic-specific technical truth later criteria should inherit
- `glossary.md` — confirmed domain terms, code names, sources, or statuses
- `global-architecture.md` — cross-epic structure, boundaries, contracts

Do not push debugging notes, silently rename glossary terms, rewrite tasks because implementation was hard, or backfill speculative future work.

## Step 7: Present the result

Summarize: files changed, criterion covered, validation result, story progress updates, workflow updates, blockers or risks, whether another criterion is unblocked.

## Error Handling

@include includes/error-protocol.md
