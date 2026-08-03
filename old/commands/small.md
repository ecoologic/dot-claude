---
description: Delegate a small scoped task to a lightweight subagent
argument-hint: [file refs or scope hints] [goal]
---

# /small — Small Scoped Task via Subagent

Delegate a narrowly scoped task to a _lightweight_ subagent.

`$ARGUMENTS` expected shape: `[file refs, paths, or scope hints] [goal]`

Examples:
- `src/utils/date.ts simplify this helper`
- `README.md tighten install instructions`
- `settings.json clean up duplicated keys`
- `src/components/Modal.tsx keep this change tiny and local`

## Step 1: Parse arguments

From `$ARGUMENTS`, identify:

1. **Scope hints** (optional) — file paths, symbols, folders, or plain-English boundaries
2. **Goal** (required if not obvious) — the concrete small task to perform
3. **Constraints** (optional) — words like "docs only", "one file", "no tests", or "no behavior change"

If no actionable task can be inferred from `$ARGUMENTS`, **STOP** and ask the user for the smallest concrete task description. Do NOT guess.

## Step 2: Gather only the minimum context needed

- Resolve any referenced files or symbols with `Read`, `Glob`, or `Grep`
- Read only the files and ranges required to understand the requested small task
- If a referenced target cannot be found, **STOP** and report the mismatch — do NOT guess and do NOT widen the search unnecessarily

## Step 3: Scope check (reject out-of-scope up front)

`/small` is for **small, contained tasks**. Allow the task only if it looks safe for a lightweight model with limited exploration.

**Allowed examples:**

- Small code cleanup in one file or a few tightly related files
- Tiny docs or config edits
- Localized rename or wording cleanup
- Small bugfix with obvious scope and no architectural impact

**STOP** and tell the user the request is out of scope if it implies any of:

- Broad or unclear exploration before acting
- New abstractions, new modules, or new dependencies
- Architectural changes or multi-phase implementation
- Large refactors or behavior-heavy rewrites
- Touching many unrelated files
- Significant test work, CI fixing, or release work
- Any risk level that is too high for a lightweight model

When rejecting, suggest `/sup-design`, `/sup-plan`, or a normal implementation flow instead.

## Step 4: Delegate to the subagent

Invoke a lightweight subagent via the `Agent` tool with:

- `subagent_type`: choose the narrowest fitting type:
  - `code-simplifier` for contained cleanup or simplification
  - `generalPurpose` for other small tasks
- `model`: prefer Claude Sonnet 4.6 if the platform supports selecting it directly; otherwise omit the explicit model and use a lightweight default
- `description`: short 3-5 word task label
- `prompt`: self-contained, including the items below

Prompt contents (all required):

1. **Task summary** — the user's requested small task, verbatim when possible
2. **Scope lock** — exact files, ranges, symbols, or boundaries discovered in Step 2. Forbid unrelated edits.
3. **Guardrails**:
   - Keep the blast radius small
   - Avoid unnecessary exploration
   - Preserve public API unless the user explicitly requested otherwise
   - Do not add new dependencies
   - Do not expand into planning or redesign
   - If the task turns out to be larger than expected, stop and report instead of improvising
4. **Verification** — after editing, the agent must re-read the edited area and return:
   - a one-line change summary
   - the files touched
   - any follow-up that should be handled by a stronger workflow

Pass no extra project context beyond what the subagent needs to complete the bounded task.

## Step 5: Report

Output to the user, in this order:

1. Files touched
2. One-line change summary from the subagent
3. Follow-ups the subagent flagged — only if any

## Important Notes

- **PREFER** Claude Sonnet 4.6 when available, but **FALL BACK** to a generic lightweight model when the exact model cannot be selected
- **ALWAYS** keep the task small and bounded
- **NEVER** silently expand scope because the first request was underspecified
- **NEVER** continue once the task clearly needs planning, broader context, or a stronger model
- **DO NOT** run broad test, lint, or formatting workflows unless the user explicitly made that the small task
