---
description: Push the current branch, then open a draft PR or update the existing one, following the repo template
allowed-tools: Bash, Read, Glob, Grep, Agent, mcp__claude_ai_Atlassian__getAccessibleAtlassianResources, mcp__claude_ai_Atlassian__getJiraIssue
model: haiku
effort: xhigh
disable-model-invocation: true
---

# Draft Pull Request

Push the current branch and open a draft PR (Pull Request) on GitHub, with a body that follows the repository's own PR template. When a PR already exists for the branch, update it instead.

## What This Command Does

1. Preflight. A dirty tree, the default branch, or a missing `gh` is a hard stop. An existing PR switches CREATE mode to UPDATE mode.
2. Gather context from the branch name and the commit subjects -- never the diff.
3. Resolve the Jira issue from the branch itself, reading its title only.
4. Find the repository's PR template.
5. Write the title, and the description as a numbered TLDR.
6. Read the diff ONCE, and only as deeply as its size warrants.
7. Add `### APIs` and `### Migrations` when the branch moves an interface.
8. Ask a subagent for a UML diagram when the change is large; it lands as `### Changes`.
9. Complete the rest of the template mechanically -- the ticket link, the checklists.
10. Push, then create the draft PR or update the existing one.
11. Report.

Steps 5 to 8 write INSIDE the template's description section, and nowhere else. Step 9 is the ONLY step that touches anything outside it.

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
DEFAULT_BRANCH="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)}"
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

6. An existing PR on the branch selects the mode:

```bash
gh pr view --json url -q .url
```

If it prints a URL, record it as `PR_URL` and run in UPDATE mode. Otherwise run in CREATE mode. Every other step is the same in both modes.

### 2. Gather context

```bash
git log --oneline "origin/$DEFAULT_BRANCH..HEAD"
```

The branch name and these commit subjects are the ONLY sources for the title (step 5) and the description's numbered list (step 5). Do NOT read the diff here -- it is read once, in step 6, and it feeds steps 7 and 8 alone.

Note whether the branch name or any commit subject carries a Jira key, e.g. `PROP-1234`.

### 3. Resolve the Jira issue

The card the branch is working on, or nothing. There is no second candidate.

1. A key found in step 2 IS the only candidate. Fetch its title only -- never its description, comments, or subtasks.
2. No key there: there is no card. Record NO key and move on.
3. Test the title against the branch's work. The card is UNRELATED when its title describes a different piece of work -- not merely a wider or narrower one. Then record NO key.
4. NEVER search Jira for a card. NEVER fall back to an epic. NEVER ask the user which issue to use.
5. Record the key as `ISSUE_KEY`, empty when step 2 or step 3 left you without one. Step 9 puts it under `## Tickets & Documentation`.

### 4. Find the PR template

Look in this order, first hit wins: `.github/PULL_REQUEST_TEMPLATE.md`, `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`, `docs/`, the repository root.

Read it whole before writing anything. Its headers, its order and its comments are the contract: you fill it in, you do not redesign it. When there is no template, write a minimal body -- a `## Description` section and nothing else -- and say so in the report.

### 5. Write the title and the description

#### Title rules

1. NO conventional-commit prefix.
2. Telegraphic, a few words, taking its lead from the branch name.
3. Connected PRs in different repos share one prefix.

#### Description rules

1. Think of it as a TLDR. Write it in the active output style.
2. A numbered list of telegraphic sentences: what changes for the user, what changes for the developer, or why it matters.
3. NEVER repeat the title verbatim. NEVER name files or symbols. NEVER restate the Jira issue.
4. The template asks you to justify your decisions: where the branch chose between real alternatives, give the reason in one clause. Nothing more.
5. Replace the template's empty `-` stub with your list. Never leave it sitting above or below it.

### 6. Read the change once

This is the ONLY place in the command that reads diff content. Steps 7 and 8 draw on what this step reads -- never call `git diff` for hunk content anywhere else. The step 8 subagent is the one exception: it reads the diff again, in its own context.

EVERY `git diff` in this command carries the exclude pathspecs below, so lockfiles, snapshots and generated files never reach a diff, a measurement, or a section.

1. Measure the change, so that a dependency bump cannot trigger a diagram:

```bash
git diff --shortstat "origin/$DEFAULT_BRANCH...HEAD" -- . \
  ':(exclude)**/*.lock' ':(exclude)**/pnpm-lock.yaml' \
  ':(exclude)**/*.snap' ':(exclude)**/*.generated.*'
```

