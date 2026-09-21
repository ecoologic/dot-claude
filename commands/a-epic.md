---
description: Break down an idea into personas and actionable user stories
argument-hint: "<epic-slug> [details]"
allowed-tools: [Read, Write, Edit, AskUserQuestion, Skill]
disable-model-invocation: true
---

# Epic

### Pipeline I/O

| Direction  | File                                      | Description                                                                                                      |
| ---------- | ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| **In**     | `~/.claude/commands/a-templates/conventions.md`     | Shared folder layout, path resolution, selector resolution, and vertical-slicing rules                          |
| **In**     | `$EPIC_DIR/idea.md`                       | Raw epic idea and links to supporting artifacts                                                                  |
| **In**     | `<repo>/CONTEXT.md`, per touched repo     | Existing naming baseline for that repo                                                                           |
| **Out**    | `$EPIC_DIR/epic.md`                       | Structured now-work story list plus epic-level ERD, requirements, UX framing, the touched-repo list, and a top-of-file UI design reference section for later stages |
| **Out**    | `$EPIC_DIR/personas.md`                   | Personas, actors, and usage context for later stages                                                             |
| **Out**    | `$EPIC_DIR/stretch-goals.md`              | Deferred later-scope stories kept separate from the main pipeline reading path                                   |

`$EPIC_DIR` resolves per `~/.claude/commands/a-templates/conventions.md`.

## Skills

Discover and invoke project skills per `~/.claude/commands/a-templates/conventions.md`. A skill about UX or interaction design applies when shaping story boundaries.

## Purpose

Turn a rough idea into a high-quality epic packet for the rest of the pipeline:
- `epic.md` defines the current story list, the touched repos, and the shape of the work
- `epic.md` preserves UI references near the top of the file so later stages can find and follow them immediately when the epic has UI
- `personas.md` captures the actors, goals, and contexts that later commands must inherit
- `stretch-goals.md` captures worthwhile later-scope ideas that no one needs to read for now

This command produces workflow artifacts only. It must not investigate the codebase or write implementation code.

For downstream commands, the source of truth shifts to the packet produced here:
1. `epic.md`
2. `personas.md`
3. UI-facing design artifacts and references preserved near the top of `epic.md`
4. `idea.md` as the raw upstream input

Use this hierarchy per question, not per file. Do not resolve a whole run by deciding that one file wins globally.

Treat each inconsistency independently:
1. identify the exact statement, assumption, or requirement that conflicts
2. determine which source is stronger for that specific question
3. record the chosen interpretation and the rejected alternative
4. if the hierarchy does not clearly resolve it, or if the difference would materially change scope, behavior, or architecture, stop and ask the user about that specific inconsistency instead of choosing silently

## Rules

- NEVER write or modify application code, create commits, or write files outside `$EPIC_DIR`
- NEVER investigate the codebase for this step; rely on `idea.md` and its referenced product artifacts only
- NEVER define synonyms; if a term exists in a touched repo's `CONTEXT.md`, use its exact term everywhere
- NEVER abbreviate new names
- NEVER slice stories by technology layer
- NEVER write implementation details, API shapes, schema designs, or task-level work into `epic.md`
- NEVER reuse a story number, place multiple stories under the same numbered heading, or represent one numbered story across multiple files; each story number must map 1:1 to exactly one `## Story N` section in `epic.md` and exactly one future `story-N.md` file
- NEVER change a story number once assigned; the number is identity, not sequence. Execution order lives in `## Story Order`, and that list is the only ordering a later stage may revise
- produce `personas.md` in this command so later stages inherit the same actors and usage context
- keep stretch goals out of `epic.md`; write them to `stretch-goals.md` instead
- NEVER state an unverified claim as settled fact anywhere in `epic.md`; record it as a row in `## Assumptions` and cite its ID where it matters

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

When several reasonable splits exist, prefer the smallest user-visible slice and ask the user to choose before writing outputs if the tradeoff is ambiguous.

## Step 0: Resolve the epic and its folder

1. Read `~/.claude/commands/a-templates/conventions.md`. Follow its path resolution and selector resolution.
1. `$ARGUMENTS` = `<epic-slug> [details]`. `<epic-slug>` names the folder; it is never derived or guessed.
1. No `<epic-slug>` in `$ARGUMENTS` → fall through selector resolution: memory, then stop and ask.
1. Resolve `$EPIC_DIR` = `$PLANNING_ROOT/<epic-slug>`. Create it when it does not exist.
1. Record `<epic-slug>` as the current epic in memory now, so every later command defaults to it.
1. `$EPIC_DIR/idea.md` exists → read it whole, follow its references to supporting materials, and report any unreadable reference.
1. `$EPIC_DIR/idea.md` is missing and `[details]` was given → write `$EPIC_DIR/idea.md` from `[details]` verbatim, then continue.
1. `$EPIC_DIR/idea.md` is missing and no `[details]` was given → stop, print the exact path `$EPIC_DIR/idea.md`, and ask for the idea.
1. Identify UI-facing referenced artifacts. Preserve every relevant UI reference in `epic.md` for later commands.

