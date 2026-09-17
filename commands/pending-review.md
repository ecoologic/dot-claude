---
description: Review a PR and leave it on GitHub as a pending (draft) review — humble, brief, human
argument-hint: <pr-number> [focus or extra instructions]
allowed-tools: Bash, Read, Glob, Grep, Skill, Write, Agent
disable-model-invocation: true
---

# Pending Review

Review a pull request and leave the findings on GitHub as a PENDING (draft) review, written in the user's own voice. The user edits and submits it; this command NEVER submits.

## What This Command Does

1. Preflight. No `gh`, no repository, or no PR is a stop. An existing pending review is kept, not a stop.
2. Review the PR with the `code-review` skill, posting nothing.
3. Rewrite the findings as humble, brief, human questions inside a line budget.
4. Build the review JSON and check every anchor against the diff.
5. POST a new pending review, or add each comment to the pending review that already exists.
6. Report the draft and hand the submit decision back to the user.

## Implementation Steps

### 1. Preflight

Run all of these BEFORE anything that writes. Stop at the first failure and report the exact reason.

1. Inside a git repository, with `gh` authenticated:

```bash
git rev-parse --show-toplevel && gh auth status
```

2. Resolve `PR` from the first number in `$ARGUMENTS`. With no number, take the current branch's PR:

```bash
gh pr view --json number --jq .number
```

No PR resolves, STOP.

3. Read the PR and keep `headRefOid` as `COMMIT_ID` — the review anchors to it:

```bash
gh pr view $PR --json number,title,url,state,isDraft,headRefOid,headRefName,baseRefName
```

4. A closed or merged PR is a STOP unless `$ARGUMENTS` says otherwise.

5. Check for a pending review the user already owns. GitHub allows ONE pending review per user per PR, so an existing one is ADDED TO, never replaced:

```bash
gh api graphql -f query='query{repository(owner:"OWNER",name:"REPO"){pullRequest(number:PR){
  reviews(last:5,states:PENDING){nodes{id databaseId}}}}}'
```

Nothing comes back, take the NEW REVIEW path in step 5. An id comes back:

1. Keep `id` as `REVIEW_NODE_ID`, take the APPEND path in step 5.
2. Read what is already in it, so a finding already raised is NEVER repeated:

```bash
gh api repos/{owner}/{repo}/pulls/$PR/reviews/<databaseId>/comments --jq '.[] | "=== \(.path)\n\(.body)\n"'
```

3. NEVER delete a pending review. NEVER overwrite its `body`. The user may be writing in it right now.

### 2. Review the PR

1. Invoke the `code-review` skill on `$PR`, passing through any focus or depth wording from `$ARGUMENTS` (eg `with an eye on elegance, don't go too deep`).
2. NEVER pass `--comment` or `--fix`. `--comment` posts submitted comments, which is the opposite of this command.
3. Keep its verified findings — `{file, line, summary, failure_scenario}` — as raw material. Nothing is posted yet.
4. The user's own skills (`coding`, `typescript`, `testing`, `api`) set the bar for what counts as a finding.

### 3. Shape the comments

1. Budget: 50 lines TOTAL across all comment bodies, fewer is better. A number in `$ARGUMENTS` (eg `40 lines`) overrides it.
2. Rank findings by severity, keep the top ones that fit, drop the rest. NEVER cut a finding in half to fit.
3. Tone, every comment:
    1. ASK, never assert — `Have you considered...`, `Is this doing...?`, `Would this...`
    1. Hedge — `I think`, `maybe`, `not sure it matters much`, `happy to be wrong`
    1. ELI5 — plain words, short sentences, contractions.
    1. ONE concrete consequence, in the reader's terms: what breaks, for whom, when.
4. A finding that needs more than two sentences to explain MUST carry a worked example, and the example MUST come from RUNNING the code, never from reasoning alone:
    1. Give real input values and the wrong output they produce, named the way the code names them.
    1. Example of the target shape: `a set at /exclusion/bym and a leaf at /inclusion/hwu/exclusion/bym come out as current_scope=['Condition'], when the real parent is ['Encounter']`.
    1. Building the example IS the check. It regularly shows the finding is wrong — a tie that breaks the right way, a guard further up, a case that cannot be reached. DROP those findings, NEVER soften them into a vague worry.
    1. The example cannot be built, the finding is NOT verified. DROP it.
