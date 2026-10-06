---
description: Create a sibling git worktree named <project>--<branch-last-segment>, off an updated main
argument-hint: <branch-name>
model: haiku
---

# Create Git Worktree

Create a git worktree as a sibling of the main repository, in the folder `{project}--{branch-last-segment}`.

Examples, project folder `product`:

| Command | Folder | Branch |
| --- | --- | --- |
| `/wt login` | `product--login` | `login` |
| `/wt PROP-123/story-1-ac-2-email-format` | `product--story-1-ac-2-email-format` | `PROP-123/story-1-ac-2-email-format` |

## Steps

### 1. Resolve the paths

1. Require `<branch-name>`. No branch name → stop and ask for it.
1. Run the block below. It fails → the current directory is not in a git repository. Stop.

```bash
BRANCH="<branch-name>"
MAIN_REPO_DIR="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
WORKTREE_DIR="$(dirname "$MAIN_REPO_DIR")/$(basename "$MAIN_REPO_DIR")--${BRANCH##*/}"
```

1. `WORKTREE_DIR` exists → report it and stop. NEVER overwrite it.
1. Print `WORKTREE_DIR` and `BRANCH`. Ask the user to confirm. Anything but a yes → stop.

### 2. Update main

1. Run `git -C "$MAIN_REPO_DIR" fetch origin`.
1. `git -C "$MAIN_REPO_DIR" branch --show-current` prints `main` → run `git -C "$MAIN_REPO_DIR" merge --ff-only origin/main`.
1. Otherwise → run `git -C "$MAIN_REPO_DIR" fetch origin main:main`.

### 3. Create the worktree

1. The local branch exists (`git -C "$MAIN_REPO_DIR" show-ref --verify --quiet "refs/heads/$BRANCH"`) → run `git -C "$MAIN_REPO_DIR" worktree add "$WORKTREE_DIR" "$BRANCH"`.
1. Otherwise → run `git -C "$MAIN_REPO_DIR" worktree add -b "$BRANCH" "$WORKTREE_DIR" main`.

### 4. Report

1. Print `WORKTREE_DIR` and `BRANCH`.
1. Print `/cd <WORKTREE_DIR>` for the user to type. `/cd` is a harness built-in. NEVER claim you ran it.
1. `$WORKTREE_DIR/scripts/setup-worktree.sh` exists → offer to run it from `WORKTREE_DIR`.

## Rules

1. NEVER create symlinks, copy files, or clean anything up.
1. NEVER run the setup script without the user's yes.
1. A command fails → report the command and its error. Stop. NEVER retry.
