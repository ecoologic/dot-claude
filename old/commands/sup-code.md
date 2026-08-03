---
description: Execute a written implementation plan
argument-hint: [Priority instructions or file to consider prompt]
---

## Precedence (high to low)

1. `<priority instructions>`
2. This file
3. Project rules and `CLAUDE.md`
4. Global skills and commands like `ecoologic-*`
4. `ecoologic-*` skills and commands
5. Superpowers (eg: `brainstorming` or `writing-plans`)

## Output hygiene

Invoke skills (`superpowers:*`, `ecoologic-*`) freely as part of your workflow — that's how the work gets done. But **never mention** development tools, design/plan documents, or Superpowers materials in **artifacts the user ships**: produced code, comments, commit messages, or PR descriptions. Internal invocation = yes; visible attribution in shipped output = no.

## Parallelisation

Invoke `superpowers:dispatching-parallel-agents`. Group plan tasks into non-conflicting areas (different files, different subsystems, no shared state) and dispatch one agent per area in a single assistant message. Tasks that touch the same files or depend on each other run sequentially.

Invoke `superpowers:executing-plans`, `ecoologic-architecture` and `ecoologic-code` in every agent.

If, at any point, you find bugs, invoke `ecoologic-debug` and `superpowers:systematic-debugging`.

## When done

1. DO NOT use `AskUserQuestion` for "Ready to proceed?" at the end. It's OK before completing the work
2. Suggest the user run `/clear` and `/sup-finish` to verify the work
