---
description: "Template: handoff document produced by /architect-handoff"
disable-model-invocation: true
---

# Handoff document template

The handoff consists of these H2 sections, in order:

1. Source
  - Path of the design document, branch, and base commit
  - One sentence on what the agents build, taken from the design Goal
1. Shared context
  - Everything every subagent needs, they see nothing else
  - Repository root, the exact commands to run tests, lint and build
  - The files every agent must read first
  - The skills every agent must load, with the rule from the **Skills** section of the command
  - Non-negotiables: naming, boundaries, dependency direction, from the design Architecture section
1. Execution waves (table)
  - One row per wave, in order
  - Columns:

    | Column | Content |
    | --- | --- |
    | Wave | Number |
    | Tasks | Task IDs in the wave |
    | Blocked by | Wave numbers, or `-` |
    | Why | One clause on what the wave delivers |
1. File ownership (table)
  - One row per file or glob, one owner only
  - Columns: File, Owner task, Action (`create`, `edit`, `delete`)
  - Confirm in one sentence that no two tasks in one wave share a file
1. Task packets
  - One H3 per task, titled `T{n} — {short title}`
  - The body of each packet is copy-pasteable as the subagent prompt: second person, imperative, self-contained
  - Each packet has:
    - A header table:

      | Model | Effort | Skills | Depends on |
      | --- | --- | --- | --- |

    - Objective: one sentence
    - Files: exact paths, marked create or edit
    - Contracts: the exact signatures, types, names and routes this task must produce, copied from the design
    - Steps: small numbered instructions, in order
    - Tests: the spec-style lines from the design that this task must make pass
    - Acceptance: the exact commands the agent runs to verify, and the expected result
    - Out of scope: explicit NEVERs, including every file the task does not own
1. Integration checks
  - The exact commands to run after each wave, and what a pass looks like
  - Who fixes a failure, and in which wave
1. Final verification
  - The exact commands for the whole feature
  - The manual check, if one is needed
1. Open questions
  - Anything that blocks execution
  - This section MUST be empty before the user launches the agents. Say so if it is not
1. A brief sentence confirming whether the handoff is ready to run
