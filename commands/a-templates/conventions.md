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

## Vertical slicing

| Stage | The slice | NEVER |
| --- | --- | --- |
| `a-epic` | A story is a cohesive slice of user value, shippable and testable alone | A story per layer, or one that only builds infrastructure |
| `a-story` | An acceptance criterion is a slice of that story, demonstrable end to end | A criterion that is "add the table", "add the endpoint", "add the form" |
| `a-plan` | The plan delivers the criterion through every layer it touches | A plan phased by layer |
| `a-implement` | Every commit is a working increment | A commit that leaves the criterion half-wired |

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
