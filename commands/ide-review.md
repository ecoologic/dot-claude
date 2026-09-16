---
description: Help the user "parse the code themselves" to do a code review
model: sonnet
disable-model-invocation: true
---

# IDE Review

In order:

## Get context

The argument, if any, is a PR number or a branch. Options, stop when you have enough:

1. already in chat context
1. the (semi~)latest implemented plan for the branch
1. the branch diff with main

The branch MUST be checked out in the working directory — every link below is relative to it.
A branch lives in only one worktree: if another one holds it, ask before removing that worktree.

## Choose the entrypoints

The happy path entrypoints, tests when possible, top level callers.

## Features

Write to `pr-<number>-review.md` (or `<branch>-review.md`) at the repo root. NOT to the chat.

Template:

```md
## <Goal>

> Describe x when y, it returns z (existing test, or a description otherwise)

1. [ClassTest#test_name](path/from/repo/root#L<line>)
    1. [class#method](path/from/repo/root#L<line>)
        1. [class#method](path/from/repo/root#L<line>)
            1. [class#method](path/from/repo/root#L<line>)
        1. [class#method](path/from/repo/root#L<line>)
            1. Optional code summary related to the goal; max 20 words
```

Write as many sections as required. It is not needed to cover all changes, just the important ones.

### Links

EVERY item is a link. NEVER write an unlinked item — the user clicks it to open the code.

1. The path is relative to the repo root, where the review file sits. VS Code resolves a leading
   `/` against the workspace root, and never expands `~` — both forms open nothing.
1. The line anchor is `#L<line>`, never `:<line>`.
1. Before delivering, check every target file exists and every line is the one meant.

### What to nest

Only code this branch adds or changes.

Unchanged code earns a place only where the flow makes no sense without it — a button that is
the sole entrypoint, a callee that carries the domain meaning. Mark it `unchanged` and say in a
few words why it is there.

A pure rename or an import swap is not a change worth its own item.

## After

The user might paste a snippet of code followed by questions or change suggestions. Review it
with the related skills, and verify against the plan if useful.
