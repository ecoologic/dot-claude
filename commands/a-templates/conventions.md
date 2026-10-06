---
description: "Template: shared conventions every a-* command follows"
disable-model-invocation: true
---

# Shared `a-*` conventions

Every `a-*` command reads this file as its own step 1 and follows it. A command step that needs a rule below cites the section in one line. NEVER restate a rule from this file in a command. NEVER read this file, or a command file, again once this session has read it. A nested stage skips its own step-1 read of this file.

## Folder layout

```text
<dev-root>/
├── foo-bar/                                  # main repo, tracks ./CONTEXT.md
├── foo-bar--story-1-ac-1-guest-email/        # /wt worktree, sibling, per criterion
└── planning/                                 # git repo, the user commits it by hand
    └── checkout-flow/                        # epic slug
        ├── epic-architecture.md              # /a-architecture
        ├── epic-personas.md                  # /a-epic
        ├── epic-progress.md                  # the whole epic's state, /a-cont
        ├── epic-requirements.md              # /a-epic Step 0, from the raw idea
        ├── epic-stretch-goals.md             # /a-epic
        ├── epic.md                           # /a-epic
        ├── story-1-ac-1.md                   # /a-plan, story 1 criterion 1
        ├── story-1-ac-2.md
        ├── story-1-design.md                 # /a-design
        ├── story-1.md                        # /a-story
        └── story-2.md                        # ... one set per story
```

Every file name doubles as its alphabetical sort key: an `epic-` or `story-<story-number>-` prefix, plus a trailing detail (`-design`, `-ac-<criterion-number>`) or none for the stage's own root doc (`epic.md`, `story-<story-number>.md`). `ls` groups every epic-level doc together and every story's own artefacts together, in the order shown above. One flat epic folder; any artefact resolves from numbers alone. Past 9 stories or 9 criteria, the two-digit numbers (`story-10-*.md`, `story-<story-number>-ac-10.md`) sort lexicographically inside their group, not numerically, but the group itself stays contiguous.

## Story numbers

1. `N` is permanent identity: assigned once by `a-epic`, never reused, never changed
1. The execution order lives in `epic.md`'s `## Story Order`, never in the numbers, so the two are free to disagree
1. NEVER renumber a story, and NEVER offer to. `story-N.md`, `story-N-design.md`, `story-N-ac-M.md`, the branch names and the memory file all key on `N`. Reorder only by rewriting `## Story Order`, which moves nothing on disk

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
1. A command writes only inside `$EPIC_DIR`, with three exceptions: the memory file, a repo's `./CONTEXT.md` in `a-finish`'s context worktree, and the code `a-implement` and `a-check` write in the criterion worktrees

## Where a command runs

1. Planning stages are `a-epic`, `a-architecture`, `a-story` and `a-design`. They run from the main repo root only, and so does `a-finish`, since a worktree cannot remove itself
1. A planning stage started inside a worktree stops and says so. It is a worktree when the two lines of the `## Path resolution` command differ

1. A planning stage on a branch other than the default one prints a one-line warning and carries on. The default branch is `git symbolic-ref --short refs/remotes/origin/HEAD` without its `origin/` prefix
1. `/wt` makes each criterion worktree from `story-N-ac-M.md`'s `branch` header, per `## Criterion branches`, for `a-implement` onwards. `a-cont`, `a-edit` and `a-plan` run from either place

## Selector resolution

| Command | Order |
| --- | --- |
| Planning stages | 1. The command's own argument 2. Memory 3. Stop and ask |
| Every other `a-*` command | 1. The command's own argument 2. The current branch, when it matches `<issue-key>/story-<story-number>-ac-<criterion-number>-<ac-slug>` and exactly one `$PLANNING_ROOT/*/epic.md` carries that `issue-key` header 3. Memory 4. Stop and ask |

1. `$ARGUMENTS` never carries an epic slug. The epic resolves per this table
1. NEVER guess, NEVER create `$EPIC_DIR` from a guess
1. A new epic slug is confirmed by the user before anything is written under it
1. An AC slug is kebab-case, 3 words at most. `a-plan` picks it from the criterion; it needs no confirmation

