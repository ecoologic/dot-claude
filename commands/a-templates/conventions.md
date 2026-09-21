---
description: "Template: shared conventions every a-* command follows"
disable-model-invocation: true
---

# Shared `a-*` conventions

Every `a-*` command reads this file as its own step 1 and follows it.

## Folder layout

```text
<dev-root>/
├── foo-bar/                          # main repo, tracks ./CONTEXT.md
├── fb-checkout-flow-1-guest-email/   # /wt worktree, sibling, per story
└── planning/
    └── checkout-flow/                # epic slug
        ├── idea.md
        ├── epic.md
        ├── personas.md
        ├── stretch-goals.md
        ├── architecture.md
        ├── progress.md               # the whole epic's state
        ├── story-1.md                # /a-story
        ├── design-1.md               # /a-design
        ├── plan-1-1.md               # /a-plan, story 1 criterion 1
        ├── plan-1-2.md
        └── story-2.md                # ... one set per story
```

One flat epic folder. The suffix is `<story-number>` or `<story-number>-<criterion-number>`, so any artefact resolves from numbers alone.

`story-N.md` carries a `Slug:` header line, kebab-case from the title, so a branch name survives a later title reword.

`N` is permanent identity: assigned once by `a-epic`, never reused, never changed. The epic's execution order lives in `epic.md`'s `## Story Order`, never in the numbers, so the two are free to disagree.

## Path resolution

Identical from the main repo or from any worktree:

```bash
MAIN_REPO_DIR="$(dirname "$(git rev-parse --git-common-dir)")"   # not `git rev-parse --show-toplevel`, which returns the worktree's own path
PLANNING_ROOT="$(dirname "$MAIN_REPO_DIR")/planning"
EPIC_DIR="$PLANNING_ROOT/<epic-slug>"
```

Report the folder a command works in before it writes to it.

## Selector resolution, in order

1. The command's own argument
1. The current branch, when it matches `<epic-slug>/<n>-<story-slug>` and `$EPIC_DIR` exists
1. Memory
1. Stop and ask. NEVER guess, NEVER create `$EPIC_DIR` from a guess

Rule 2 makes this work inside a worktree, where the project memory directory is keyed on a different path than the main repo's.

## Memory

1. One memory file holds the current position: the epic slug, the story number, the criterion number, and the repos the epic touches
1. A command overwrites this file with its own resolved selector before it finishes. It never appends
1. `a-finish` is the last command that needs a selector. Every command after `a-implement` keys on the current git branch instead

## Cold-start rule

The user clears and compacts context between stages. Every `a-*` command runs from an empty context, given only its selector: read what it needs from `$EPIC_DIR` and the repo. NEVER rely on conversation history.

## Canonical blocks

A story's _As a_ / _I want_ / _So that_ and a criterion's _Given_ / _When_ / _Then_ read one clause per line, in every template and every artifact.

1. End every line but the last with a trailing ` \`, the hard line break. Blockquote lines without it collapse into one rendered line
2. NEVER collapse a canonical block onto one line, NEVER drop a clause, NEVER reorder the clauses

## Vertical slicing

| Stage | The slice | NEVER |
| --- | --- | --- |
| `a-epic` | A story is a cohesive slice of user value, shippable and testable alone | A story per layer, or one that only builds infrastructure |
| `a-story` | An acceptance criterion is a slice of that story, demonstrable end to end | A criterion that is "add the table", "add the endpoint", "add the form" |
| `a-plan` | The plan delivers the criterion through every layer it touches | A plan phased by layer |
| `a-implement` | Every commit is a working increment | A commit that leaves the criterion half-wired |

## Bulk approval

A command that gates approval one item at a time (one acceptance criterion, one story, one decision) must let the user lift that gate explicitly.

1. The user may ask for the rest in one pass (eg: "do the rest", "draft them all") — that drafts every remaining item in one pass instead of one at a time
1. Print the whole drafted batch together for one round of revision. Bulk drafting is NEVER a shortcut past revision; the user still revises the batch before it locks, same as a single item would
1. Bulk-lifting one gate lifts only that gate. NEVER skip a later step's own checkpoint because an earlier gate was bulk-approved
1. Absent that request, the default stays one item at a time

## Incremental writes

The artifact is written to disk as each section finalizes, not assembled in conversation and written once at the end. The user reviews a growing file, not CLI scrollback.

1. Write or update the artifact's relevant section the moment a step finalizes it
1. NEVER hold a locked section back waiting for a later step; write what is locked now
1. A mid-run write is never final; the command still presents the complete file for review once every section is written

## Assumptions

Findings travel up; assumptions travel down. Every stage records what it acted on without evidence, in its own artifact's `## Assumptions` table: an inferred model, an unread reference, a guessed dependency, an unconfirmed product intent, a "this is probably how the codebase does it".

