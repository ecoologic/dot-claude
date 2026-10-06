---
description: Push the current branch, then open a draft PR or update the existing one, following the repo template
argument-hint: "[--base <branch>] [--epic <url>]"
allowed-tools: Bash, Read, Glob, Grep, Agent
model: haiku
effort: xhigh
disable-model-invocation: true
---

# Draft Pull Request

Push the current branch with `/push`. Then open a draft PR (Pull Request), or update the existing one. The body fills `.github/PULL_REQUEST_TEMPLATE.md`.

## Implementation Steps

### 1. Preflight

Run all checks BEFORE anything that writes. Stop at the first failure. Report the exact reason.

Shell variables do not survive between `Bash` calls. Write the resolved values literally in every later command, or redefine them in the same call.

1. Resolve the values:

```bash
git rev-parse --show-toplevel
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
DEFAULT_BRANCH="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"
```

2. `BRANCH` is `DEFAULT_BRANCH` → STOP
3. `gh auth status` fails → STOP
4. `.github/PULL_REQUEST_TEMPLATE.md` is missing → STOP
5. `BASE_BRANCH`: the value after `--base` in `$ARGUMENTS`, else `DEFAULT_BRANCH`. `git rev-parse --verify "origin/$BASE_BRANCH"` fails → STOP
6. `BASE_BRANCH` is not `DEFAULT_BRANCH` and `gh pr list --head "$BASE_BRANCH" --state merged --json number` prints a PR → STOP. The branch needs a rebase onto `DEFAULT_BRANCH`
7. `EPIC_URL`: the value after `--epic` in `$ARGUMENTS`, else none
8. `gh pr view --json url -q .url` prints a URL → record `PR_URL`, UPDATE mode. Else CREATE mode

### 2. Push

1. `git status --porcelain` is not empty → commit it, per the repo's commit convention. NEVER stash
2. Call the `Agent` tool ONCE, `model: "haiku"`, with this prompt:

```text
Read ~/.claude/commands/push.md and follow it literally in <REPO_ROOT>.
You cannot dispatch the conflict agent of its step 3: on a rebase conflict, run `git rebase --abort` and stop.
Report: its step 6 report, or the failed command and its error.
```

3. Verify. `git rev-parse HEAD` MUST equal `git rev-parse "origin/$BRANCH"`. Else STOP, print the agent's report, and tell the user to run `/push`
4. `HEAD` never moves after this step

### 3. Write the title and the TLDR

Sources: the branch name and `git log --oneline "origin/$BASE_BRANCH..HEAD"`. NEVER the diff.

1. Title: telegraphic, a few words, led by the branch name. NO conventional-commit prefix. Connected PRs in different repos share one prefix
2. TLDR: 6 numbered items max, 100 words max in total. HARD limits
3. Each item: what changes for the user or the developer, or why it matters. A decision between real alternatives gets its reason as one clause, inside the limit
4. NEVER repeat the title. NEVER name files or symbols
5. The TLDR replaces the template's empty `-` stub under its description header

### 4. Read the diff once

The ONLY step that reads diff content. EVERY `git diff` carries these excludes:

```bash
EXCLUDES=(':(exclude)**/*.lock' ':(exclude)**/pnpm-lock.yaml' ':(exclude)**/*.snap' ':(exclude)**/*.generated.*')
```

1. `git diff --shortstat "origin/$BASE_BRANCH...HEAD" -- . "${EXCLUDES[@]}"`. Insertions plus deletions is `DIFF_TOTAL`
2. `DIFF_TOTAL` above 100 → read the full diff: `git diff "origin/$BASE_BRANCH...HEAD" -- . "${EXCLUDES[@]}"`
3. `DIFF_TOTAL` of 100 or less → list paths with `--name-only`. Keep only interface paths: routes and controllers, public entry points (`package.json` `exports`/`main`/`types`, `src/index.*`, `__init__.py`, `mod.rs`), migrations (`migrations/`, `db/migrate/`, `prisma/schema.prisma`, `alembic/versions/`). Read the diff of those paths only. None → skip step 5

### 5. APIs and Migrations

