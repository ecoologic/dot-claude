---
description: Break down an idea into personas and actionable user stories
argument-hint: "<epic-slug> [details]"
allowed-tools: [Read, Write, Edit, AskUserQuestion, Skill, Bash(git rev-parse:*), Bash(date:*), Bash(git symbolic-ref:*), Bash(git branch:*)]
disable-model-invocation: true
---

# Epic

### Pipeline I/O

| Direction  | File                                      | Description                                                                                                      |
| ---------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **In**     | `~/.claude/commands/a-templates/conventions.md`     | Shared folder layout, path resolution, selector resolution, and vertical-slicing rules                          |
| **In**     | `$EPIC_DIR/epic-requirements.md`                       | Raw epic idea and links to supporting artifacts                                                                  |
| **In**     | `<repo>/CONTEXT.md`, per touched repo     | Existing naming baseline for that repo                                                                           |
| **Out**    | `$EPIC_DIR/epic.md`                       | Structured now-work story list plus epic-level domain concepts, requirements, UX framing, candidate terms, the touched-repo list, and a top-of-file UI design reference section for later stages |
| **Out**    | `$EPIC_DIR/epic-personas.md`                   | Personas, actors, and usage context for later stages                                                             |
| **Out**    | `$EPIC_DIR/epic-stretch-goals.md`              | Deferred later-scope stories kept separate from the main pipeline reading path                                   |

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. Skill: `ask-user-question`, for every question this command asks; each question stays within conventions `## Size caps`.

## Purpose

Turn a rough idea into a high-quality epic packet for the rest of the pipeline:
- `epic.md` defines the current story list, the touched repos, and the shape of the work
- `epic.md` preserves UI references near the top of the file so later stages can find and follow them immediately when the epic has UI
- `epic-personas.md` captures the actors, goals, and contexts that later commands must inherit
- `epic-stretch-goals.md` captures worthwhile later-scope ideas that no one needs to read for now

This command produces workflow artifacts only. It must not investigate the codebase or write implementation code.

For downstream commands, the source of truth shifts to the packet produced here:
1. `epic.md`
2. `epic-personas.md`
3. UI-facing design artifacts and references preserved near the top of `epic.md`
4. `epic-requirements.md` as the raw upstream input

Use this hierarchy per question, not per file. Do not resolve a whole run by deciding that one file wins globally.

Treat each inconsistency independently:
1. identify the exact statement, assumption, or requirement that conflicts
2. determine which source is stronger for that specific question
3. record the chosen interpretation and the rejected alternative
4. if the hierarchy does not clearly resolve it, or if the difference would materially change scope, behavior, or architecture, stop and ask the user about that specific inconsistency instead of choosing silently

## Rules

- NEVER write or modify application code, or create commits. Per conventions `## Path resolution`, write only inside `$EPIC_DIR`, except the memory file
- NEVER investigate the codebase for this step; rely on `epic-requirements.md` and its referenced product artifacts only
- NEVER define synonyms; if a term exists in a touched repo's `CONTEXT.md`, use its exact term everywhere
- NEVER abbreviate new names
- NEVER slice stories by technology layer
- NEVER write implementation details, API shapes, schema designs, or task-level work into `epic.md`
- NEVER reuse or renumber a story number; each number maps 1:1 to exactly one `## Story N` section in `epic.md` and exactly one future `story-N.md` file, per conventions `## Story numbers`
- produce `epic-personas.md` in this command so later stages inherit the same actors and usage context
- keep stretch goals out of `epic.md`; write them to `epic-stretch-goals.md` instead
- Per conventions `## Assumptions`, NEVER state an unverified claim as settled fact anywhere in `epic.md`; record it as a row instead and cite its ID where it matters
- Every Edit to a doc refreshes its `updated` header, per conventions `## Document header`

## Story canonical format

> _As a_ [role] \
> _I want_ [action] \
> _So that_ [benefit]

## What Is A User Story

> A user story is a short, plain-language description of a capability told from the perspective of someone who uses the system, not someone who builds it. It follows this structure:
>
> _As a_ [persona] \
> _I want_ [goal] \
> _So that_ [benefit]
>
> It describes what the user can do and why it matters, never how it is implemented. Each story should be small enough to complete in a single iteration, deliver standalone value, and be independently testable. The written story is a placeholder for a conversation, not a full specification. Good stories follow the INVEST criteria: Independent, Negotiable, Valuable, Estimable, Small, and Testable.