Output:
```text
Epic slug: <epic-slug>
Epic dir: <EPIC_DIR>
Idea source: <written from details | read from idea.md>
Referenced artifacts: <list or none>
UI references found: <list or none>
```

## Step 1: Confirm the touched repos

1. Ask the user which sibling repos this epic touches. An epic may span several.
1. Each named repo must exist as a sibling of `$EPIC_DIR`'s grandparent, at `$(dirname "$PLANNING_ROOT")/<repo>`. A repo that does not exist there → stop and ask again.
1. Read `./CONTEXT.md` in each confirmed repo, when present, to reuse existing terms instead of coining new ones.
1. Carry the confirmed repo list into `epic.md` in Step 5.

## Step 2: Create personas

Derive the actors and usage contexts needed to reason about the epic. Write `$EPIC_DIR/personas.md`.

Use this structure:

```md
# <Epic Name> Personas

> Epic: <epic-slug>

## Persona 1: <name>
- Role: ...
- Primary goals: ...
- Current pain points: ...
- Context of use: ...
- Permissions or constraints: ...

## Persona 2: <name>
...

## Shared Constraints
- ...

## References
- ...
```

Only include personas that matter to the epic. Avoid speculative future roles.

## Step 3: Break the epic into stories

Split the work into minimal, user-facing stories. For each story:
- use canonical format
- assign a unique integer story number exactly once, in ascending order, with one story per numbered section; that number is the story's permanent identity and NEVER changes again
- include a brief user context
- include requirements only when they are truly part of the user-facing outcome
- assess prerequisites or dependencies between stories, from the product inputs alone, and record each one in that story's `### Dependencies`; `/a-architecture` may still revise `## Story Order` once it knows implementation reality, but NEVER the numbers

Before writing files, display each story title and canonical statement. Use this as an early discussion point for ambiguous story boundaries or assumptions.

## Step 4: Classify the stories

Classify each story as:
1. **Actionable** — can be taken into architecture and detailed breakdown now
2. **Blocked** — depends on another story or a prerequisite not yet available
3. **Nice to have** — valid but not essential for the epic's first valuable iteration

Display the classification table before writing outputs.

Before writing `epic.md`, `personas.md`, or `stretch-goals.md`, present the proposed personas, story list, classification split, and the assumption ledger to the user.

Put every assumption to the user one at a time, with what it affects and what changes if it is false. A row the user settles is `resolved`, in their words; a row they cannot settle stays `open` and cascades to `/a-architecture`.

If inconsistencies remain, present them one by one. For each one, show:
- what conflicts
- option A
- option B
- which option the hierarchy favors
- why it matters to story shape or scope

Persist every resolved inconsistency in `epic.md` under the same section structure described below so later stages can learn from prior decisions instead of re-litigating them.

Ask the user to confirm or adjust this proposed scope before continuing to the write steps.

Treat `Nice to have` stories as stretch goals. Do not include them in the main story list in `epic.md`.

## Step 5: Write `epic.md`

Write `$EPIC_DIR/epic.md` with this structure:

```md
# <Epic Name> (<epic-slug>)

> Epic: <summary>

## Repos
- One line per touched repo, with its path relative to the dev root
- If only one repo, still list it

## Story Order
- The epic's execution sequence, one line per story: `1. Story <n> — <title>`
- This section, NOT the story numbers, is the authoritative order; the `## Story N` sections below may sit in any order
- List every `Actionable` and `Blocked` story exactly once
- A later stage revises this list; it NEVER renumbers a story

## UI Design References
- Every UI-facing reference later stages should read directly, with its type (eg: Lovable), exact path or URL plus a brief note about what it covers.
- If there is a primary design file, list it first and label it clearly
- If none exist, write `- None`

## Resolved Source-of-Truth Decisions
- Use this section only for inconsistencies that were actually resolved during this step
- Record each resolved inconsistency as its own item using this shape:
  - Question: ...
  - Option A: ...
  - Option B: ...
  - Chosen: ...
  - Basis: which source won for this specific question, and why
  - Impact: how the decision changed story scope, boundaries, or wording
- If no inconsistencies were resolved, write `- None`

## Story 1: <title>

> _As a_ [role] \
> _I want_ [action] \
> _So that_ [benefit]

### User Context
- User Role: ...
- User Goals: ...
- Use Case: ...

### Dependencies
- ...

## Story 2: <title>

...

## Draft ERD from inputs
- Infer from the idea and product artifacts a draft ERD for the epic as a whole
- Keep this at the document level, not inside any single story
- Provide domain classes and user-visible fields only (for example, no ids unless the inputs explicitly show them)
- Do not look at the codebase to determine fields; derive them from the idea and referenced product artifacts only

## Requirements
- Cross-story requirements that shape the whole epic

