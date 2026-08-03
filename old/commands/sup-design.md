---
description: Brainstorm and design before implementation
argument-hint: [Priority instructions or file to consider prompt]
---

## Precedence (high to low)

1. `<priority instructions>`
2. This file
3. Project rules and `CLAUDE.md`
4. Global skills and commands like `ecoologic-*`
5. `ecoologic-*` skills and commands
6. Superpowers (eg: `brainstorming` or `writing-plans`)

## Rules

1. Work in plan mode, you are allowed to write any file inside `./planning/` without asking permission
2. Whenever superpower skills talk about `docs/superpowers/specs/YYYY-MM-DD-<topic>-[design|plan].md`, replace that with `./planning/{branch}/[design|plan].md`

## Definitions

1. Branch: get it with `git rev-parse --abbrev-ref HEAD`
2. Design: `./planning/{branch}/design.md`
3. Plan: `./planning/{branch}/plan.md`

## Parallelisation

Follow `superpowers:dispatching-parallel-agents`. Dispatch **2–3 Agent calls in parallel** (single assistant message, multiple tool calls) to brainstorm distinct sub-problems. Each agent MUST invoke `superpowers:brainstorming` at the top of its prompt and MUST return a design fragment, not just research. **Verification / code-exploration agents are additional and do NOT count toward this quota.**

## Supporting documentation

## When done

- DO NOT use `AskUserQuestion` for "Ready to proceed?" at the end. It's OK before completing the work.
- Once the plan is clear and right before code execution, give a brief T-shirt size estimate of how many tokens implementation could take.
- NEVER call `ExitPlanMode`. The terminal actions are: write `./planning/{branch}/design.md`, then suggest `/clear` + `/sup-plan`.

1. Store the design in `./planning/{branch}/design.md` (same `{branch}` as above)
2. Every `super-design.md` MUST end with a `## Required migrations and API changes` section containing a Markdown table with these columns: `Type`, `Required change`, `Why`. Add one row per migration or API change the feature needs. If none are required, still include the section and add a single row: `None | No migration or API change required | Feature fits the existing schema and interfaces.`
3. Suggest the user `/clear` and `/sup-plan` (branch is implicit from git).