## What A User Story Is Not

> A user story is not a technical task or implementation detail. "As a developer, I want to create a DB table" is not a user story. Items like "set up an API endpoint," "refactor the auth module," or "add a database index" are technical tasks, not user stories. Slicing work by frontend, backend, and database instead of by vertical user value is an anti-pattern. A user story is also not a detailed spec. Not everything in a backlog needs to be a user story; purely technical work should use a different format.

## Story Quality Bar

A valid story:
- is written from the user or actor perspective
- delivers a cohesive vertical slice of value
- is small enough to implement independently
- can be reviewed and tested on its own

A bad story:
- is framed from the builder perspective
- exists only to create infrastructure
- bundles unrelated UI, backend, and data work without a single user outcome
- embeds technical design decisions that belong later in the pipeline

## Scope And Size Of A User Story

Stories should be small. Each CRUD operation should usually be at most one story.

Use these examples when deciding whether work should stay together or split apart:
- Creating a profile and uploading a profile picture are usually different stories because the image flow has different constraints and failure modes than basic profile fields.
- A single dropdown or text field can become its own story if it depends on separate business rules, data sources, or permissions that belong to another slice of work.
- A table column can become its own story when the data behind it depends on a different feature; the first story can ship the table without that column, and a later story can add it once the supporting feature exists.
- A profile does not need every field in the first story. For example, basic fields may ship first, while a more complex address flow or validation-heavy field can land in a later story.
- If a table cell should eventually link to a page that does not exist yet, one story can ship the table without the link and a later story can add the working navigation.
- If a page will eventually use tabs, the first story can still be a single-page flow or a one-tab version if that is the smallest coherent value.
- If it's a log table, each event might be a story, as it needs to be stored before we can display it

Work with low cohesion must be split into different stories even if it appears on the same screen.

### When And How To Split A Story

Ask these questions:
1. Is this shippable as a cohesive, complete, and usable slice of value?
2. Are all fields, views, and supporting elements required for this slice to make sense to the user?
3. Can this be reviewed and tested on its own without waiting for unrelated work?

It is OK to return to the same UI in a later story to add another field, interaction, or linked destination.

When several reasonable splits exist, prefer the smallest user-visible slice and ask the user to choose if the tradeoff is ambiguous.

## Step 0: Resolve the epic and its folder

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its `## Path resolution` and `## Where a command runs`.
1. This is a planning stage: it stops when started inside a worktree, and prints a one-line warning (then continues) on a non-default branch, per conventions `## Where a command runs`.
1. `$ARGUMENTS` = `<epic-slug> [details]`. `<epic-slug>` names the folder; it is never derived or guessed.
1. Resolve `<epic-slug>` per conventions `## Selector resolution`'s planning-stage row. Skill: `ask-user-question`.
1. `<epic-slug>` is new (no matching folder exists yet) → confirm it with the user before `$EPIC_DIR` is created, per conventions `## Selector resolution`. Skill: `ask-user-question`.
1. Resolve `$EPIC_DIR` = `$PLANNING_ROOT/<epic-slug>`. Print it. Create it when it does not exist.
1. `$EPIC_DIR/epic-requirements.md` exists → read it whole. Missing and `[details]` was given → create it from `~/.claude/commands/a-templates/epic-requirements.md`, with `[details]` verbatim as the idea. Missing and no `[details]` → stop, print the exact path `$EPIC_DIR/epic-requirements.md`, and ask for the idea. Skill: `ask-user-question`.
1. Resolve the issue key from `epic-requirements.md`'s `Issue key:` line. NEVER ask for it. No line → `none`. A value that fails `^[A-Z][A-Z0-9]+-[0-9]+$` → stop and report it.
1. `epic.md` does not yet exist → create it from `~/.claude/commands/a-templates/epic.md`. It exists but carries no header → add one now, per conventions `## Document header`. Either way, Edit it only from here on; NEVER recreate it. Edit its `issue-key` header line with the value above.
1. Follow `epic-requirements.md`'s references to supporting materials. An unreadable reference → report it and Edit a new `open` row into `epic.md`'s `## Assumptions`.
1. Identify UI-facing referenced artifacts. Edit them into `epic.md`'s `## UI Design References`, or `- None`.