## Memory

One file holds the current position, keyed on the main repo path so it is the same file from the main repo and from every worktree:

`MEMORY_FILE` is `~/.claude/projects/<key>/memory/a-pipeline-current-position.md`, where `<key>` is `MAIN_REPO_DIR` with every `/` and `.` replaced by `-` (eg `/home/me/dev/foo-bar` → `-home-me-dev-foo-bar`). Expand `~` to the home directory the session's own memory path shows; NEVER hard-code it.

````md
---
name: a-pipeline-current-position
description: "The a-* pipeline's current position: epic slug and description, story, criterion, and the repos the epic touches"
metadata:
  type: project
---

- Epic: <epic-slug>
- Description: <the `> Epic:` summary line of epic.md>
- Story: <n, or none>
- Criterion: <m, or none>
- Repos: <repo>, <repo>
- Updated: <updated, per Document header>
````

1. Every `a-*` command runs from an empty context, given only its selector. NEVER rely on conversation history
1. Every command's resolve step overwrites this file with its own resolved selector, before the command finishes. NEVER append, NEVER add prose, history or decisions: those live in the planning docs
1. A command NEVER restates this write as a step or a `## Success Criteria` item. It names only a value it adds, eg `Criterion: none`
1. The memory directory's `MEMORY.md` carries one pointer line to this file. Add it when it is missing; NEVER duplicate it
1. `a-finish` is the last command that needs a selector. The non-`a-*` commands after `a-check` (`/draft-pr`, `/security-review`) key on the current git branch instead

## Criterion branches

One acceptance criterion, one branch, one worktree and one PR per touched repo. Main is the base whenever it can be; a stack only bridges an unmerged parent criterion. Criteria with no unmerged parent run in parallel.

1. The criterion branch is `<issue-key>/story-<story-number>-ac-<criterion-number>-<ac-slug>`, where `<issue-key>` is `epic.md`'s `issue-key` header, eg `PROP-123/story-1-ac-2-email-format`. `issue-key` is `none` → every branch in this section drops its `<issue-key>/` prefix, eg `story-1-ac-2-email-format`. Criterion code lands only there
1. The parents are the `AC <criterion-number>` lines of the plan's `### Dependencies`. A parent may carry a higher number than its child. The parent branch is the parent plan's `branch` header
1. Merged: `gh pr list --head <branch> --state merged --json number` prints a PR. NEVER test ancestry; a squash merge leaves none
1. Base: no parent, or every parent merged → `origin/<default-branch>`, the default branch per `## Where a command runs`. Exactly one unmerged parent that exists locally → that parent branch. More than one unmerged parent → STOP, and name the parents to merge first
1. Stacked: after `git fetch origin <default-branch>`, the parent branch exists locally, and `M=$(git merge-base HEAD <parent-branch>)` is not on the default branch: `git merge-base --is-ancestor "$M" origin/<default-branch>` fails. It holds after the parent branch gains commits, and after it squash-merges
1. Fork point: `M` when stacked, else `git merge-base HEAD origin/<default-branch>`. Every range a command reviews or diffs starts there
1. Rebase before push: stacked and the parent branch is merged → `git rebase --onto origin/<default-branch> <fork-point>`. A conflict → `git rebase --abort`, report the files, and stop. NEVER resolve it by guessing
1. The PR targets the base. A base other than the default branch is a GitHub stack: `/draft-pr --base <parent-branch>`
1. Ready: a criterion whose plan is `done` and whose parents all have a `status` starting with `implemented`. Every ready criterion can run `/a-implement` in its own session
1. The context branch `<issue-key>/story-<story-number>-context` carries only `a-finish`'s `CONTEXT.md` commits, per its own step

### Criterion worktree lookup

Once per touched repo. `<branch>` is the plan's `branch` header. The command names its own outcome for a missing entry.

