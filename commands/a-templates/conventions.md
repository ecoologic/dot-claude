---
description: "Template: shared conventions every a-* command follows"
disable-model-invocation: true
---

# Shared `a-*` conventions

Every `a-*` command reads this file as its own step 1 and follows it. A command step that needs a rule below cites the section in one line. NEVER restate a rule from this file in a command.

## Folder layout

```text
<dev-root>/
├── foo-bar/                          # main repo, tracks ./CONTEXT.md
├── fb-checkout-flow-1-guest-email/   # /wt worktree, sibling, per story
└── planning/                         # git repo, the user commits it by hand
    └── checkout-flow/                # epic slug
        ├── epic-architecture.md      # /a-architecture
        ├── epic-personas.md          # /a-epic
        ├── epic-progress.md          # the whole epic's state, /a-cont
        ├── epic-requirements.md      # /a-epic Step 0, from the raw idea
        ├── epic-stretch-goals.md     # /a-epic
        ├── epic.md                   # /a-epic
        ├── story-1-ac1.md            # /a-plan, story 1 criterion 1
        ├── story-1-ac2.md
        ├── story-1-design.md         # /a-design
        ├── story-1.md                # /a-story
        └── story-2.md                # ... one set per story
```

Every file name doubles as its alphabetical sort key: an `epic-` or `story-<story-number>-` prefix, plus a trailing detail (`-design`, `-ac<criterion-number>`) or none for the stage's own root doc (`epic.md`, `story-<story-number>.md`). `ls` groups every epic-level doc together and every story's own artefacts together, in the order shown above. One flat epic folder; any artefact resolves from numbers alone. Past 9 stories or 9 criteria, the two-digit numbers (`story-10-*.md`, `story-<n>-ac10.md`) sort lexicographically inside their group, not numerically, but the group itself stays contiguous.

## Story numbers

1. `N` is permanent identity: assigned once by `a-epic`, never reused, never changed
1. The execution order lives in `epic.md`'s `## Story Order`, never in the numbers, so the two are free to disagree
1. NEVER renumber a story, and NEVER offer to. `story-N.md`, `story-N-design.md`, `story-N-acM.md`, the branch name and the memory file all key on `N`. Reorder only by rewriting `## Story Order`, which moves nothing on disk

## Path resolution

Identical from the main repo or from any worktree. Run the one bare command, so `Bash(git rev-parse:*)` matches it, and derive the rest from its output:

```bash
git rev-parse --path-format=absolute --git-dir --git-common-dir   # not --show-toplevel, which returns the worktree's own path
```

| Name | Derived from the second output line |
| --- | --- |
| `MAIN_REPO_DIR` | The line without its trailing `/.git` |
| `PLANNING_ROOT` | `MAIN_REPO_DIR`'s parent, plus `/planning` |
| `EPIC_DIR` | `$PLANNING_ROOT/<epic-slug>` |

1. NEVER hard-code the dev root or the user's home directory, in a command or in its checks
1. Report the folder a command works in before it writes to it
1. A command writes only inside `$EPIC_DIR`, with two exceptions: the memory file, and a repo's `./CONTEXT.md` where the command's own step allows it

## Where a command runs

1. Planning stages are `a-epic`, `a-architecture`, `a-story` and `a-design`. They run from the main repo root only
1. A planning stage started inside a worktree stops and says so. It is a worktree when the two lines of the `## Path resolution` command differ

1. A planning stage on a branch other than the default one prints a one-line warning and carries on. The default branch is `git symbolic-ref --short refs/remotes/origin/HEAD` without its `origin/` prefix
1. `/wt` makes the story worktree from `story-N.md`'s `branch` header, for `a-implement` onwards. `a-cont`, `a-edit` and `a-plan` run from either place

## Selector resolution, in order

| Command | Order |
| --- | --- |
| Planning stages | 1. The command's own argument 2. Memory 3. Stop and ask |
| Every other `a-*` command | 1. The command's own argument 2. The current branch, when it matches `<epic-slug>/<n>-<story-slug>` and `$EPIC_DIR` exists 3. Memory 4. Stop and ask |

1. NEVER guess, NEVER create `$EPIC_DIR` from a guess
1. A new epic slug or story slug is confirmed by the user before anything is written under it
1. A story slug is kebab-case, 5 words at most

## Memory

One file holds the current position, keyed on the main repo path so it is the same file from the main repo and from every worktree:

`MEMORY_FILE` is `~/.claude/projects/<key>/memory/a-pipeline-current-position.md`, where `<key>` is `MAIN_REPO_DIR` with every `/` and `.` replaced by `-` (eg `/home/me/dev/foo-bar` → `-home-me-dev-foo-bar`). Expand `~` to the home directory the session's own memory path shows; NEVER hard-code it.