Add insertions + deletions into `DIFF_TOTAL`.

2. `DIFF_TOTAL` above 100: read the full diff.

```bash
git diff "origin/$DEFAULT_BRANCH...HEAD" -- . \
  ':(exclude)**/*.lock' ':(exclude)**/pnpm-lock.yaml' \
  ':(exclude)**/*.snap' ':(exclude)**/*.generated.*'
```

3. `DIFF_TOTAL` of 100 or less: narrow before reading any content. List the changed paths first:

```bash
git diff --name-only "origin/$DEFAULT_BRANCH...HEAD" -- . \
  ':(exclude)**/*.lock' ':(exclude)**/pnpm-lock.yaml' \
  ':(exclude)**/*.snap' ':(exclude)**/*.generated.*'
```

Keep only the paths that can carry an interface change -- route and controller files, a package's declared public entry point (`package.json` `exports`/`main`/`types`, `src/index.*`, `__init__.py`, `mod.rs`), and migrations (`migrations/`, `db/migrate/`, `prisma/schema.prisma`, `alembic/versions/`). When nothing matches, there is no interface change: skip to step 8 with nothing to report. Otherwise read only those paths:

```bash
git diff "origin/$DEFAULT_BRANCH...HEAD" -- $CANDIDATE_PATHS
```

4. A `DIFF_TOTAL` of 300 or less means step 8 draws no diagram, whatever step 7 found.

### 7. The APIs and Migrations subsections

Build these from the diff read in step 6 -- NEVER from commit subjects, the Jira issue, or guesswork.

1. Method uppercase; the path exactly as it resolves at runtime, mount prefix included, NOT the fragment written in the handler file. When a route file's mount point isn't in the diff, `grep` for where it is mounted before printing the path.
2. Path params in `{braces}`, whatever the framework wrote: `:id`, `<int:id>`, `[id]`, `{id}` all become `{id}`.
3. `Body:` and query params appear ONLY when they changed; follow the **api** skill's endpoint usage format.
4. Mark every line `+` added, `~` changed, `-` removed. `~` is for a method and path that survive while the contract moves: request body, query params, response shape, status codes, auth.
5. A handler whose internals changed with no interface change is NOT listed.
6. Changed public package exports go in a second fenced block, language-tagged to the source, same `+ ~ -` markers. Only symbols reachable from a declared public entry point qualify -- an internal helper is never listed, even when it happens to be exported.
7. Migrations: canonical DDL, one statement per line, `;` terminated, forward direction only. Express ORM schema edits (Prisma, Alembic, ActiveRecord) as the equivalent DDL.
8. OMIT an empty block, and OMIT the whole subsection when every block in it would be empty. NEVER write `N/A` or `No API changes`.
9. NEVER list an endpoint, an export, or a statement you cannot point at a diff line for.

They are SUBSECTIONS of the description, after its numbered list, in this order: `### APIs`, `### Migrations`, then `### Changes` from step 8.

````markdown
## Description

1. Users export their own data as CSV from the account page.
2. Adds one endpoint and one table; existing exports are untouched.

### APIs

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

### Migrations

```sql
-- The branch's migrations, verbatim, in this one block
```
````

### 8. Diagram the change when it is large

1. A `DIFF_TOTAL` of 300 or less: no diagram. Skip this step.
2. Record the SHA the diagram's permalinks will point at, BEFORE calling the agent:

```bash
SHA="$(git rev-parse HEAD)"
```

3. Call the `Agent` tool ONCE, `subagent_type: "uml-diagram"`, with the grand context and `SHA`.
4. The agent returns a `### Changes` section. Paste it VERBATIM as the last subsection of the description.
5. When the agent reports the change is undiagrammable, omit the section and say why in one clause in the report.

### 9. Complete the rest of the template

Everything steps 5 to 8 AUTHOR lives inside the description section. NEVER add a prose section of your own anywhere else.

Outside the description, fill the template in ONLY where the change answers it mechanically. Obey the template's own instruction comments -- they define its notation. Leave verbatim every item you cannot point at evidence for: an untouched template beats a guess. NEVER delete a section, an instruction comment, a legend, or a footer the template ships.

Section by section, for the current Propel template:

