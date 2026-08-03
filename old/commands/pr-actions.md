---
description: Triage PR review comments, resolve stale ones, and present the remaining action list
---

**Precedence**

This command owns the workflow and output format. Its triage template, numbering rules, and cleanup rules take precedence over unrelated skills. Use `superpowers:dispatching-parallel-agents` only where this file explicitly allows it. Keep all GitHub writes and the final user-facing triage document in the main agent.

# Triage PR Review Comments

Fetch unresolved PR review comments from reviewers, verify whether each comment is valid, resolve duplicated, outdated, or already-addressed threads, minimize stale bot overview reviews, and present the remaining actionable results in code order as an action list for the user.

Argument: $ARGUMENTS

## Implementation Steps

### 1. Detect PR

If `$ARGUMENTS` is a number, use it as the PR number. Otherwise, detect from the current branch:

```bash
gh pr view --json number,url
```

If no PR is found, report the error and stop.

### 2. Fetch Review Data (GraphQL)

Use GraphQL to fetch the PR author, PR number, file order, unresolved review threads, top-level PR reviews, and PR-level issue comments.

```bash
bash ~/.agents/commands/scripts/pr-fetch-reviews.sh {owner} {repo} {number}
```

Replace `{owner}`, `{repo}`, and `{number}` with values from `gh repo view --json owner,name` and the PR number from step 1. The script outputs the full GraphQL response as JSON.

Do not change the query shape by probing GitHub's GraphQL schema or running introspection queries. Use only the fields and mutations documented in this command.

The fetched data must include every identifier needed for later cleanup writes:

- `pullRequest.number` for the REST reply endpoint
- each review thread `id` for `resolveReviewThread`
- each top-level review comment's `fullDatabaseId`, falling back to `databaseId` only if `fullDatabaseId` is absent
- each review comment's `replyTo { id }` so top-level comments can be identified without parsing URLs
- each substantive top-level human review's author login and body so general review comments can be validated too
- each PR-level issue comment's author login, body, `createdAt`, `updatedAt`, and `url` from `pullRequest.comments` — bots like `greptile-apps` post their overview here, not in `pullRequest.reviews`, and they typically edit a single comment in place rather than reposting

Only process threads where `isResolved: false`.

**Important:** the PR author is `pullRequest.author.login`, not the current authenticated GitHub user.

Ignore comments written by the PR author. If a thread contains both reviewer comments and PR author replies, only keep the reviewer comments for presentation, but read the PR author's replies as rebuttal context. If a thread has no reviewer comments left after filtering, drop it entirely.

Do not create or post replies in GitHub beyond the short duplicate/outdated/already-addressed notes needed immediately before auto-resolving a thread. Do not draft or post approval text unless the user explicitly asks in a separate follow-up.

When building links for the final output, convert review comment URLs to the Changes tab form: `.../pull/<n>/changes#r<id>`.

### 3. Expand the Review Set

Before analysis, build one combined review-input set:

1. unresolved threaded reviewer comments
2. substantive human top-level general review comments, including suggestion-style comments that appear as general review comments without a diff line attachment
3. substantive bot overview content from `pullRequest.comments` (issue-level), notably `greptile-apps` summaries

Number every raw review input before analysis and keep those raw numbers stable for the rest of the run:

- Number threaded reviewer comments first, in code order
- Then number substantive human general review comments, in review order after the threaded comments
- Bot overview comments from `pullRequest.comments` (e.g. greptile-apps) are not numbered as actionable inputs; their substance is summarized in `General comments summary` and any concrete claims they make are cross-checked against the threaded set and the current code (see "Issue-level bot overview comments" below)

When there are 2 or more independent validation domains, invoke `superpowers:dispatching-parallel-agents` and dispatch multiple `Agent` calls in parallel in a single assistant message.

Use a high bar for independence. Good split boundaries:

- Separate files or subsystems with unrelated logic
- Separate broad claims that require unrelated repo searches
- Separate review clusters whose reasoning and likely fixes do not overlap

Do not parallelize when comments are tightly related, likely duplicates of each other, or require shared reasoning to classify correctly.

When dispatching parallel agents:

- Keep likely duplicates in the same agent so dedupe signals are not lost
- Pass each agent only its assigned raw comment numbers, comment text, author replies, relevant file paths, and the minimum repo context needed
- Require each agent to stay read-only: no file edits, no GitHub writes, no final triage formatting, no numbering changes
- Require each agent to return, for every assigned raw comment:
  - a short issue summary
  - classification recommendation
  - effort and severity recommendation
  - likely duplicate relationships inside that agent's scope
  - cleanup recommendation, if any
  - concise code-based evidence and any ambiguity
- Require each agent to check recent commits for the affected LoCs and related tests so "going in circles" signals are surfaced early

If the review set is small or strongly coupled, do the validation in the main agent instead of spawning subagents.

For each remaining threaded reviewer comment:

1. Read the referenced file and the surrounding code near `line` or `startLine`.
2. If needed, inspect nearby symbols, related files, or tests.
3. If the comment makes a broader claim like "this pattern is wrong everywhere" or "this logic is duplicated", search the repo to verify that claim before deciding.
4. Keep notes on what the comment is asking for, whether it is actually correct, and roughly how much work it would take to address within this PR.

Be skeptical but fair. Verify against the code before deciding.

For each substantive human general review comment:

1. Read the body carefully and split it into concrete claims only when the claims are actually separable
2. If the body points to specific files, symbols, behaviors, or tests, inspect those directly
3. If the body raises a broader architectural, correctness, or maintainability concern, search the repo and nearby commits to verify whether the concern is real in this PR
4. If the body is useful but too broad to become a single fix item, keep it in `General comments summary`
5. If the body contains one concrete actionable issue, or a small set of tightly related actionable issues, convert it into a numbered triage item instead of summary-only text

Do not assume a general review comment is non-actionable just because it is not attached to a diff line. This includes suggestion-formatted review text that appears as a general comment rather than a diff-thread comment.

#### Issue-level bot overview comments (greptile and similar)

Some bots — `greptile-apps` is the canonical case — post their overview as a PR-level issue comment in `pullRequest.comments`, not as a review in `pullRequest.reviews`. Treat these specifically:

- Match by author. Greptile is `greptile-apps`. Body usually starts with a `<details><summary><h3>Greptile Summary</h3></summary>` block and may include `Confidence Score: N/5` and a `Prompt To Fix All With AI` block with concrete code snippets.
- These bots typically edit a single comment in place (`updatedAt > createdAt`) instead of reposting. Do not minimize earlier copies — there are usually none. Only the latest body matters.
- The overview commonly references **prior review threads** (some of which may already be resolved) and re-asserts P1/P2 findings. Do not promote these claims to numbered actionable items on trust. For each concrete claim:
  1. Find any matching threaded review comment in `pullRequest.reviewThreads` (resolved or not) — if it exists and is resolved, the bot's claim is most likely stale.
  2. Revalidate against current code on the branch. If the issue is actually fixed, mark the claim stale; if it is genuinely open, treat it like a substantive general comment per the rules above (numbered triage item if it maps to one concrete fix; summary-only otherwise).
  3. Concrete code snippets inside `Prompt To Fix All With AI` (or equivalent) blocks should be revalidated the same way before being numbered.
- Summarize the high-level body (summary + confidence score) in `General comments summary` so the user still sees the bot's read of the PR even when no claim survives revalidation.
- Do not post replies on issue-level bot comments as part of cleanup. The reply endpoint used by this command targets review-thread comments; issue comments are a different surface and bots like greptile do not consume replies there.

### 4. Classify Each Comment

#### Required skills for Validation and Follow-Up Work

Load the relevant skills below when they help validate whether a comment is actually correct in the context of the work we're doing. If valid comments would likely require code changes in a later follow-up, mention the relevant skills in the closing recommendation so the next step is clear, but do not start fixing anything in this command.

If the user later asks to fix one or more comments, revalidate each selected comment against the current codebase before editing anything. Treat this triage output as a starting point, not as final truth.

For that later follow-up:

- Re-read the current file, nearby symbols, and any related tests or call sites before deciding on the fix.
- Re-check the reviewer claim against the current code, not just the code state from when triage was written.
- Be more critical and more detailed than the initial triage. Look for stale assumptions, indirect fixes that already landed, changed root causes, and better-scoped fixes.
- If the user refers to a comment by number with their own summary, for example `3. <comment with reason>`, quickly verify that the requested number matches the intended triaged issue and that the user's summary still fits the actual reviewer comment and current code.
- If the number appears wrong, the user's summary does not match the triaged issue, or the request is ambiguous, stop and ask for confirmation before editing anything.
- If the underlying issue is no longer valid, or the important details materially changed, stop before editing and ask the user whether the item should now be treated as invalid or re-triaged with the updated details.
- Only proceed with implementation after that revalidation still supports the comment as actionable.

- If a later follow-up will involve implementation work, load `ecoologic-code`.
- If that later follow-up would touch `.ts`, `.tsx`, `.js`, or `.jsx` files, also load `typescript-best-practices`.
- If that later follow-up would touch React components or hooks, also load `react-best-practices`.
- If the valid comments are about UI, UX, layout, accessibility, or interaction design, also load `ux-laws` for that later follow-up.
- If the valid comments are specifically a UI review, design quality, or accessibility audit, also load `web-design-guidelines` for that later follow-up.

#### Process

Before proceeding, check all the recent commits for the affected LoCs and relative tests. Answer the question: "Are we going in circles? Are we applying a change that undoes a previous fix?". In that case, think deeper about the solution that fixes both issues raised. Sometimes it will mean undoing the latest change, sometimes we shouldn't do anything, and sometimes it will mean finding a solution that fixes both issues.

If parallel agents were used, do the final classification in the main agent after all agent results return:

- Reconcile disagreements before deciding
- Re-check any suspected cross-agent duplicate before deduping
- Re-check any comment whose validity depends on shared context across domains
- Treat agent output as analysis input, not as final truth
- Do not let any subagent print the final triage document or perform cleanup writes

Each comment must end up in exactly one category:

- `VALID[done]`: the reviewer is correct but the fix has already been applied
- `VALID[dup]`: the reviewer is correct but the fix will be made together with fixing a preceding comment
- `VALID[e:quick][s:<severity>]`: the reviewer is correct and the fix should be small, local, and low-risk
- `VALID[e:mid][s:<severity>]`: the reviewer is correct and the fix needs a moderate code change, touches a couple of call sites, or needs careful adjustment
- `VALID[e:long][s:<severity>]`: the reviewer is correct but the fix is broader, cross-cutting, or requires meaningful refactoring / follow-up work
- `INVALID`: when:
  - Useless defensive coding practice
  - The reviewer is mistaken
  - The reviewer is asking to complicate the logic for little benefit
    - This is common with Copilot
  - The reviewer is asking for checks that provide little benefit
  - The comment is based on a misunderstanding or outdated information

Severity: `low|mid|high`

When uncertain between `VALID[...]` and `INVALID`, default to `VALID[...]` with the best effort estimate.

If the PR author already replied explaining that the reviewer comment is wholly or partly based on a misunderstanding, stale assumption, or incorrect reading of the code, bias the classification toward `INVALID`. Treat the author's reply as evidence to verify against the code, not as automatic proof. When this is the deciding factor, explicitly include `author reviewed` in the `INVALID` explanation.

### 5. Dedupe Repeated Feedback

Group comments only when they are effectively the same issue and would receive the same reasoning and same fix. Use a high bar for dedupe.

Examples that should usually dedupe:

- The same missing null check called out in several files
- The same naming issue repeated across multiple call sites
- The same architectural concern repeated on multiple hunks

Examples that should usually stay separate:

- Similar wording but materially different fixes
- Same theme, different root cause
- Same reviewer concern, but one instance is valid and another is invalid

For each deduped issue:

- Keep the first comment as the canonical entry
- Record every display number that belongs to that repeated issue
- Preserve only the first comment's text in the final output
- Use the canonical threaded comment's GitHub review comment URL to derive a Changes tab link as the display link target when the canonical issue came from a review thread
- If the canonical issue came from a general review comment, keep it as a general review issue and do not fabricate a diff anchor
- Mention all matching numbers together, like `2, 5, 8.`
- Mark every non-canonical duplicate thread for resolution after classification is complete

### 6. Order Issues by Code Position

Present issues in this order:

1. All canonical issues with concrete PR diff positions, in PR diff order:
   - Use `pullRequest.files.nodes[].path` to determine file order.
   - Within a file, sort by the earliest available line: `startLine`, else `line`, else push to the end of that file.
   - For deduped issues, use the canonical comment's position.
2. Then all remaining canonical issues whose canonical source is a general review comment without a concrete diff position

### 7. Print the Final Triage Document Before Cleanup

Before any cleanup write, assemble the exact final user-facing triage document using the ordered issue list and the cleanup set you plan to execute. Print that complete document to the user first, then start the GitHub cleanup pass. Treat the printed document as the authoritative triage output for the rest of the run.

Start with:

```text
## PR #<number>: <title>
<url>
```

Then, if any threads are queued for auto-resolution or any stale bot overview reviews are queued for minimization, include this section before the actionable issue list:

```text
Resolved automatically:
- <n>. duplicate of #<canonical-number>
- <n>. outdated
- <n>. already addressed
- <author> overview review hidden
```

Then, if there are any substantive but non-actionable human general review comments, include this unnumbered section before the actionable issue list:

```text
General comments summary:
- @<reviewer login>: <brief summary of the substantive general comment body>
```

Then list each remaining deduped issue in order using exactly this shape:

```text
<n>[, <n2>, <n3>]. @<reviewer login>
[path/to/file.ts:<line>](<canonical-review-comment-changes-url>)
> <comment text truncated to one paragraph>

VALID[e:quick|mid|long][s:low|mid|high]
<brief paragraph with a tailored example of how this could go wrong in practice>

<brief paragraph with the suggested fix>
```

Or:

```text
<n>[, <n2>, <n3>]. @<reviewer login>
[path/to/file.ts:<line>](<canonical-review-comment-changes-url>)
> <comment text truncated to one paragraph>

INVALID
<telegraphic sentence explaining why>
```

If the canonical issue came from a general review comment rather than a diff thread, use this shape instead:

```text
<n>[, <n2>, <n3>]. @<reviewer login>
General review comment
> <comment text truncated to one paragraph>

VALID[e:quick|mid|long][s:low|mid|high]
<brief paragraph with a tailored example of how this could go wrong in practice>

<brief paragraph with the suggested fix>
```

Or:

```text
<n>[, <n2>, <n3>]. @<reviewer login>
General review comment
> <comment text truncated to one paragraph>

INVALID
<telegraphic sentence explaining why>
```

Presentation rules:

- Number every raw review input first, before deduping. Threaded reviewer comments come first in code order; substantive human general review comments come after them in review order. If comments 4 and 7 are duplicates of comment 2, the canonical entry should render as `2, 4, 7.`
- Do not include auto-resolved duplicate, outdated, or already-addressed threads in the actionable issue list. Mention them only in `Resolved automatically`.
- Do not include minimized top-level bot overview reviews in the numbered issue list. Mention them only in `Resolved automatically`.
- Do include substantive but non-actionable human general review comments in `General comments summary`.
- Do include actionable human general review comments in the numbered issue list.
- Render `path:line` as a markdown link to the canonical PR review comment's Changes tab URL, for example `https://github.com/owner/repo/pull/326/changes#r2929596414`.
- For actionable general review issues without a concrete diff anchor, render `General review comment` as plain text, not as a fake `path:line`.
- Truncate the quoted reviewer text to a single paragraph. Remove extra blank lines and shorten if needed, but preserve the substance.
- For `VALID[...]` items, write exactly two short paragraphs: first the tailored failure mode example, then the suggested fix.
- Do not include planned GitHub reply text.
- Do not include storage paths or persistence details in the main triage list itself.
- Keep explanations concise but specific to the code.
- The `Resolved automatically` section is the cleanup plan that will be executed immediately after this document is printed. Do not wait until after cleanup to print the document.

### 8. Cleanup conversations

After classification and dedupe are complete, resolve review threads in GitHub when any of these is true:

- The thread is a non-canonical duplicate of another issue
- The thread is classified `VALID[done]` because the fix is already present
- The thread is classified `INVALID` because it is outdated or already addressed

In those cases, leave a short explanation reply before closing.

Do not use parallel agents for cleanup. Cleanup is stateful GitHub mutation work and must run only in the main agent, serially, using the exact cleanup set that was already printed to the user.

Before any cleanup write:

- Pick a top-level reviewer comment from the thread, meaning `replyTo` is null
- Use that top-level comment's REST comment identifier for replies: prefer `fullDatabaseId`, fall back to `databaseId` only if `fullDatabaseId` is absent
- Do not derive the reply comment id from the comment URL
- Do not use GraphQL introspection or schema-discovery queries
- If `pullRequest.number`, `threadId`, or the top-level reply comment id is missing, report the missing identifier and stop before making any cleanup write

Use the REST reply endpoint below once per thread that should be auto-resolved:

```bash
short_reason="$(cat <<'EOF'
{short-reason}
EOF
)"
gh api repos/{owner}/{repo}/pulls/{pull_number}/comments/{comment_id}/replies --raw-field body="$short_reason"
```

Quoting requirements for this REST reply step:

- Do not inline arbitrary reply text inside single quotes
- Always build the reply body first, then pass it as `--raw-field body="$short_reason"`
- Use the heredoc form above even for short one-line replies so apostrophes, quotes, backticks, and punctuation do not break the shell command
- If the constructed command still contains an inline literal body like `-f body='...'`, treat it as malformed command construction and fix it before running any GitHub write

Run the reply creation and the thread resolution as separate commands so the failing write is unambiguous. Do not combine cleanup writes into one shell line with `&&`.

To stay below GitHub secondary rate limits during cleanup:

- Run cleanup writes serially, never concurrently
- Wait at least 1 second between every mutating GitHub request in this section, including reply creation, `resolveReviewThread`, and `minimizeComment`
- If GitHub returns a rate limit response with `retry-after`, report it and stop without retrying automatically
- If GitHub returns `x-ratelimit-remaining: 0`, report that the primary limit is exhausted and stop
- If GitHub returns a secondary rate limit error without `retry-after`, report that it is likely a burst-content or per-minute secondary limit and stop

Do not resolve the canonical thread for a still-valid issue. Do not resolve a thread just because it is low severity.

Use the GraphQL mutation below once per review thread that should be resolved:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread {
      id
      isResolved
    }
  }
}' -f threadId='{threadId}'
```

Track which raw comment numbers were resolved automatically and why:

- `duplicate of #<canonical-number>`
- `outdated`
- `already addressed`
- `author reviewed`

Also clean up stale top-level bot overview reviews and separately analyze substantive human general review comments. Use a separate pass over `pullRequest.reviews`:

- Consider only reviews from `cursor` and `copilot-pull-request-reviewer`
- Consider only reviews that are general overview reviews, for example:
  - Cursor review body contains `Cursor Bugbot has reviewed your changes`
  - Copilot review body contains `## Pull request overview`
- Group those reviews internally by author
- Keep only the latest matching review per author
- For every older matching review that is not already minimized and `viewerCanMinimize` is true, minimize it with classifier `OUTDATED`
- Do not include these internal groups in the user-facing numbering or actionable list

Issue-level bot overview comments in `pullRequest.comments` (e.g. `greptile-apps`) are handled differently:

- Do not minimize them and do not post replies. They are typically a single comment edited in place — there are no older copies to hide, and the reply endpoint used elsewhere in this command targets review-thread comments, not issue comments.
- Their content is summarized in `General comments summary` and revalidated per the "Issue-level bot overview comments" rules in step 3.

For human general review comments:

- Consider only reviews whose author is not `cursor` or `copilot-pull-request-reviewer`
- Consider only reviews with a non-empty `body`
- Ignore pure approval boilerplate with no actionable substance
- Validate the substance of those bodies against the code just like review-thread comments
- Treat suggestion-style review text in those bodies as substantive general comments when it is not attached to a diff line
- If a body contains one concrete actionable issue, or a small tightly-related actionable cluster, turn it into a numbered issue item
- If a body is substantive but too broad, too vague, or too high-level to map to one actionable issue item, summarize it in `General comments summary`
- If a general comment duplicates an existing threaded issue, dedupe it into that canonical issue instead of printing it twice
- If there are no substantive human general review comments left after this split, omit `General comments summary`

Use this GraphQL mutation once per stale top-level review that should be hidden:

