---
description: Create a sibling git worktree named <project-initials>-<sanitised-branch>
argument-hint: <branch-name> <instructions for the session on that branch>
---

# Create Git Worktree

Create a git worktree as a sibling of the current project using the folder name `{project-initials}-{sanitised-branch}`. `project-initials` means the initials of the project folder, and `sanitised-branch` means the branch name with `/` replaced by `-`. After creation, continue work from that new folder.

## What This Command Does

1. Resolve the current repository root and project folder name.
2. Build the sibling worktree path as `{project-initials}-{sanitised-branch}`, where the project initials come from the project folder name and the sanitised branch replaces `/` with `-`.
3. Create the worktree for the existing local branch, or create the branch from `origin/<branch>` when that remote branch exists, otherwise from `origin/main`.
4. Report the new path and treat that folder as the working directory from that point on.

## Usage

```bash
/wt my-feature-branch
```

Example: if the project folder is `foo-bar` and the branch is `feature/main`, the sibling worktree folder should be `fb-feature-main`.

## Implementation Steps

When this command is invoked with `<branch-name>`:

### 1. Validate arguments and repository state

1. Require exactly one argument: `<branch-name>`.
2. If no branch name is provided, stop and ask for it.
3. Run:

```bash
git rev-parse --show-toplevel
```

4. If that command fails, report that the current directory is not inside a git repository and stop.

### 2. Resolve the sibling worktree path

1. Treat the `git rev-parse --show-toplevel` result as `PROJECT_DIR`.
2. Compute `PROJECT_NAME` as the basename of `PROJECT_DIR`.
3. Compute `PROJECT_PREFIX` as the initials of `PROJECT_NAME`. Example: `foo-bar` becomes `fb`.
4. Treat the command argument as `BRANCH` exactly as passed. Do not shorten it. Do not rewrite it. Do not prefix it.
5. Compute `SANITISED_BRANCH` by replacing every `/` in `BRANCH` with `-`.
6. Compute the worktree path as a sibling of `PROJECT_DIR`:

```bash
PROJECT_PREFIX="$(printf '%s' "$PROJECT_NAME" | tr '-' '\n' | sed '/^$/d; s/^\(.\).*$/\1/' | tr -d '\n')"
SANITISED_BRANCH="${BRANCH//\//-}"
WORKTREE_DIR="$(dirname "$PROJECT_DIR")/${PROJECT_PREFIX}-${SANITISED_BRANCH}"
```

7. If `WORKTREE_DIR` already exists, report the path and stop. Do not overwrite it.

### 3. Create the worktree

1. Check whether the branch already exists locally:

```bash
git show-ref --verify --quiet "refs/heads/$BRANCH"
```

2. If the branch already exists locally, run:

```bash
git worktree add -f "$WORKTREE_DIR" "$BRANCH"
```

3. Otherwise, check whether the branch exists on `origin`:

```bash
git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"
```

4. If `origin/$BRANCH` exists, create the local branch from that remote branch while creating the worktree:

```bash
git worktree add -b "$BRANCH" "$WORKTREE_DIR" "origin/$BRANCH"
```

5. Otherwise, create the local branch from `origin/main` while creating the worktree:

```bash
git worktree add -b "$BRANCH" "$WORKTREE_DIR" "origin/main"
```

6. Use `-f` for existing local branches so the command also works when `BRANCH` is the current branch or is already checked out in another worktree.

### 4. Report the result and continue from the new folder

1. Report:

```text
Worktree created:
  dir:    <WORKTREE_DIR>
  branch: <BRANCH>
```

2. State that subsequent work should happen from `WORKTREE_DIR`.
3. Do not perform any other setup
4. Start interpreting the prompt <instructions for the session on that branch> (the session continues in the new worktree)

## Important Notes

1. **NEVER** create the worktree inside the repository. Always create it as a sibling directory.
2. **ALWAYS** prefix the folder name with the initials of the project folder. Example: `foo-bar` becomes `fb`.
3. **SANITISE ONLY** the folder name branch segment by replacing `/` with `-`.
4. **KEEP** `BRANCH` unchanged for git operations. Do not shorten it. Do not rewrite it. Do not prefix it.
5. **USE** `git worktree add -f` for existing local branches so the current branch is supported.
6. **BASE** new local branches on `origin/<branch>` when that remote branch exists.
7. **FALL BACK** to `origin/main` when the branch does not yet exist locally or on `origin`.
8. **DO NOT** create symlinks, copy files, run setup steps, or clean anything up.
9. **DO NOT** do anything beyond creating the sibling worktree and reporting the resulting directory.

## Error Handling

If any step fails:

1. Report the specific command that failed.
2. Show the error message.
3. Stop immediately.
4. Do not retry automatically.