1. `## Tickets & Documentation` -- one bullet per ticket, as a full URL: `https://propel-health-ai.atlassian.net/browse/$ISSUE_KEY`. An empty `ISSUE_KEY` leaves the section exactly as the template ships it -- NEVER link a card the work does not answer. A documentation link goes here only when the branch changed that document.
2. `## Visual Comparison/Preview (if applicable)` -- NEVER touch it. A screenshot, a GIF or a video is the author's to add.
3. `## Testing` -- NEVER write its prose; the testing a person performed is theirs to describe. Under `#### Have tests been added/updated?`, tick `👍 Yes` when the diff adds or changes test files, or `🙅 No, they aren't needed` when the branch touches no executable code at all. Anything else: leave all three unticked.
4. `## Checklist` -- mark an item `[N/A]` when the diff proves its condition absent: no endpoint change makes the Postman item N/A, no envar change makes the 1Password, `.env.template` and Terraform items N/A. Mark `[x]` ONLY for what the diff itself shows, e.g. `.env.template` really did change. NEVER tick an action that happens outside this repository -- a Postman collection, a 1Password entry, a companion Terraform PR -- leave it `[ ]` for the author.

A repo whose template has other sections still obeys the paragraph above: fill what the change answers, leave the rest.

### 10. Push, then create or update

Write the body to a temporary file, `BODY_FILE`, first, so quoting cannot mangle it.

#### Push

This command NEVER rebases. `/recommit` is the command that restructures a branch and rebases it.

1. `HEAD` never moves here, so the step 8 permalinks stay valid.
2. A branch whose history was rewritten before this command ran needs `--force-with-lease`. Test it:

```bash
git rev-parse --verify "origin/$BRANCH" >/dev/null 2>&1 \
  && git merge-base --is-ancestor "origin/$BRANCH" "$BRANCH"
```

3. It succeeds, or the remote branch does not exist yet -- push plainly:

```bash
git push -u origin "$BRANCH"
```

4. It fails -- the remote branch exists and is not an ancestor, so the history was rewritten:

```bash
git push -u origin "$BRANCH" --force-with-lease
```

5. A rejected push is a hard stop. NEVER rebase to clear it. Report it and say `/recommit` rebases the branch.

#### CREATE mode

```bash
gh pr create --draft --base "$DEFAULT_BRANCH" --title "$TITLE" --body-file "$BODY_FILE"
```

#### UPDATE mode

MERGE into the body that is already there, never overwrite it. Read it first:

```bash
gh pr view "$PR_URL" --json body -q .body > "$OLD_BODY_FILE"
```

Build `$BODY_FILE` from `$OLD_BODY_FILE` with these rules:

1. Replace the description section -- its header down to the next header of the same level -- with the one you wrote. Its `### APIs`, `### Migrations` and `### Changes` subsections go with it.
2. When the old body has no description section, add yours as the first section and change nothing else.
3. Keep EVERY other section byte for byte: resolved checklist items, review notes, sections a person added by hand. Step 9 fills the template items still left unresolved, and only those.
4. Keep the Jira link where it already sits. NEVER add a second one.

Then edit the PR:

```bash
gh pr edit "$PR_URL" --body-file "$BODY_FILE"
```

1. NEVER pass `--title`. A person may have renamed the PR. Report your derived title when it differs.
2. NEVER pass `--draft` or `--ready`. The PR keeps the state it has.

### 11. Report

1. Print the PR URL. Say whether the command created the PR or updated it.
2. Say whether the push was plain or `--force-with-lease`.
3. Name the template items step 9 filled, and any it left for the author. In UPDATE mode, name the sections you replaced, and print your derived title alongside the PR's when they differ.
4. When no template was found, add: `No PR template found in this repo -- wrote a minimal body`.
5. When step 3 linked no card, say so in one line -- the branch carried no key, or name the card it rejected and why. Otherwise say nothing about Jira.
6. When `DIFF_TOTAL` was above 300 and no diagram was drawn, add one clause saying why.

## Important Notes

1. **NEVER** commit, amend, or stash. A dirty tree is a hard stop.
2. **NEVER** rebase. **NEVER** force-push, with one exception: the step 10 `--force-with-lease`, on a branch whose history was already rewritten.
3. **NEVER** mark the PR ready for review. A new PR stays a draft; an existing PR keeps the state it has.
4. **NEVER** write to Jira -- no transitions, no comments, no field edits. This command reads only.
5. **DO NOT** do anything beyond pushing the branch and opening or updating the draft PR.

## Error Handling

If any step fails:

1. Report the specific command that failed.
2. Show the error message.
3. Stop immediately.
4. Do not retry automatically.

Jira is the one exception: a failure in step 3 leaves `ISSUE_KEY` empty, and the PR is still created.