1. The touched repos are the ones the plan's `> Repos:` line and the Repo column of its `## Verification` name
1. Each repo resolves to `<dev-root>/<repo>`, the sibling of `$PLANNING_ROOT`, per `## Folder layout`
1. Run `git -C <dev-root>/<repo> worktree list --porcelain`. The `branch refs/heads/<branch>` entry's `worktree` line is the worktree. Use it
1. No entry → the command's own outcome: STOP, record `none`, or create the worktree
1. Create: the local `<branch>` exists first, on the base the command names. Read `~/.claude/commands/wt.md` and follow its text from `<dev-root>/<repo>`, with `<branch>` as its argument, eg `PROP-123/story-1-ac-2-email-format`. It checks out the local branch. Then run `./scripts/setup-worktree.sh` from the new worktree when it exists
1. Run `git -C <worktree> status --porcelain`. Uncommitted changes → STOP. Report them. NEVER stash, reset or discard them

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
branch: PROP-123/story-1-ac-1-guest-email
pr: foo-bar#123
---
```

| Key | On | Content |
| --- | --- | --- |
| `updated` | every doc | The time of the last write, from `date +%Y-%m-%dT%H:%M%z`. Every write refreshes it |
| `status` | the stage's primary doc: `epic.md`, `epic-architecture.md`, `story-N.md`, `story-N-design.md`, `story-N-ac-M.md` | `draft` while being written. `done` only once the user gives final approval. `blocked` with the reason in the doc's `## Findings` or `## Assumptions`. `finished` on `story-N.md` only, set by `a-finish` once the story closes. On `story-N-ac-M.md` only, after `done`: `implemented`, set by `a-implement` once the criterion is committed; then `implemented, simplified` and `implemented, simplified, reviewed`, each appended by `a-check` |
| `issue-key` | `epic.md` only | The epic's Jira issue key from `epic-requirements.md`, eg `PROP-123`; `none` when it names none. Set by `a-epic` |
| `branch` | `story-N-ac-M.md` only | The criterion branch, set by `a-plan` on its first write. Per `## Criterion branches` |
| `pr` | `story-N-ac-M.md` only | `<repo>#<number>` per repo with a PR for the criterion branch, comma-separated, else `none`. Set by `a-implement`, refreshed by `a-finish` |

1. Update each key with one exact Edit of its line. NEVER rewrite the header block as a whole
1. A later revision of a doc past `draft` keeps its status and refreshes `updated`
1. `a-implement` records its status in `story-N-ac-M.md`'s header. `a-finish` records its status in `story-N.md`'s header
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
| An AC slug | 3 words |

## Assumptions

Findings travel up; assumptions travel down. Every stage records what it acted on without evidence, in its own doc's `## Assumptions` table: an inferred model, an unread reference, a guessed dependency, an unconfirmed product intent, a "this is probably how the codebase does it".

| Column | Content |
| --- | --- |
| ID | `A-<STAGE>-<n>`: `A-EPIC-<n>`, `A-ARCH-<n>`, `A-STORY-<story-number>-<n>`, `A-AC-<story-number>-<criterion-number>-<n>`. The prefix names the stage that coined it; `n` numbers that stage's assumptions. `A-AC-` rows are coined by `a-implement` in one plan, so parallel criteria never collide. Assigned once. NEVER reassign, reuse, or renumber one |
| Assumption | The claim, stated so it can be proven true or false |
| Why It Matters | What breaks, or what changes, if it turns out false |
| Status | `open`, `verified`, `resolved`, `invalidated`, or `cascaded` |
| Evidence or Decision | `verified` → the file, line, test, or reference that proves it. `resolved` → the user's decision, in their words. `invalidated` → what is true instead. `cascaded` → the doc that inherits it. `open` → empty |