````md
---
name: a-pipeline-current-position
description: "The a-* pipeline's current position: epic slug, story, criterion, and the repos the epic touches"
metadata:
  type: project
---

- Epic: <epic-slug>
- Story: <n, or none>
- Criterion: <m, or none>
- Repos: <repo>, <repo>
- Updated: <updated, per Document header>
````

1. A command overwrites this file with its own resolved selector before it finishes. NEVER append, NEVER add prose, history or decisions: those live in the planning docs
1. The memory directory's `MEMORY.md` carries one pointer line to this file. Add it when it is missing; NEVER duplicate it
1. `a-finish` is the last command that needs a selector. Every command after `a-implement` keys on the current git branch instead

## Cold-start rule

The user clears and compacts context between stages. Every `a-*` command runs from an empty context, given only its selector: read what it needs from `$EPIC_DIR` and the repo. NEVER rely on conversation history.

## Templates

1. Every planning doc has exactly one template in `~/.claude/commands/a-templates/`, named after the doc: `epic-requirements.md`, `epic.md`, `epic-personas.md`, `epic-stretch-goals.md`, `epic-architecture.md`, `story.md`, `story-design.md`, `story-ac.md`, `epic-progress.md`
1. The template's `## Shape` block is the doc's structure. A command reads headings from the template; NEVER retype a heading from memory or from another command
1. A command reads another stage's doc by the headings in that doc's template

## Document header

Every planning doc starts with YAML frontmatter, above its `#` title:

```yaml
---
updated: 2026-09-23T14:05+1000
status: draft
branch: checkout-flow/1-guest-email
---
```

| Key | On | Content |
| --- | --- | --- |
| `updated` | every doc | The time of the last write, from `date +%Y-%m-%dT%H:%M%z`. Every write refreshes it |
| `status` | the stage's primary doc: `epic.md`, `epic-architecture.md`, `story-N.md`, `story-N-design.md`, `story-N-acM.md` | `draft` while being written. `done` only once the user gives final approval. `blocked` with the reason in the doc's `## Findings` or `## Assumptions` |
| `branch` | `story-N.md` only | `<epic-slug>/<n>-<story-slug>`, set once the slug locks. `/wt` and `a-implement` read it from here |

1. Update each key with one exact Edit of its line. NEVER rewrite the header block as a whole
1. A later revision of a `done` doc keeps `status: done` and refreshes `updated`
1. A stage that writes no doc (`a-implement`, `a-finish`) records its status in its `epic-progress.md` row only
1. A doc without a header is legacy. Its owning command, or `/a-edit`, adds the header the next time it writes that doc. NEVER bulk-migrate

## Write as you go

This is THE write rule for every `a-*` command. No command restates it or carves an exception.

1. The first write creates the doc from its template: the header with `status: draft`, the title, and every H2 heading. The user reviews a growing file, not CLI scrollback
1. Write a section the moment a step settles it, with Edit on that section alone
1. NEVER hold a settled section back for a later step, NEVER batch sections into one write, NEVER rewrite the whole doc
1. The last step checks the doc against its template and uses Edit to add only the missing sections. Then it presents the doc for final approval, and sets `status: done` only on that approval

## Single source of facts

Each fact lives in one planning doc. Every other doc cites it by assumption ID or by heading (`epic-architecture.md` → `## Technical Decisions`), NEVER copies it. A copy drifts.

## Canonical blocks

A story's _As a_ / _I want_ / _So that_ and a criterion's _Given_ / _When_ / _Then_ read one clause per line, in every template and every artefact.

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
1. Present the whole drafted batch together for one round of revision. Bulk drafting is NEVER a shortcut past revision; the user still revises the batch before it locks, same as a single item would
1. Bulk-lifting one gate lifts only that gate. NEVER skip a later step's own checkpoint because an earlier gate was bulk-approved
1. Absent that request, the default stays one item at a time

## Size caps

| Item | Cap |
| --- | --- |
| A table cell | 25 words |
| A finding | 60 words |
| A question to the user | 40 words |
| A story slug | 5 words |

## Assumptions

Findings travel up; assumptions travel down. Every stage records what it acted on without evidence, in its own doc's `## Assumptions` table: an inferred model, an unread reference, a guessed dependency, an unconfirmed product intent, a "this is probably how the codebase does it".

| Column | Content |
| --- | --- |
| ID | `A-<STAGE>-<n>`: `A-EPIC-<n>`, `A-ARCH-<n>`, `A-STORY-<story-number>-<n>`. The prefix names the stage that coined it; `n` numbers that stage's assumptions. Assigned once. NEVER reassign, reuse, or renumber one |
| Assumption | The claim, stated so it can be proven true or false |
| Why It Matters | What breaks, or what changes, if it turns out false |
| Status | `open`, `verified`, `resolved`, `invalidated`, or `cascaded` |
| Evidence or Decision | `verified` → the file, line, test, or reference that proves it. `resolved` → the user's decision, in their words. `invalidated` → what is true instead. `cascaded` → the doc that inherits it. `open` → empty |