| Column | Content |
| --- | --- |
| ID | `EPIC-<n>`, `ARCH-<n>`, or `STORY-<story-number>-<n>`, assigned once by the stage that coined it. NEVER reassign, reuse, or renumber one |
| Assumption | The claim, stated so it can be proven true or false |
| Why It Matters | What breaks, or what changes, if it turns out false |
| Status | `open`, `verified`, `resolved`, `invalidated`, or `cascaded` |
| Evidence or Decision | `verified` → the file, line, test, or reference that proves it. `resolved` → the user's decision, in their words. `invalidated` → what is true instead. `cascaded` → the artifact that inherits it. `open` → empty |

1. A stage inherits every `open` and `cascaded` row from every artifact it reads, and reprints it in its own table under its original ID. NEVER drop one by omission
2. A stage settles what its own evidence settles: `verified` when the codebase, a test, or a followed reference proves it; `invalidated` when they disprove it
3. It cannot settle a row from evidence → put it to the user. Their call is `resolved`, recorded in their words
4. It can settle a row neither way → `cascaded`, naming the artifact that inherits it. A cascade is the ONLY way to leave a row unsettled, and a cascade with nowhere left to go is a gate, not a pass
5. NEVER let a row reach `/a-design` `open` or `cascaded`. `a-story` is the deadline: it verifies what the codebase can settle, then puts the rest to the user
6. The user may settle a row by accepting it as a known risk. That is `resolved`, recorded with the decision and its impact — NEVER a silent pass
7. An `invalidated` row already baked into `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` also becomes an upstream finding, per the rule below
8. NEVER record an assumption as prose. The table is the ledger; a narrative section may cite an ID, NEVER restate the claim in its place

## Upstream findings

A story's own stages touch one file: `story-N.md`. None of them write `epic.md`, `architecture.md`, or a repo's `CONTEXT.md` directly.

1. `a-story`, `a-design`, `a-plan`, and `a-implement` each append an incongruity or durable finding to `story-N.md`'s `## Upstream Findings` section instead of writing the shared doc themselves: the target doc, the finding, the suggested change
1. `a-plan` reads this section, alongside `design-N.md`, and factors confirmed findings into its plan. It never applies one upstream
1. `a-finish` is the only command that applies confirmed findings from `## Upstream Findings` to `epic.md`, `architecture.md`, and each touched repo's `CONTEXT.md`, once per story, after its last criterion lands
1. A story-order conflict takes the same route: the finding targets `epic.md`'s `## Story Order`, names the position the story must move to, and names the dependency that forces it. NEVER renumber a story — `story-N.md`, `design-N.md`, `plan-N-M.md`, the branch name, and the memory selector all key on the number. Rewriting `## Story Order` moves nothing on disk, so it stays safe at any point in the epic

## Skills

1. NEVER name a specific skill as if it is known to exist. Check `./.claude/skills/` in each repo the current step touches, and read the `SKILL.md` files present there
1. Invoke a project skill only when its own description matches the task at hand
1. Embed the real skill text in the prompt or the step, per the global rules. NEVER paraphrase or invent skill content
1. A repo with no matching project skill → carry on without one

## Git

1. Commits are allowed everywhere in this flow
1. NEVER push. Push is explicit, from the user, never from a command

## Terminology

1. `./CONTEXT.md` in a repo is that repo's naming baseline. Read it before coining a term; when a term already exists there, reuse it exactly
1. Update `./CONTEXT.md` only with durable, confirmed terms
1. NEVER remove an entry. NEVER rename an existing entry without explicit user approval