5. Pick ONE or TWO of the nicest things in the diff. Each gets its own comment: `:+1:` then one short generic line — `I like this`, `nice one`, `this is good`. NEVER explain the praise. NEVER praise a line the review also criticises.
6. A MINOR finding — a nit, a naming point, anything the author can ignore and still merge — starts its body with `:green_circle:` then a space. NEVER mark a non-minor finding this way.
7. NEVER severity labels, rubric language, headings, or bullet lists inside a comment. NEVER emojis, except the `:green_circle:` and `:+1:` markers above.
8. NEVER an attribution or "Generated with" footer. This posts under the user's own account; the attribution rule covers commit messages and PR descriptions, not review comments.
9. The summary `body` is one or two hedged lines naming the one finding worth reading first. Example of the target voice:

> A few small things below, plus one I think might be a real gap (schema endpoint missing saved_only). Nothing blocking, happy to be wrong on any of these!

### 4. Build the payload

1. Write the JSON to the session scratchpad as `pr<PR>_review.json`:

```json
{
  "commit_id": "<headRefOid>",
  "body": "<hedged one-liner>",
  "comments": [
    {
      "path": "packages/api/app/services/rls_service.py",
      "line": 188,
      "body": "Have you considered forcing `saved_only=True` here too, like the routes right around this one do? Without it, I think a member could see a draft nobody has saved yet."
    }
  ]
}
```

2. Anchoring rules. A bad anchor returns 422 and the WHOLE review fails:
    1. `path` exactly as the diff spells it, repo-relative.
    1. `line` MUST be a line the diff actually touches, RIGHT side by default.
    1. `side: "LEFT"` for a deleted line, `start_line` plus `line` for a range.
    1. Check every `path` and `line` against the diff BEFORE writing the file:

```bash
gh pr diff $PR
```

3. Validate the JSON before the POST:

```bash
jq . <scratchpad>/pr<PR>_review.json > /dev/null && echo VALID
```

### 5. Post it as pending

Preflight step 5 picked the path.

#### NEW REVIEW path — no pending review exists

```bash
gh api repos/{owner}/{repo}/pulls/$PR/reviews -X POST --input <scratchpad>/pr<PR>_review.json
```

1. Omitting `event` is what makes the review PENDING. NEVER pass `event`.
2. On 422, print the API message verbatim and STOP. NEVER retry blind.

#### APPEND path — `REVIEW_NODE_ID` exists

Add ONE comment per call, in rank order, with the `comments` array from step 4:

```bash
gh api graphql -f query='
mutation($reviewId:ID!,$path:String!,$line:Int!,$body:String!){
  addPullRequestReviewThread(input:{
    pullRequestReviewId:$reviewId, path:$path, line:$line, side:RIGHT, body:$body
  }) { thread { id path line } }
}' -f reviewId="$REVIEW_NODE_ID" -f path=... -F line=... -f body=...
```

1. The `body` summary from step 4 is DROPPED on this path. The review already has one, or the user is writing it.
2. `thread` comes back `null` with NO `errors` key, the comment did NOT attach. STOP after the FIRST null, report which ones landed, NEVER retry. Retrying returns the same null.
3. A null usually means the user has the review open in a browser tab. Say so, and offer to add the rest once they close it.
4. Check the result of every call before the next one. A half-posted run must be reported as such.

#### Both paths

1. NEVER `gh pr review --approve`, `--request-changes`, or `--comment`.
2. `gh` resolves `{owner}/{repo}` from the current repository. NEVER hardcode an owner.

### 6. Report

1. Print the review id, the PR URL, the comment count, and the lines used against budget.
2. Say which path ran: a NEW draft, or comments ADDED to the draft that was already there.
3. State that it is a draft, visible only to the user until submitted, and that submitting is the user's call.
4. List the findings that were dropped for budget, one line each, so the user can ask for them.

## Important Notes

- NEVER submit the review — pending is the whole point.
- NEVER post anything before the preflight passes.
- NEVER add findings the `code-review` skill could not verify.
- Less is better: six good comments beat twelve thin ones.