1. Legacy IDs without the `A-` prefix (`EPIC-5`, `ARCH-3`, `STORY-1-2`) are the same row as their prefixed form (`A-EPIC-5`). Match them as equal when reading; write new rows prefixed only
1. Routing: every `a-epic` row routes to `epic-architecture.md`. A `cascaded` row routes to the doc its Evidence cell names (`story-3.md`, or `every story-N.md`)
1. A stage inherits only the `open` and `cascaded` rows routed to its own doc, and reprints each under its original ID. NEVER drop a routed row by omission
1. A settled row is cited by ID, NEVER reprinted
1. One ID, one truth: the most downstream doc's status wins, in the order `epic.md` → `epic-architecture.md` → `story-N.md` → `story-N-design.md` → `story-N-ac-M.md`. NEVER go back to update the upstream row
1. A stage settles its rows per `### Settle` below
1. It can settle a row neither way → `cascaded`, naming the doc that inherits it. A cascade is the ONLY way to leave a row unsettled, and a cascade with nowhere left to go is a gate, not a pass
1. The gate covers only the rows this story's implementation requires. NEVER let such a row reach `/a-design` `open` or `cascaded`. `a-story` is their deadline: it verifies what the codebase can settle, then puts the rest to the user
1. A routed row this story's implementation does not require is never gated here: cascade it to the doc that does require it (`story-N.md` of a later story, or `every story-N.md`)
1. NEVER record an assumption as prose. The table is the ledger; a narrative section may cite an ID, NEVER restate the claim in its place

### Settle

A stage settles its ledger in this order. The command names its ID prefix, its evidence, and the stage its gate protects.

1. Mark each row its own evidence settles: `verified` when the codebase, a test, or a followed reference proves it. `invalidated` when they disprove it. Cite the file, line, test or commit
1. Put every row still `open` to the user, one at a time, per the `ask-user-question` skill. Name what it blocks and what changes if it is false
1. NEVER batch rows into one question, unless the user lifts the gate per `## Bulk approval`
1. The user settles a row by deciding, or by accepting it as a known risk. Either is `resolved`: record the decision in their words, with its impact. NEVER a silent pass
1. The user cannot settle a row → stop. That is a gate: report the row, what it blocks, and the decision needed. NEVER hand the next stage an `open` row
1. An `invalidated` row already baked into `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` also becomes a finding, per `## Findings` below

### Entry gate

A stage checks its upstream doc's ledger before any work. The command names its upstream doc, and any row its gate skips.

1. The upstream doc carries a row still `open` or `cascaded` → STOP. The upstream stage was that row's deadline
1. Report the row, and send the user to `/a-edit` for the upstream doc, with `<guidance>`. NEVER settle it here

## Findings

A story's own stages touch one planning doc each. None of them write `epic.md`, `epic-architecture.md`, or a repo's `CONTEXT.md` directly.

1. `a-story`, `a-design` and `a-plan` each append an incongruity or durable finding to `story-N.md`'s `## Findings` section instead of writing the shared doc themselves. `a-implement` and `a-check` append theirs to their own `story-N-ac-M.md`'s `## Findings`, the same way
1. A row carries the target doc, the finding, and the suggested change, within `## Size caps`. Append only. NEVER edit an earlier row; only `a-finish`'s mark below changes one
1. A confirmed finding overrides the shared doc it targets. Every later `a-story`, `a-design` and `a-plan` run reads `## Findings` beside `epic-architecture.md` and acts on the finding, NEVER on the text it corrects. `a-implement` and `a-check` read their plan only
1. Those three stages also read `## Findings` in every other `story-N.md` of the epic, never its `-design` or `-ac` files, and skips each row whose Suggested Change cell carries `Applied to <doc> on <YYYY-MM-DD>` or `Rejected on <YYYY-MM-DD>: <reason>`
1. Only `a-finish` marks a row, by appending one of those two marks to its Suggested Change cell
1. `a-finish` is the only command that applies confirmed findings to `epic.md`, `epic-architecture.md`, and each touched repo's `CONTEXT.md`, once per story, after its last criterion lands. It reads `## Findings` in `story-N.md` and in every `story-N-ac-M.md` of the story
1. A story-order conflict takes the same route: the finding targets `epic.md`'s `## Story Order`, names the position the story must move to, and names the dependency that forces it. Per `## Story numbers`, it NEVER renumbers
1. Two rows that contradict each other on the same target: the later stage wins, `story-N-ac-M.md` over `story-N.md`. `a-finish` marks the other `Rejected on <YYYY-MM-DD>: superseded by <file>`

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
| `simplify` | `a-check`, first |
| `code-review` | `a-check`, second, as `high --fix` |
| `run` | `a-implement` and `a-check`, to start the app for the `Browser` verification row |
| `claude-in-chrome` | `a-implement` and `a-check`, to drive the `Browser` verification row |

