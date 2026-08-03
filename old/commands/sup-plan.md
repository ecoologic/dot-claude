---
description: Write a detailed implementation plan from a design document
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
2. Design: `./planning/{branch}/design.md`
3. Plan: `./planning/{branch}/plan.md`

## Rules

- Work in plan mode, you are allowed to write any file inside `./planning/` without asking permission
- Whenever superpower skills talk about `docs/superpowers/specs/YYYY-MM-DD-<topic>-[design|plan].md`, replace that with `./planning/{branch}/[design|plan].md`
- Invoke `superpowers:dispatching-parallel-agents` for the planning work itself: split investigation into non-conflicting domains and dispatch one agent per domain in a single assistant message
- The produced plan MUST mark each task with the parallelisation domains it belongs to, so `/sup-code` can fan out via `superpowers:dispatching-parallel-agents` without re-deriving the grouping (this is one of the reasons to have design and plan separate)
- Invoke `superpowers:writing-plans`, `ecoologic-architecture` and `ecoologic-plan` in every agent

## Supporting documentation

Create a new file `./planning/{branch}/doc.md` with the following sections:

1. Sequence diagram: the full mermaid sequence diagram for the planned changes
2. Endpoints: a single code block with all new or changed endpoints, format example: `GET /users`
2. Migrations: a single SQL block with all the changes (no down migrations)

## When done

1. Store the plan in `./planning/{branch}/plan.md`
2. Suggest the user `/clear` and `/sup-code`
3. DO NOT use `AskUserQuestion` for "Ready to proceed?" at the end. It's OK before completing the work
4. Once the plan is clear and right before code execution, give a brief T-shirt size estimate of how many tokens implementation could take. This is usually when you say something like: "Ready to kick off execution. Subagent-driven (recommended) or inline?"
