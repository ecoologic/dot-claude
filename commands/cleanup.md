---
description: Remove low-value tests and trim comments in the current branch
allowed-tools: Bash, Read, Edit, Glob, Grep, Skill
disable-model-invocation: true
---

# Cleanup

## Implementation Steps

### 1. Preflight

```bash
git rev-parse --show-toplevel
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEFAULT_BRANCH="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)}"
```

1. `BRANCH` is not `DEFAULT_BRANCH`. If it is, STOP.

### 2. Read the branch diff

```bash
git diff "origin/$DEFAULT_BRANCH...HEAD"
```

1. Tests: touch ONLY tests the branch adds or changes, and the code that becomes dead when you remove them.
2. Comments: touch the comments the branch adds or changes, and the comments that describe code the branch changes.

### 3. Remove low-value tests

1. Load every available skill about testing. If none applies, skip this step.
2. Remove a test when it breaks a rule of those skills. When in doubt, keep it.
3. Remove the code the removed tests leave dead: helpers, fixtures, mocks, setup, imports and production code.

### 4. Trim comments

1. Load every available skill about coding. If none applies, skip this step.
2. Delete or trim a comment when it breaks a rule of those skills.
3. NEVER touch doc comments on a public interface.

### 5. Report

1. Each removed test, with its file and the skill rule it broke.
2. The count of comments deleted and cut, per file.

## Important Notes

1. **NEVER** commit, stash or push.
2. **NEVER** change code that is not a test or a comment, except dead code from step 3.
3. **DO NOT** do anything beyond steps 3 and 4.