Output:
```text
Epic slug: <epic-slug>
Epic dir: <EPIC_DIR>
Issue key: <issue key; none when epic-requirements.md names none>
Idea source: <written from details | read from epic-requirements.md>
Referenced artifacts: <list or none>
UI references found: <list or none>
```

## Step 1: Confirm the touched repos

1. Ask the user which sibling repos this epic touches. An epic may span several. Skill: `ask-user-question`.
1. Each named repo must exist as a sibling of `$PLANNING_ROOT`, at `<PLANNING_ROOT's parent>/<repo>`. A repo that does not exist there → stop and ask again. Skill: `ask-user-question`.
1. Read `./CONTEXT.md` in each confirmed repo, when present, to reuse existing terms instead of coining new ones.
1. Edit `epic.md`'s `## Repos` with the confirmed list.
1. Record the confirmed repos in memory now, per conventions `## Memory`, so every later command defaults to them.

## Step 2: Create personas

Derive the actors and usage contexts needed to reason about the epic. `epic-personas.md` missing → create it from `~/.claude/commands/a-templates/epic-personas.md`. It exists but carries no header → add one now, per conventions `## Document header`. Either way, Edit in each persona, `## Shared Constraints`, and `## References` as they are settled.

Only include personas that matter to the epic. Avoid speculative future roles.

## Step 3: Draft the stories

Split the work into minimal, user-facing stories. A skill about UX or interaction design applies when shaping story boundaries. For each draft story:
- use canonical format
- include a brief user context
- include requirements only when they are truly part of the user-facing outcome
- assess prerequisites or dependencies between stories, from the product inputs alone; a dependency the product inputs do not confirm → Edit a new `open` row into `epic.md`'s `## Assumptions` immediately

Display each draft story's title and canonical statement as an early discussion point for ambiguous story boundaries or assumptions.

Story numbers are not assigned yet; Step 4 assigns one only once a story is classified `Actionable` or `Blocked`, so the numbered sections in `epic.md` stay contiguous. `/a-architecture` may still revise `## Story Order` once it knows implementation reality, but NEVER a story's number.

## Step 4: Classify and write the stories

Classify each draft story as:
1. **Actionable** — can be taken into architecture and detailed breakdown now
2. **Blocked** — depends on another story or a prerequisite not yet available
3. **Nice to have** — valid but not essential for the epic's first valuable iteration

Display the classification table for discussion, then discuss the proposed personas, story list, classification split, and the assumption ledger with the user. Skill: `ask-user-question`.

Put every assumption to the user one at a time, with what it affects and what changes if it is false. Skill: `ask-user-question`. A row the user settles is `resolved`, in their words; Edit that status into `epic.md`'s `## Assumptions` immediately. A row they cannot settle stays `open` and cascades to `/a-architecture`; Edit it in the same way.

If inconsistencies remain, present them one by one. For each one, show:
- what conflicts
- option A
- option B
- which option the hierarchy favors
- why it matters to story shape or scope

Skill: `ask-user-question`. Edit each resolved inconsistency into `epic.md`'s `## Resolved Source-of-Truth Decisions` the moment it resolves, or `- None` if none arise.

Ask the user to confirm or adjust this proposed scope before continuing. Skill: `ask-user-question`.

Once a story's classification is confirmed:
- `Actionable` or `Blocked` → assign it the next integer story number, in ascending order; that number is the story's permanent identity and NEVER changes again. Edit its `## Story N: <title>` section into `epic.md` immediately, with its canonical statement, `### User Context`, and `### Dependencies`
- `Nice to have` → gets no story number. `epic-stretch-goals.md` missing → create it from `~/.claude/commands/a-templates/epic-stretch-goals.md` on the first one; exists but carries no header → add one now, per conventions `## Document header`. Either way, Edit its `## Stretch Goal N: <title>` section in immediately

Once every story is classified and written, Edit `epic.md`'s `## Story Order` with every `Actionable` and `Blocked` story, in execution order.

## Step 5: Fill epic.md's domain-level sections

Edit into `epic.md`, one section at a time as each settles:
- `## Domain Concepts` — domain concepts inferred from the idea and referenced product artifacts only, never the codebase
- `## Requirements` — cross-story requirements that shape the whole epic
- `## UX Considerations` — epic-level UX constraints or interaction expectations shared across stories
- `## References` — every reference `epic-requirements.md` named, plus any this step adds

