---
description: Push the current branch and open a draft PR following the repo template
allowed-tools: Bash, Read, Glob, Grep, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__searchJiraIssuesUsingJql, mcp__claude_ai_Atlassian__getJiraIssue
model: haiku
effort: xhigh
---

# Draft Pull Request

Push the current branch and open a draft PR (Pull Request) on GitHub, with a body that follows the repository's own PR template.

## What This Command Does

1. Refuse to run unless the working tree is clean and no PR exists for the branch.
2. Read the commit subjects against the default branch to understand the change.
3. Find the Jira issue this branch belongs to, reading titles only.
4. Find the repository's PR template and fill only the sections that carry information.
5. Write the body in the active output style.
6. List the API, export and migration changes when the branch has any.
7. Append a UML diagram of the change when the diff is above 100 lines.
8. Push the branch and create the PR as a draft, then report its URL.

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
```

These commit subjects are ONE of the three sources for the title and body -- see step 5. Do NOT read the diff here; the diff is read once, later, in step 6.

### 3. Find the Jira issue

This step is cheap and quiet. Spend at most a few tool calls on it, read titles only, and NEVER let it change the PR body's substance.

1. If `BRANCH` or any commit subject contains an issue key (`[A-Z][A-Z0-9]+-\d+`), take that key and skip the search. Confirm it with `getJiraIssue`, requesting `fields: ["summary", "issuetype", "parent", "status"]`.

2. Otherwise resolve the site with `getAccessibleAtlassianResources` and search the user's in-progress work with `searchJiraIssuesUsingJql`:

```
cloudId:     <id or hostname from getAccessibleAtlassianResources>
jql:         assignee = currentUser() AND statusCategory = "In Progress" ORDER BY updated DESC
fields:      ["summary", "issuetype", "parent", "status"]
maxResults:  50
```

If that returns nothing, widen ONCE to `assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC` and stop there.

3. Choose the most specific issue whose SUMMARY describes the change in this branch:
   1. Prefer a sub-task over its task, a task over its story, a story over its epic.
   2. Use the parent ONLY when no child of it matches the branch.
   3. When a candidate's `parent` field names an epic, that epic is context for the choice, not a second thing to link.
4. Match on summaries, the branch name, and the commit subjects. Do NOT open descriptions, comments, acceptance criteria, or linked pages -- titles carry enough signal and anything more is wasted context.
5. When exactly one candidate plainly matches, take it silently. When several match, or none does, ask ONCE with a shortlist of `KEY -- summary` lines plus a "none" option, and wait. NEVER guess a key.
6. Record `ISSUE_KEY` and `ISSUE_URL` (`https://<site-host>/browse/<ISSUE_KEY>`). The issue summary itself is for your judgement only -- it does NOT go into the PR.
7. When the Atlassian MCP is unavailable, unauthenticated, or errors, or when the user answers "none": continue with NO key, and say so once in the final report. NEVER block the PR on Jira.

### 4. Find the template

Use the first of these that exists (case-insensitive):

1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `docs/pull_request_template.md`
4. `pull_request_template.md`

If `.github/PULL_REQUEST_TEMPLATE/` is a directory, list its templates and ask which one to use.

### 5. Write the title and body

Sources for BOTH the title and the body are ONLY: the commit subjects (step 2), the Jira issue title (step 3), and this conversation. The diff read in step 6 feeds ONLY the `## API`, `## Migrations` and `## Changes` sections -- NEVER let it shape the title, the summary sentence, or any template section.

Title: derive from the branch name when it carries meaning (`feat/user-export` becomes `Add user export`), otherwise from the single commit subject, otherwise from the Jira issue title when known. ALWAYS strip the `feat/`, `fix/`, `chore/` prefix.

Title rules:

1. Avoid conventional commits prefixes
1. Be telegraphic, a few words, take inspiration from the branch name
1. For connected PRs in different repos, use the same prefix
1. When `ISSUE_KEY` is known, prefix the title with the bare Jira issue key and one space: `PROP-5000 Add user export`. Nothing else -- no brackets, no summary, no URL in the title. This is the ONLY place Jira connects to the title.
1. Strip any key already embedded in the branch name so it appears exactly once.

Body rules:

1. When `ISSUE_KEY` is known, the link is the bare markdown `[PROP-5000](https://<site-host>/browse/PROP-5000)` -- no heading, no bold, no label, no issue summary, no `Closes`/`Fixes` keyword.
   1. When the template has a section whose header names the ticket (matching, case-insensitively, on `ticket`, `jira`, `issue`, or `story`), the link goes THERE and NOWHERE else: replace an empty placeholder (`-`, `N/A`, or blank) with it, or add it as that section's first line when the section already holds content.
   2. Otherwise, the link is the FIRST line of the body, followed by a blank line.
1. Then a telegraphic sentence on what this changes, product xor refactor
1. ALWAYS follow the template's section order and headers exactly.
1. OMIT any section with nothing substantive to say. NEVER write `N/A`, `None`, or a restatement of the title.
1. KEEP checklist sections (`- [ ]`) intact and tick only what is genuinely done.
1. Write developer-clear prose: what changed and why, present tense, no marketing, brief -- a sentence or two, not a commit-by-commit retelling.
1. NEVER restate, summarise, or paraphrase the Jira issue. The code changes are the subject of the PR; the ticket is a breadcrumb.
1. NEVER add a "Generated with Claude Code" footer.
1. When no template was found, write a minimal body -- the issue link line if any, one line for what, one line for why, test notes only if relevant -- and REMEMBER to say so in the final report.

### 6. Read the change once

This is the ONLY place in the command that reads diff content. Both the interface sections (step 7) and the size-gated diagram (step 8) draw from what this step reads -- never call `git diff` for hunk content anywhere else.

1. Measure the change, ignoring lockfiles and snapshots so a dependency bump cannot trigger a diagram:

```bash
git diff --shortstat "origin/$DEFAULT_BRANCH...HEAD" -- . \
  ':(exclude)**/*.lock' ':(exclude)**/package-lock.json' \
  ':(exclude)**/pnpm-lock.yaml' ':(exclude)**/yarn.lock' \
  ':(exclude)**/*.snap' ':(exclude)**/*.generated.*'
```

Add insertions + deletions into `DIFF_TOTAL`.

2. When `DIFF_TOTAL` is above 100, read the full diff. It covers both the interface sections below and the diagram in step 8:

```bash
git diff "origin/$DEFAULT_BRANCH...HEAD"
```

3. Otherwise (`DIFF_TOTAL` is 100 or less), narrow before reading any content. List changed paths first:

```bash
git diff --name-only "origin/$DEFAULT_BRANCH...HEAD"
```

Keep only paths that can carry an interface change -- route/controller files, a package's declared public entry point (`package.json` `exports`/`main`/`types`, `src/index.*`, `__init__.py`, `mod.rs`), and migration files (`migrations/`, `db/migrate/`, `prisma/schema.prisma`, `alembic/versions/`). When nothing matches, there are no interface changes -- skip to step 7 with nothing to report. Otherwise read only those paths:

```bash
git diff "origin/$DEFAULT_BRANCH...HEAD" -- $CANDIDATE_PATHS
```

4. Whichever diff was read, it feeds step 7. A `DIFF_TOTAL` of 100 or less means step 8 draws no diagram, regardless of what step 7 finds.

### 7. API and Migrations sections

Build these from the diff read in step 6 -- NEVER from commit subjects, the Jira issue, or guesswork.

1. Method uppercase; path exactly as it resolves at runtime, including the router's mount prefix, NOT the fragment written in the handler file. When a route file's mount point isn't in the diff, `grep` for where it's mounted before printing the path.
2. Path params in `{braces}` whatever the framework wrote -- `:id`, `<int:id>`, `[id]`, `{id}` all become `{id}`.
3. `Body:` and query params appear ONLY when they changed; follow the **api** skill's endpoint usage format.
4. Mark each line `+` added, `~` changed, `-` removed. Use `~` when the method and path survive but the contract moves: request body, query params, response shape, status codes, auth.
5. A handler whose internals changed with no interface change is NOT listed.
6. List changed public package exports in a second fenced block, language-tagged to the source, same `+ ~ -` markers. Only symbols reachable from a declared public entry point (`package.json` `exports`/`main`/`types`, `src/index.*`, `__init__.py`, `mod.rs`) qualify -- an internal helper is never listed even when it happens to be exported.
7. Migrations: canonical DDL, one statement per line, `;` terminated, forward direction only. Express ORM schema edits (Prisma, Alembic, ActiveRecord, etc.) as the equivalent DDL.
8. OMIT an empty block; OMIT the whole section (`## API`, `## Migrations`) when every block in it is empty. NEVER write `N/A` or `No API changes`.
9. NEVER list an endpoint, export, or statement you cannot point at a diff line for.

