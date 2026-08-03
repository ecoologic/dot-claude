---
description: Verify work with evidence before claiming completion
argument-hint: [Priority instructions or file to consider prompt]
---

## Precedence (high to low)

1. `<priority instructions>`
2. This file
3. Project rules and `CLAUDE.md`
4. Global skills and commands like `ecoologic-*`
5. `ecoologic-*` skills and commands
6. Superpowers (eg: `brainstorming` or `writing-plans`)

## Definitions

1. Branch: get it with `git rev-parse --abbrev-ref HEAD`
2. Plan: `./planning/{branch}/plan.md`

## Rules

* Follow the steps below in order, one by one in sequence, do not overstep
* If, at any point, you find bugs, invoke `ecoologic-debug` and `superpowers:systematic-debugging` and resolve
* Invoke `superpowers:dispatching-parallel-agents`
* Invoke `superpowers:verification-before-completion` before ticking any checkbox — evidence, not assumption

## Step 1 - test

1. Invoke `ecoologic-architecture`, `ecoologic-code`, `ecoologic-test`, read them fully
2. Write the black-box tests in spec format, focusing on domain and UX behavior; write test files _in parallel_ with different agents

## Step 2 - simplify

Run `/simplify`, then make sure all the relevant tests pass

## Step 3 - code review

1. Run `superpowers:requesting-code-review`
2. Implement solutions for the most important issues
3. Store unaddresses issues for later, to present to the user at the end
4. Make sure all the relevant tests pass

## Step 4 - verify

In parallel, analyze the work done with parallel **read-only** agents, they should provide clear output for the next step to act on:

* One agent to run all tests
* One agent for skill `review`
* One agent for skill `security-review`
* One agent for skill `superpowers:requesting-code-review`
* One agent for skill `superpowers:finishing-a-development-branch`

Then organize the findings (dedup, verify, prioritise). Be skeptical, some issues might be related, highlight a poor design or the solution might be a structural change.

## Step 5 - fix

1. Make a plan to fix all the issues, possibly keeping are of conflicts separated to use multiple agents
2. Decide which skills the new agents might need to solve their goal
3. Spin off agents as required

## Step 6 - polish

* Invoke `superpowers:verification-before-completion` in one agent
  * Pass the `{branch}` name (and `./planning/{branch}/` paths if useful) to that agent
* Make sure all tests are green
* Review all suggestions that we skipped deeming them not necessary; verify them again and present only the valid ones, in a table ordered by importance, with columns `n,file:line(where appropriate, also link),issue,example`

## Step 6.5 - checkpoint

Goal: tick verified `- [ ]` boxes in `super-plan.md`, surface the out-of-scope carryover so it doesn't get forgotten, and write `./planning/{branch}/progress.md` (or the arg-derived dir) as the single source of truth for what shipped.

Read-only evidence gathering first, then one write pass. **Never tick a box without citable evidence** — commit SHA, test name, or `file:line`.

1. **Resolve plan path** — default `./planning/{branch}/super-plan.md`. If `$ARGUMENTS` is a path to a `super-plan.md`, use that and derive the planning dir from its parent.
2. **Extract checkboxes** — scan the plan for `^- \[[ x]\]` lines; build `{line, text, state}` tuples. Also keep a note of each parent task heading so the progress table reads well.
3. **Gather evidence per unchecked item** — use `git log --all --oneline`, the Step 4 test output, and `Grep`/`Read` on the referenced source files. Classify each item as `shipped` / `partial` / `not shipped`.
4. **Extract carryover** — find any heading matching (case-insensitive) `## .*Out of scope.*` or `## .*tracked for later.*` or `## .*Out of .* scope.*`. Capture the full block (until the next `##` heading or EOF). Also scan any upstream design doc referenced from the plan (e.g. `all-design.md`) for the same patterns.
5. **Tick verified boxes** — single Edit pass on `super-plan.md`: `- [ ]` → `- [x]` only for items marked `shipped`. Leave `partial` and `not shipped` as `- [ ]`; note them in progress.md with why.
6. **Write `./planning/{branch}/progress.md`** using this template:

    ```markdown
    # Progress: {branch}

    **Status:** ✅ shipped | ⏳ in progress | ❌ blocked
    **Verified:** YYYY-MM-DD
    **PR:** #NNN — <title>  (omit if not merged)
    **Merge commit:** <sha>  (omit if not merged)

    ## Completion matrix

    | # | Task | Evidence | Status |
    |---|---|---|---|
    | 1 | ... | `<sha> <subject>` or `<test-name>` | ✅ |

    ## QA checklist

    Source: `super-qa.md` — manual UX passes, not auto-verified here.

    - [ ] Goal 1 (manual)

    ## Carryover — NOT done, do not forget

    > Paste these into the upstream roadmap / backlog doc.

    - Item ... (source: `super-plan.md:LINE` or `all-design.md:LINE`)

    ## Unaddressed issues from review

    From Step 6 findings that were consciously deferred:

    | # | file:line | issue | why deferred |
    |---|---|---|---|
    ```

7. **Surface carryover at end of turn** — print the `## Carryover` section verbatim, prefixed with:

    > These items are NOT done. Paste into your upstream roadmap or open tickets.

    This is the anti-forgetting guard. Do not skip it even if the carryover block is empty — print `(none)` instead.

Idempotency: re-running on the same branch must not double-tick and must overwrite progress.md cleanly.

## Step 7 - finish

Store a document in `./planning/{branch}/super-qa.md` based on this:

* Read again the related `./planning/{branch}/super-*.md` and define a clear step-by-step (like I'm 5) QA plan
* Assume docker is running and server is up
* Stay user centric, this is not a technical developer task
* For every intended goal:
  * Title and state the goal/benefit (user centric)
  * Description format of the related tests, using the actual test descriptions (eg and format template: `User -> create -> when on user page` -> `it creates a user`)
  * Provide urls to visit
  * Provide labels and texts to click, and text to input
  * Explain what we expect to see
* Checkbox ticking is handled by Step 6.5 — do not duplicate here.