```bash
gh api graphql -f query='
mutation($subjectId: ID!) {
  minimizeComment(input: {subjectId: $subjectId, classifier: OUTDATED}) {
    minimizedComment {
      isMinimized
    }
  }
}' -f subjectId='{reviewId}'
```

Track minimized top-level reviews separately as:

- `<author> overview review hidden`

If a cleanup write is needed but a required identifier is missing, report which identifier is missing and stop before writing anything.

If a thread resolution or review minimization API call fails, report the failing command and stop instead of continuing with partial state.

NOTE: If the prompter asks to "cleanup the conversation", these above are the rules.

After the final triage document from section 7 has been printed, execute the queued cleanup writes. Use the same `Resolved automatically` set that was already shown to the user. Do not silently add new cleanup items after printing the document.

### 9. Close with a Clear Next Step

After the numbered list, close with:

1. Make it explicit that this command triages the unresolved review comments, may resolve duplicate, outdated, or already-addressed review threads, and may minimize stale bot overview reviews, but does not start fixes, post review replies beyond cleanup notes, or push anything.
2. Offer to address the valid comments in order only if the user explicitly asks in a follow-up message.
   - Make it explicit that the follow-up will revalidate each selected comment against the updated code before any fix starts.
   - Make it explicit that numbered shorthand like `3. <comment with reason>` will be sanity-checked against the triaged issue before any fix starts.
   - Make it explicit that the later fix follow-up may use multiple agents when the selected comments split into independent implementation domains.
   - Make it explicit that tightly related comments, duplicate fixes, or changes touching the same code path should stay in one implementation stream instead of being parallelized.
3. If any valid comment would require code changes in that later follow-up, mention the relevant skills loaded from the section above.
4. Offer to store the triage result in `./tmp/pr-<number>.md` for a clean follow-up agent, and make it clear that a simple reply of `write` should trigger that storage.
5. If all valid comments have already been addressed and all duplicate, outdated, or already-addressed threads were resolved, say the branch may be ready to push, but do not push anything as part of this command until told.

Example closing line:

```text
This command triages the unresolved review comments, may resolve duplicate, outdated, or already-addressed review threads, and may minimize stale bot overview reviews. It does not start fixes, post GitHub replies beyond cleanup notes, or push the branch.

If you want, I can address the valid items in order in a follow-up message, starting with #<first-valid-comment-number>. I will revalidate each selected comment against the updated code before fixing it, and I will sanity-check numbered shorthand like `3. <comment with reason>` before acting on it. If the selected items split into independent implementation domains, that later fix pass may use multiple agents; if they touch the same code path or are coupled, it will stay in one implementation stream.

Loaded relevant skills: `ecoologic-code`, `typescript-best-practices`

If all valid items are already addressed, the branch may be ready to push.

Reply `write` if you want me to store this triage as `./tmp/pr-<number>.md`
```

The prompter will use the comment numbers to address the various comments.

### 10. Optional Handoff File

If the user replies `write`, store the triage result in `./tmp/pr-<number>.md`.

If `./tmp/pr-<number>.md` already exists, treat it as stale and replace it without asking the prompter for confirmation.

Requirements for that file:

- Make it self-contained so a fresh agent can understand the context with no prior chat history.
- Start by stating that this document is the current PR comment triage and that the next step is to address the valid PR comments by their numbers.
- Include the PR number, title, and URL.
- Include the `Resolved automatically` section exactly as shown to the user, if present.
- Include the `General comments summary` section exactly as shown to the user, if present.
- Include the same numbered deduped issue list that was shown to the user, preserving numbering exactly.
- Preserve each issue's reviewer login, linked `path:line`, comment excerpt, and `VALID[e:quick|mid|long][s:low|mid|high]` or `INVALID` reasoning.
- Preserve duplicate-number groupings such as `2, 5, 8.`
- Preserve important context such as `author reviewed` when it was part of the reasoning.
- Include the relevant loaded skills if code changes are expected.
- Explicitly instruct the next agent to use those skills while revalidating and addressing the valid comments.
- Explicitly instruct the next agent to sanity-check numbered follow-up requests like `3. <comment with reason>` against the actual triaged item before editing.
- Explicitly instruct the next agent to revalidate each valid comment against the current code before editing, and to stop and ask the user if the underlying issue became invalid or the important details changed.
- Explicitly instruct the next agent to use multiple agents only when the selected fix items are truly independent implementation domains with low conflict risk.
- Explicitly instruct the next agent to keep coupled fixes, same-file clusters, and likely overlapping refactors in one implementation stream.
- Explicitly instruct the next agent to run `/simplify` only on the final user-facing response from that later fix follow-up, not on the triage report and not on the handoff file contents.
- End with a short instruction that the next agent should address the valid comments in numeric order unless told otherwise.

