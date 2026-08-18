---
description: Push the current branch and open a draft PR following the repo template
---

# Draft Pull Request

Push the current branch and open a draft PR (Pull Request) on GitHub, with a body that follows the repository's own PR template.

## What This Command Does

1. Refuse to run unless the working tree is clean and no PR exists for the branch.
2. Read the commits and diff against the default branch to understand the change.
3. Find the repository's PR template and fill only the sections that carry information.
4. Push the branch and create the PR as a draft, then report its URL.

## Implementation Steps

### 1. Preflight checks

Run all of these BEFORE anything that writes. Stop at the first failure and report the exact reason.

1. Inside a git repository:

```bash
git rev-parse --show-toplevel
```

2. Resolve `BRANCH` and `DEFAULT_BRANCH`:

```bash
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEFAULT_BRANCH="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' \
  || gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"
```

3. Working tree clean:

```bash
git status --porcelain
```

If the output is not empty, list the dirty files and STOP. Do NOT commit. Do NOT stash. Do NOT offer to.

4. `BRANCH` is not `DEFAULT_BRANCH`. If it is, STOP.

5. `gh` (GitHub CLI) is installed and authenticated:

```bash
gh auth status
```

6. No PR exists for the branch:

```bash
gh pr view --json url -q .url
```

If it prints a URL, report it and STOP.

### 2. Gather context

```bash
git log --oneline "origin/$DEFAULT_BRANCH..HEAD"
git diff --stat "origin/$DEFAULT_BRANCH...HEAD"
```

### 3. Find the template

Use the first of these that exists (case-insensitive):

1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `docs/pull_request_template.md`
4. `pull_request_template.md`

If `.github/PULL_REQUEST_TEMPLATE/` is a directory, list its templates and ask which one to use.

### 4. Write the title and body

Title: derive from the branch name when it carries meaning (`feat/user-export` becomes `Add user export`), otherwise from the single commit subject, otherwise from the diff. ALWAYS strip the `feat/`, `fix/`, `chore/` prefix.

Body rules:

1. ALWAYS follow the template's section order and headers exactly.
2. OMIT any section with nothing substantive to say. NEVER write `N/A`, `None`, or a restatement of the title.
3. KEEP checklist sections (`- [ ]`) intact and tick only what is genuinely done.
4. Write developer-clear prose: what changed and why, present tense, no marketing, no line-by-line retelling of the diff.
5. NEVER add a "Generated with Claude Code" footer.
6. When no template was found, write a minimal body -- one line for what, one line for why, test notes only if relevant -- and REMEMBER to say so in the final report.

### 5. Push and create

```bash
git push -u origin "$BRANCH"
gh pr create --draft --base "$DEFAULT_BRANCH" --title "$TITLE" --body-file "$BODY_FILE"
```

Write the body to a temporary file first so quoting cannot mangle it.

### 6. Report

1. Print the PR URL.
2. When no template was found, add: `No PR template found in this repo -- wrote a minimal body`.

## Important Notes

1. **NEVER** commit, amend, or stash. A dirty tree is a hard stop.
2. **NEVER** force-push.
3. **NEVER** mark the PR ready for review. It stays a draft.
4. **DO NOT** do anything beyond pushing the branch and opening the draft PR.
5. Non-GitHub remotes are unsupported. Report and stop.

## Error Handling

If any step fails:

1. Report the specific command that failed.
2. Show the error message.
3. Stop immediately.
4. Do not retry automatically.
