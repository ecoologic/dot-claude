---
description: Fetch, rebase onto main, sign every commit, then push the current branch; an Opus subagent resolves rebase conflicts
allowed-tools: Bash, Agent
model: haiku
---

# Push

Push the current branch. ALWAYS follow the order: fetch, rebase, ensure all commits are signed, push.

## Implementation Steps

### 1. Preflight

Stop at the first failure. Report the exact reason.

1. Resolve the repository and the branch:

```bash
echo "REPO_ROOT=$(git rev-parse --show-toplevel) BRANCH=$(git rev-parse --abbrev-ref HEAD) BEFORE=$(git rev-parse HEAD)"
```

Shell variables do not survive between `Bash` calls. Write the printed values literally in every later command.

2. `BRANCH` is `HEAD` or `main` → STOP.
3. The tree MUST be clean. This prints nothing:

```bash
git status --porcelain
```

4. No rebase, merge, cherry-pick or bisect in progress. `git status` names one → STOP.

### 2. Fetch

```bash
git fetch origin
```

### 3. Rebase

```bash
git rebase origin/main
```

1. Success → go to step 4.
2. Conflict → dispatch ONE `Agent` with `model: "opus"` and the prompt below. Fill in the real values. Wait for its report.
3. After the agent returns, this prints `rebased`. Else STOP and report the agent's answer:

```bash
test ! -d "$(git rev-parse --git-path rebase-merge)" && git merge-base --is-ancestor origin/main HEAD && echo rebased
```

Agent prompt:

```text
Resolve the git rebase conflicts in <REPO_ROOT>.
Branch <BRANCH> rebases onto origin/main.

1. Run `git status` and `git diff` to find each conflict
2. Read both sides and the commit that introduced each one (`git log -p`)
3. Keep the intent of BOTH sides. NEVER drop a change to make the conflict go away
4. Remove every conflict marker. Then `git add` each resolved file
5. Run `GIT_EDITOR=true git rebase --continue`. Repeat from 1 until the rebase ends
6. A conflict whose correct result is unclear: run `git rebase --abort` and stop
7. NEVER push, commit outside the rebase, reset, stash, or pass `--no-verify`

Report: each file resolved and how, or why you aborted.
```

### 4. Ensure all commits are signed

1. List the unsigned commits. This prints nothing when all are signed:

```bash
git rev-list origin/main..HEAD | xargs -I{} sh -c 'git cat-file commit {} | grep -q ^gpgsig || echo {}'
```

2. Output not empty → re-sign every commit right away:

```bash
git rebase --force-rebase --gpg-sign origin/main
```

3. The signing fails → STOP. Signing can need the user's approval.

### 5. Push

The rebase rewrote history, so a lease guards the force push:

```bash
git push --force-with-lease -u origin HEAD
```

### 6. Report

```text
Pushed:
  branch:  <BRANCH>
  onto:    origin/main
  commits: <count>, all signed
```

Add the files the agent resolved, if step 3 dispatched one.

## Important Notes

1. **NEVER** change the step order.
2. **NEVER** push `main`.
3. **NEVER** pass `--no-verify` or `--force`. Use `--force-with-lease` only.
4. **NEVER** resolve a conflict yourself. The Opus agent does it.

## Error Handling

If any step fails:

1. Report the specific command that failed.
2. Show the error message.
3. Print `BEFORE`. `git rebase --abort` (only mid-rebase), then `git reset --hard <BEFORE>`, restores the branch.
4. Stop immediately.
5. Do not retry automatically.