1. Legacy IDs without the `A-` prefix (`EPIC-5`, `ARCH-3`, `STORY-1-2`) are the same row as their prefixed form (`A-EPIC-5`). Match them as equal when reading; write new rows prefixed only
1. Routing: every `a-epic` row routes to `epic-architecture.md`. A `cascaded` row routes to the doc its Evidence cell names (`story-3.md`, or `every story-N.md`)
1. A stage inherits only the `open` and `cascaded` rows routed to its own doc, and reprints each under its original ID. NEVER drop a routed row by omission
1. A settled row is cited by ID, NEVER reprinted
1. One ID, one truth: the most downstream doc's status wins, in the order `epic.md` → `epic-architecture.md` → `story-N.md` → `story-N-design.md` → `story-N-acM.md`. NEVER go back to update the upstream row
1. A stage settles what its own evidence settles: `verified` when the codebase, a test, or a followed reference proves it; `invalidated` when they disprove it
1. It cannot settle a row from evidence → put it to the user. Their call is `resolved`, recorded in their words
1. It can settle a row neither way → `cascaded`, naming the doc that inherits it. A cascade is the ONLY way to leave a row unsettled, and a cascade with nowhere left to go is a gate, not a pass
1. The gate covers only the rows this story's implementation requires. NEVER let such a row reach `/a-design` `open` or `cascaded`. `a-story` is their deadline: it verifies what the codebase can settle, then puts the rest to the user
1. A routed row this story's implementation does not require is never gated here: cascade it to the doc that does require it (`story-N.md` of a later story, or `every story-N.md`)
1. The user may settle a row by accepting it as a known risk. That is `resolved`, recorded with the decision and its impact — NEVER a silent pass
1. An `invalidated` row already baked into `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` also becomes a finding, per `## Findings` below
1. NEVER record an assumption as prose. The table is the ledger; a narrative section may cite an ID, NEVER restate the claim in its place

## Findings

A story's own stages touch one planning doc each. None of them write `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` directly.

1. `a-story`, `a-design`, `a-plan`, and `a-implement` each append an incongruity or durable finding to `story-N.md`'s `## Findings` section instead of writing the shared doc themselves: the target doc, the finding, the suggested change
1. A confirmed finding overrides the shared doc it targets. Every later stage reads `## Findings` beside `epic-architecture.md` and acts on the finding, NEVER on the text it corrects
1. Until `a-finish` exists, a stage also reads `## Findings` in every other `story-N.md` of the epic, never its `-design` or `-ac` files, since nothing has applied them upstream yet
1. `a-finish` is the only command that applies confirmed findings from `## Findings` to `epic.md`, `epic-architecture.md`, and each touched repo's `CONTEXT.md`, once per story, after its last criterion lands
1. A story-order conflict takes the same route: the finding targets `epic.md`'s `## Story Order`, names the position the story must move to, and names the dependency that forces it. Per `## Story numbers`, it NEVER renumbers

## Skills

Global and plugin skills, per stage:

| Skill | Use in |
| --- | --- |
| `ask-user-question` | Every `AskUserQuestion` call, in every command |
| `grill-me` | `a-architecture` user gate; `a-design` design agreement and four-axis review |
| `diagrams` | Every mermaid diagram |
| `posthog-feature-flags` | `a-design`, only when the story needs a rollout flag |
| `engineering:architecture` | `a-architecture` decision records |
| `engineering:testing-strategy` | `a-design` happy-path test lines |

Repo and package skills:

1. In each repo the current step touches, list `.claude/skills/*/SKILL.md` and `**/.claude/skills/*/SKILL.md`, skipping `node_modules`
1. Read each `SKILL.md` found. Use a skill only when its own description matches the step at hand
1. NEVER hard-code a repo skill's name; they differ per repo
1. Embed the real skill text in a subagent's prompt, per the global rules. NEVER paraphrase or invent skill content
1. A repo with no matching skill → carry on without one
1. A command step that uses a skill names it in one line

## Git

1. `$PLANNING_ROOT` is a git repository. The user commits it by hand; no `a-*` command ever commits in it
1. Commits in the code repos are allowed everywhere in this flow
1. NEVER push. Push is explicit, from the user, never from a command

## Terminology

1. `./CONTEXT.md` in a repo is that repo's naming baseline. Read it before coining a term; when a term already exists there, reuse it exactly
1. Update `./CONTEXT.md` only with durable, confirmed terms. `a-epic` never writes it: its candidate terms wait in `epic.md` for `a-architecture` to confirm
1. NEVER remove an entry. NEVER rename an existing entry without explicit user approval