## UX Considerations
- Epic-level UX constraints or interaction expectations shared across stories

## Assumptions
| ID | Assumption | Why It Matters | Status | Evidence or Decision |
| --- | --- | --- | --- | --- |

- One row per claim this step acted on without evidence, per `~/.claude/commands/a-templates/conventions.md`'s Assumptions rule
- ID is `EPIC-<n>`, assigned once and NEVER reused
- Every unresolved scope question, ambiguous split, or weak assumption left after discussion with the user is a row here, `open` — NEVER prose
- This step reads no code, so it settles a row only with the user, as `resolved`. Everything else leaves `open` for `/a-architecture` to inherit
- No rows when this step assumed nothing

## References
- ...
```

Include only `Actionable` and `Blocked` stories in `epic.md`. Exclude all `Nice to have` stories from this file.
When UI references exist, include all of them in `epic.md`, even if only some stories use each reference.
List every touched repo in `## Repos`, even when there is only one.
Place `## Repos` immediately after the epic summary, `## Story Order` after `## Repos`, `## UI Design References` after that, and `## Resolved Source-of-Truth Decisions` immediately after that, so later stages can find them near the top.
Ensure the numbered story sections are unique and contiguous within `epic.md` so later stages can resolve `Story N` to one story only and one corresponding `story-N.md` file. Ensure `## Story Order` lists every one of them exactly once.

## Step 6: Write `stretch-goals.md`

Write `$EPIC_DIR/stretch-goals.md` with this structure:

```md
# <Epic Name> Stretch Goals

> Epic: <epic-slug>
> Purpose: Deferred later-scope stories that are explicitly not required reading for the current pipeline stage.

## How To Use This File
- Treat this as parking lot scope for later review.
- Do not assume later commands must read this file unless the user explicitly asks for it.

## Stretch Goal 1: <title>

> _As a_ [role] \
> _I want_ [action] \
> _So that_ [benefit]

### Why Later
- ...

### Dependencies or Enablers
- ...

## Stretch Goal 2: <title>

...

## References
- ...
```

If there are no stretch goals, still create the file and say so clearly.

## Step 7: Update repo terminology

If this step reveals durable product terms that later stages must reuse, update `./CONTEXT.md` in the relevant touched repo.

Rules:
- never remove entries
- never rename an existing term without explicit user approval
- a term may carry no code name or source yet, when the codebase has not been investigated

## Step 8: Present to user

Summarize:
1. story count by classification
2. recommended starting story
3. personas created
4. whether `stretch-goals.md` was created and how many items it contains
5. the assumption ledger: every row, its status, and which rows leave this step `open`
6. any `CONTEXT.md` entries added, per repo

Tell the user that the main review path is `epic.md` plus `personas.md`, and that `stretch-goals.md` is optional for now.

Invite final feedback on the generated artifacts before moving to `/a-architecture`. Do not use this step as the primary scope discussion gate.

## Success Criteria

- [ ] `epic.md` exists at `$EPIC_DIR/epic.md`
- [ ] `personas.md` exists at `$EPIC_DIR/personas.md`
- [ ] `stretch-goals.md` exists at `$EPIC_DIR/stretch-goals.md`
- [ ] all required inputs and followed references were validated before execution continued
- [ ] every story uses canonical _As a / I want / So that_ format
- [ ] every story includes `### User Context` and `### Dependencies` sections
- [ ] every actionable or blocked story in `epic.md` has a unique story number, appears exactly once under its own `## Story N` heading, and maps to exactly one future `story-N.md` file
- [ ] `epic.md` contains `## Story Order`, listing every actionable and blocked story exactly once
- [ ] stories are sliced by user value, not by tech layer
- [ ] `epic.md` does not include numbered acceptance criteria; `/a-story` owns acceptance-criteria drafting
- [ ] `epic.md` contains only `Actionable` and `Blocked` stories
- [ ] `Nice to have` stories, if any, were written only to `stretch-goals.md`
- [ ] every touched repo is listed in `## Repos`
- [ ] UI-facing references from the inputs were preserved near the top of `epic.md` in `## UI Design References`, or `- None` was written explicitly
- [ ] resolved inconsistencies, if any, were persisted in `epic.md` under `## Resolved Source-of-Truth Decisions`, or `- None` was written explicitly
- [ ] any durable new terms were added to the relevant repo's `CONTEXT.md`
- [ ] no synonyms were introduced
- [ ] the user reviewed the proposed story set and the assumption ledger before outputs were written
- [ ] every claim this step acted on without evidence is a row in `## Assumptions`, with an ID, a status, and no prose restating it
- [ ] the epic slug is recorded in memory

## Error Handling

When stopping due to a missing, unreadable, or malformed input:
1. Print the exact absolute path that was checked
2. Print which step of this command failed (step number and name)

- **Weak input** — say what is missing, record each assumption as its own `## Assumptions` row, and ask the user instead of inventing certainty