Place `## API` and `## Migrations`, in that order, after every section the template contains and before `## Changes`:

````markdown
## API

```sh
+ POST /users/{id}/exports Body: { "format": "csv" }
~ GET /users?filter[status]="active"
- DELETE /users/{id}/export
```

```ts
+ export function toCsv(rows: Row[]): string
~ export type ExportOptions = { format: 'csv' | 'json' }
- export function legacyExport(): void
```

`+` added, `~` changed, `-` removed.

## Migrations

```sql
ALTER TABLE users ADD COLUMN export_format TEXT NULL;
CREATE TABLE user_exports (id UUID PK, user_id UUID FK, created_at TIMESTAMPTZ);
CREATE INDEX idx_user_exports_user_id ON user_exports (user_id);
```
````

### 8. Diagram the change when it is large

Run this ONLY when `DIFF_TOTAL` from step 6 is above 100. A small PR gets NO diagram -- skip the whole step silently.

1. Draw from the full diff already read in step 6 -- do not read it again.

2. Apply the **diagrams** skill. Read it now and follow every rule in it -- UML, method-call arrow labels, blue for new elements with BOTH light and dark mode declared, and the legend after the diagram.

3. On top of that skill, for this command specifically:
   1. Diagram ONLY what this PR changes. Unchanged classes, services, or steps appear only when an arrow to or from them is needed to make the change legible, and they are NOT blue.
   2. Blue means added by this PR. Dotted lines mean removed or deprecated by this PR. Say so in the legend prose.
   3. Pick the UML form from the shape of the change: `classDiagram` for new or reshaped types and their relations, `sequenceDiagram` for a changed call flow across components, `stateDiagram-v2` for a changed lifecycle. ONE diagram, one form. NEVER draw a file tree or a flowchart of the commit history.
   4. When the change is genuinely undiagrammable -- a bulk rename, a config sweep, a formatting pass -- omit the section and say why in one clause in the final report.

4. Build the legend's link base ONCE so links survive later pushes:

```bash
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
SHA="$(git rev-parse HEAD)"
```

Each legend entry links to `https://github.com/$REPO/blob/$SHA/<path>#L<line>`, and its link TEXT is verbatim the label used in the diagram.

5. Append this as the LAST section of the body -- after everything the template contains, and after `## API` / `## Migrations` when either is present:

````markdown
## Changes

```mermaid
classDiagram
    ...
```

1. [Exporter#toCsv](https://github.com/acme/app/blob/<SHA>/src/export/exporter.ts#L42)
2. Blue: added by this PR. Dotted: removed by this PR.
````

6. Verify the mermaid parses before creating the PR -- balanced quotes, escaped `(`, `)`, `<`, `>` in labels, no stray backticks. A broken diagram is worse than none.

### 9. Push and create

```bash
git push -u origin "$BRANCH"
gh pr create --draft --base "$DEFAULT_BRANCH" --title "$TITLE" --body-file "$BODY_FILE"
```

Write the body to a temporary file first so quoting cannot mangle it.

### 10. Report

1. Print the PR URL.
2. When no template was found, add: `No PR template found in this repo -- wrote a minimal body`.
3. When no issue key was resolved, add one line saying so. Otherwise say nothing about Jira.
4. When the diff was above 100 lines but no diagram was drawn, add one clause saying why.

## Important Notes

1. **NEVER** commit, amend, or stash. A dirty tree is a hard stop.
2. **NEVER** force-push.
3. **NEVER** mark the PR ready for review. It stays a draft.
4. **NEVER** write to Jira -- no transitions, no comments, no field edits. This command reads only.
5. **NEVER** invent an endpoint, export, or DDL statement that no diff line supports.
6. **DO NOT** do anything beyond pushing the branch and opening the draft PR.
7. Non-GitHub remotes are unsupported. Report and stop.

## Error Handling

If any step fails:

1. Report the specific command that failed.
2. Show the error message.
3. Stop immediately.
4. Do not retry automatically.

Jira lookup is the one exception: a failure there degrades to "no key" and the PR is still created.