`epic.md`'s full shape and per-section rules are `~/.claude/commands/a-templates/epic.md`.

## Step 6: Confirm epic-stretch-goals.md

`epic-stretch-goals.md` already exists, from Step 4, when any `Nice to have` story was found → keep it and Edit only. No `Nice to have` stories were found and it still does not exist → create `$EPIC_DIR/epic-stretch-goals.md` from `~/.claude/commands/a-templates/epic-stretch-goals.md` now, per its own Rule 1.

## Step 7: Record candidate terms

This step never reads or investigates the codebase, so it never confirms a term against a repo's `CONTEXT.md`; that is `/a-architecture`'s terminology reconciliation job, per conventions `## Terminology`.

Edit `epic.md`'s `## Candidate Terms` with every durable product term this run coined that is not yet confirmed in a touched repo's `CONTEXT.md`, one bullet each with a short definition. No such term → `- None`.

## Step 8: Present to user

Check `epic.md`, `epic-personas.md`, and `epic-stretch-goals.md` each against their own template in `~/.claude/commands/a-templates/`; Edit in any section still missing or empty in any of them.

Summarize:
1. story count by classification
2. recommended starting story
3. personas created
4. whether `epic-stretch-goals.md` was created and how many items it contains
5. the assumption ledger: every row, its status, and which rows leave this step `open`
6. any candidate terms recorded in `epic.md`'s `## Candidate Terms`

Tell the user that the main review path is `epic.md` plus `epic-personas.md`, and that `epic-stretch-goals.md` is optional for now.

Invite final feedback on the generated artifacts before moving to `/a-architecture`. Skill: `ask-user-question`. Do not use this step as the primary scope discussion gate.

On the user's approval, Edit `epic.md`'s header to `status: done`, per conventions `## Write as you go`. `epic-personas.md` and `epic-stretch-goals.md` carry no `status` key, per conventions `## Document header`.

## Success Criteria

- [ ] `epic.md` exists at `$EPIC_DIR/epic.md`
- [ ] `epic-personas.md` exists at `$EPIC_DIR/epic-personas.md`
- [ ] `epic-stretch-goals.md` exists at `$EPIC_DIR/epic-stretch-goals.md`
- [ ] all required inputs and followed references were validated before execution continued
- [ ] every story uses canonical _As a / I want / So that_ format
- [ ] every story includes `### User Context` and `### Dependencies` sections
- [ ] every actionable or blocked story in `epic.md` has a unique story number, appears exactly once under its own `## Story N` heading, and maps to exactly one future `story-N.md` file
- [ ] `epic.md` contains `## Story Order`, listing every actionable and blocked story exactly once
- [ ] stories are sliced by user value, not by tech layer
- [ ] `epic.md` does not include numbered acceptance criteria; `/a-story` owns acceptance-criteria drafting
- [ ] `epic.md` contains only `Actionable` and `Blocked` stories
- [ ] `Nice to have` stories, if any, were written only to `epic-stretch-goals.md`
- [ ] every touched repo is listed in `## Repos`
- [ ] UI-facing references from the inputs were preserved near the top of `epic.md` in `## UI Design References`, or `- None` was written explicitly
- [ ] resolved inconsistencies, if any, were persisted in `epic.md` under `## Resolved Source-of-Truth Decisions`, or `- None` was written explicitly
- [ ] every durable term this run surfaced but did not confirm is a row in `epic.md`'s `## Candidate Terms`, or `- None` was written explicitly
- [ ] no synonyms were introduced
- [ ] the user reviewed the proposed story set and the assumption ledger before scope was confirmed
- [ ] every claim this step acted on without evidence is a row in `epic.md`'s `## Assumptions`, with an `A-EPIC-<n>` ID, a status, and no prose restating it
- [ ] the confirmed repos are recorded in memory, per conventions `## Memory`
- [ ] each doc was created from its template at first write and Edited section by section as it settled; the final step checked all three docs against their templates and set `status: done` on `epic.md` only on the user's approval

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **Weak input** — say what is missing, record each assumption as its own `## Assumptions` row, and ask the user instead of inventing certainty