When writing this file:

- Reuse the already-produced triage output rather than regenerating it from scratch.
- Ensure `./tmp` exists first.
- Overwrite any existing `./tmp/pr-<number>.md` file with the latest triage output.
- After writing, tell the user the exact file path that was created.

### 11. Later Fix Follow-Up Rules

If the user later asks to fix selected items, for example with a message like `fix this shit`, treat that as a separate implementation pass guided by the triage output above.

For that later fix follow-up:

- Revalidate each selected item against the current code before editing anything
- If the user request is broad, default to addressing valid items in numeric order
- If the selected items split into 2 or more independent implementation domains, invoke `superpowers:dispatching-parallel-agents` and dispatch multiple agents in parallel
- Give each fix agent a narrow, self-contained scope with:
  - the selected comment numbers
  - the relevant files or symbols
  - the current triage reasoning
  - the requirement to revalidate before editing
  - explicit boundaries to avoid unrelated changes
- Keep related fixes together in one agent when:
  - they touch the same file or symbol cluster
  - one fix may invalidate or subsume another
  - they are likely duplicates with one shared implementation
  - they need shared architectural reasoning
- Keep final coordination in the main agent:
  - reconcile agent outputs
  - resolve conflicts
  - run verification
  - present the final fix summary to the user
- Do not let subagents produce the authoritative final user-facing fix report on their own

Run `/simplify` only at the very end of that later fix follow-up response, not during the triage report creation above and not when writing `./tmp/pr-<number>.md`.

Treat that `/simplify` pass as wording cleanup only. Preserve all required substance exactly:

- Keep the selected issue numbers and their mapping to the implemented fixes
- Keep any validation notes about items that changed or became invalid
- Keep any verification results, remaining risks, and skipped items
- Keep any required mention of loaded skills
- Do not remove ambiguity notes, caveats, or error details that affect correctness
- Do not rewrite the response into a different structure that obscures which triaged items were addressed

## Reply Guidelines

- Validate comments against the actual code before deciding.
- Do not invent certainty. If the code is ambiguous, say why, then choose the most defensible classification.
- Use the response you already produced.
- Parallelize only independent read-only validation work. Keep dedupe, final classification reconciliation, final formatting, and all GitHub writes in the main agent.
- Do not run `/simplify` on the triage report itself. Use it only on the later fix follow-up response, if such a follow-up happens.
- Treat repeated comments as one issue only when they genuinely share the same fix and reasoning.
- Resolve duplicate and outdated threads only after validation and dedupe are complete.
- Minimize stale top-level bot overview reviews only after the active latest review for that author is identified.
- When in doubt between `VALID[...]` and `INVALID`, default to `VALID[...]`.
- Do not start fixing files, posting substantive GitHub comments, or pushing the branch as part of this command.
- If the user references a numbered item with their own summary, quickly verify the number and summary match the intended issue before acting.
- If the user later asks for fixes, revalidate against the current code before editing and stop to ask the user if the issue no longer holds or materially changed.

## Error Handling

If any step fails:
- If the command as written here does not provide a required identifier, report the missing identifier and stop before any GitHub write
- If a GitHub command was constructed incorrectly, report that exact command and why it does not match the templates in this file
- Report the specific command that failed and its error output
- If the failure happened after triage analysis started and after the section 7 document was printed, explicitly say that the final triage document was already printed before cleanup started and that the command stopped on the first cleanup write failure to avoid further partial GitHub mutations
- In that explanation, summarize the debugging details in technical terms: which cleanup step was running, whether it was a REST reply, `resolveReviewThread`, or `minimizeComment`, which identifier or endpoint was involved, and whether the failure points to malformed command construction, missing identifiers, rate limiting, permissions, or a GitHub-side rejection
- Stop and ask the user how to proceed
- DO NOT retry automatically
