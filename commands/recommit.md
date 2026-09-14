---
description: Fold uncommitted work in, squash the branch into the fewest self-contained commits, then rebase onto the default branch
allowed-tools: Bash, Read, Glob, Grep
disable-model-invocation: true
---

# Recommit

Rewrite the current branch as the fewest self-contained commits. Uncommitted work is folded in. The branch then rebases onto the default branch. Nothing is pushed.

## Implementation Steps

### 1. Preflight

Stop at the first failure. Report the exact reason.

1. Resolve the repository, the branch and the base:

```bash
git rev-parse --show-toplevel
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEFAULT_BRANCH="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)}"
git fetch origin "$DEFAULT_BRANCH"
MERGE_BASE="$(git merge-base "origin/$DEFAULT_BRANCH" HEAD)"
```

2. `BRANCH` is not `DEFAULT_BRANCH`. If it is, STOP.
3. No rebase, merge, cherry-pick or bisect in progress. If one is, STOP:

```bash
git status
```

4. The branch carries work. No commits ahead of `MERGE_BASE` AND a clean tree means there is nothing to do — STOP:

```bash
git rev-list --count "$MERGE_BASE..HEAD"
git status --porcelain
```

5. Keep a safety ref before any rewrite. Every later step names it on failure:

```bash
git branch "recommit-backup/$BRANCH-$(date +%Y%m%d-%H%M%S)"
```

### 2. Read the repository's commit rules

First hit wins. Every message you write MUST pass these rules:

1. `commitlint.config.*`, `.commitlintrc*`, or a `commitlint` key in `package.json`
2. `.pre-commit-config.yaml` -- note every hook on the `commit-msg` stage
3. `CONTRIBUTING.md`, `.gitmessage`
4. Nothing found: copy the convention the default branch already uses:

```bash
git log --no-merges --format=%s -30 "origin/$DEFAULT_BRANCH"
```

### 3. Fold the uncommitted work in

```bash
git status --porcelain
git add -A
TREE_BEFORE="$(git write-tree)"
```

1. Untracked files are branch work. `git add -A` takes them; `.gitignore` still applies.
2. Record what you staged. Step 7 reports it.
3. `TREE_BEFORE` is the integrity check. Step 5 uses it to prove no change was lost.

### 4. Plan the commits

Read the whole branch, the staged work included:

```bash
git log --oneline "$MERGE_BASE..HEAD"
git diff --stat "$MERGE_BASE"
git diff "$MERGE_BASE"
```

1. Default to ONE commit.
2. Split ONLY for genuinely separable concerns -- a migration beside a feature, a dependency bump beside a fix. Each commit MUST revert on its own.
3. NEVER split for tidiness. NEVER spread one concern across two commits.
4. One commit carries one type under the step 2 rules. A group that needs two types is two groups.
5. Write each message from the work itself, NEVER from the old commit subjects.

### 5. Rewrite

```bash
git reset --soft "$MERGE_BASE"
```

One group:

```bash
git commit -m "$MESSAGE"
```

Several groups, in dependency order -- the migration before the code that uses it:

```bash
git reset                 # empty the index, keep every change in the tree
git add -- $GROUP_PATHS   # repeat these two lines, once per group
git commit -m "$MESSAGE"
```

1. NEVER pass `--no-verify`. The hooks run.
2. A hook that rewrites files: `git add -A`, then `git commit --amend --no-edit`.
3. A hook that fails: STOP. Report the hook and its output. Leave the branch as it stands. Name the step 1 backup ref.
4. The last group MUST leave the tree clean. `git status --porcelain` prints something means you missed paths -- add them to that last group BEFORE you commit it.
5. Prove nothing was lost:

```bash
test "$(git rev-parse HEAD^{tree})" = "$TREE_BEFORE" && echo IDENTICAL
```

A hook that reformatted a file is the ONLY allowed difference. Anything else: STOP and report `git diff $TREE_BEFORE HEAD`.

### 6. Rebase onto the default branch

```bash
git rebase "origin/$DEFAULT_BRANCH"
```

On conflict, abort and STOP. NEVER resolve a conflict. The new commits survive the abort:

```bash
git rebase --abort
```

### 7. Report

1. The commits now on the branch, one line each.
2. The uncommitted files you folded in.
3. What the rebase did: moved the branch, found nothing to do, or aborted -- name the conflicting files.
4. The backup ref, and the `git branch -D` line that drops it.
5. Whether the branch now differs from its remote. The push is the user's to run.

## Important Notes

1. **NEVER** push. **NEVER** force-push.
2. **NEVER** pass `--no-verify`.
3. **NEVER** resolve a rebase conflict.
4. **NEVER** drop a change. The step 5 tree check is the proof.
5. **NEVER** touch the default branch.
6. **DO NOT** do anything beyond rewriting the commits and rebasing.

## Error Handling

If any step fails:

1. Report the specific command that failed.
2. Show the error message.
3. Stop immediately.
4. Do not retry automatically.
5. Name the step 1 backup ref whenever the branch is left mid-rewrite.