Subsections after the TLDR, in this order: `### APIs`, `### Migrations`, `### Changes`. Every line points at a diff line from step 4, else it is not listed.

1. Endpoints: method uppercase. Path as it resolves at runtime, mount prefix included; `grep` for the mount when the diff lacks it
2. Path params in `{braces}`: `:id`, `<int:id>`, `[id]` all become `{id}`
3. `Body:` and query params ONLY when they changed, per the **api** skill's endpoint format
4. Markers: `+` added, `~` contract changed (body, query, response, status, auth), `-` removed. Internals-only changes are NOT listed
5. Public exports: a second fenced block, tagged with the source language, same markers. Only symbols reachable from a public entry point
6. Migrations: canonical DDL, one `;`-terminated statement per line, forward only. ORM schema edits become the equivalent DDL
7. OMIT an empty block. OMIT an empty subsection. NEVER write `N/A`

````markdown
## Description

1. Users export their own data as CSV from the account page.
2. One new endpoint and table; existing exports untouched.

### APIs

```sh
+ POST /users/{id}/exports Body: { "format": "csv" }
~ GET /users?filter[status]="active"
```

### Migrations

```sql
CREATE TABLE exports (id uuid PRIMARY KEY, user_id uuid NOT NULL);
```
````

### 6. Diagram when large

1. `DIFF_TOTAL` of 300 or less → skip
2. Call the `Agent` tool ONCE, `subagent_type: "uml-diagram"`, with the branch context and `SHA="$(git rev-parse HEAD)"`
3. Paste its `### Changes` section VERBATIM as the last subsection. Undiagrammable → omit it

### 7. Fill the rest of the template

Steps 3 to 6 write ONLY inside the description section. Outside it, fill only what the diff answers mechanically. An untouched item beats a guess.

1. Obey the template's instruction comments
2. NEVER delete a section, comment, legend or footer
3. NEVER touch tickets, documentation links, screenshots or testing prose. These belong to the author
4. Tick `[x]` only what the diff shows, eg `.env.template` changed. Mark `[N/A]` only when the diff proves the condition absent, eg no endpoint change
5. NEVER tick an action outside this repo (Postman, 1Password, a Terraform PR). Leave it `[ ]`
6. A tests question: `👍 Yes` when the diff changes test files; `🙅 No, they aren't needed` when it touches no executable code. Else leave it unticked

### 8. Create or update

Write the body to a temporary `BODY_FILE`.

#### CREATE mode

```bash
gh pr create --draft --base "$BASE_BRANCH" --title "$TITLE" --body-file "$BODY_FILE"
```

`BASE_BRANCH` is not `DEFAULT_BRANCH` → link the stack, bottom first, by PR number only (a branch name makes `gh stack link` push):

```bash
gh stack link "$(gh pr view "$BASE_BRANCH" --json number -q .number)" "$(gh pr view --json number -q .number)"
```

`gh extension list` lacks `github/gh-stack` → skip the link. Report `gh extension install github/gh-stack`.

#### UPDATE mode

MERGE into the existing body. NEVER overwrite it.

1. `gh pr view "$PR_URL" --json body -q .body > "$OLD_BODY_FILE"`
2. Replace the description section, down to the next header of its level, with the new one
3. No description section → add the new one first
4. Keep EVERY other section byte for byte. Step 7 fills only unresolved items
5. `gh pr edit "$PR_URL" --body-file "$BODY_FILE"`
6. NEVER pass `--title`, `--draft` or `--ready`
7. Pass `--base "$BASE_BRANCH"` ONLY when `--base` differs from the PR's `baseRefName`, or the PR's base has a merged PR

### 9. Report

1. The PR URL, and created or updated
2. `EPIC_URL` set → `Epic: <EPIC_URL>`
3. The base, and stack link or retarget
4. The push agent's report
5. Template items filled, and items left for the author
6. UPDATE mode: the derived title, when it differs from the PR's
7. `DIFF_TOTAL` above 300 and no diagram → one clause on why

## Important Notes

1. **NEVER** mark the PR ready for review
2. **DO NOT** do anything beyond the push and the draft PR

## Error Handling

A failed step: report the command and its error. Stop. Do not retry.