Repo and package skills:

1. In each repo the current step touches, list `.claude/skills/*/SKILL.md` and `**/.claude/skills/*/SKILL.md`, skipping `node_modules`
1. Read each `SKILL.md` found. Use a skill only when its own description matches the step at hand
1. NEVER hard-code a repo skill's name; they differ per repo
1. Embed the real skill text in a subagent's prompt, per the global rules. NEVER paraphrase or invent skill content
1. A repo with no matching skill → carry on without one
1. A command step that uses a skill names it in one line

Recorded skill paths, from `a-design` onwards:

1. `a-design` runs the lookup above once per touched repo. It records every `SKILL.md` path found in the design's `> Skills:` line, as `<repo>/<path from the repo root>`. Paths only, NEVER skill text. No skill found → `none`
1. `a-plan` copies the design's `> Skills:` line into each plan's `> Skills:` line
1. `a-plan`, `a-implement`, `a-check`, and `a-edit` on a design or a plan, read only the paths their input doc's `> Skills:` line lists. NEVER list the skills directories again
1. `a-implement` and `a-check` resolve each path inside the criterion worktree of its repo
1. A design or plan with no `> Skills:` line is legacy. Run the lookup above

## Git

1. `$PLANNING_ROOT` is a git repository. The user commits it by hand; no `a-*` command ever commits in it
1. Commits in the code repos are allowed everywhere in this flow
1. NEVER push. Push is explicit, from the user, never from a command
1. NEVER pass `--no-verify`. The hooks run

### Committing in a criterion worktree

`a-implement` and `a-check` commit this way. The command names the paths it stages.

1. Stage by exact path. NEVER `git add -A`
1. After each commit, `git status --porcelain` in that worktree prints nothing. Anything left → commit it, or stop and report it
1. Follow the repo's own commit message convention, from its `CLAUDE.md` or `CONTRIBUTING.md`. The message follows `## Workflow jargon`
1. A hook fails → fix the cause, then commit again

## Validation

`a-implement` and `a-check` validate with this ladder. Each command adds only its own failure policy.

Run the plan's `## Verification` rows only, in this order:

1. Targeted tests for the changed module, component or endpoint
1. Targeted lint, format, or type checks
1. The full test suite
1. The `browser` row, when the plan has one: invoke the `run` skill to start the app with the row's command. Then invoke the `claude-in-chrome` skill to follow `### Browser` step by step. Record a GIF of the run as evidence

Then:

1. A failure is pre-existing or unrelated → report the command and the failure. Explain why it is out of scope, and do not block completion
1. A rung has no `## Verification` row, or its row is `- None` → skip it. Report it as a risk in the command's summary step
1. The Chrome extension is not connected → skip the `browser` rung. Report that the user must check it by hand
1. No automated validation at all → state this. Review the code against the criterion's _Given_ / _When_ / _Then_ by hand

## Workflow jargon

These rules cover code, comments, user-facing copy, commit messages, and committed implementation text. They NEVER cover the planning docs.

1. NEVER mention epic, story, acceptance criteria, AC, or similar workflow jargon. Use plain language that still makes sense later without process context
1. NEVER introduce outdated history context in comments or UI. It refers to implementation detail changes, eg the rename of a model
1. Write only durable comments. A comment describes behaviour or business rules directly. NEVER reference a workflow artefact

## Terminology

1. `./CONTEXT.md` in a repo is that repo's naming baseline. Read it before coining a term; when a term already exists there, reuse it exactly
1. Update `./CONTEXT.md` only with durable, confirmed terms. Only `a-finish` writes it, from confirmed findings
1. `a-architecture` confirms `epic.md`'s candidate terms in `epic-architecture.md`'s `## Terminology`. `a-story` routes each `new` or `exists (extend with ...)` row its story uses as a finding that targets that repo's `CONTEXT.md`
1. NEVER remove an entry. NEVER rename an existing entry without explicit user approval
