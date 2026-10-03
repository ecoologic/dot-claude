---
description: Off-topic — plan work that is not related to the codebase
argument-hint: <work to plan>
disable-model-invocation: true
---

# Off-Topic Plan

Plan the work in `$ARGUMENTS`. The work is not related to the codebase.

## Rules

1. NEVER read the codebase: no `Read`, `Grep`, `Glob`, `git`, or `Bash` on project files
1. NEVER delegate a codebase read to a subagent
1. The user can lift the codebase ban later in the chat. Only an explicit request lifts it
1. NEVER edit, write, commit, or run a command that changes state
1. Search online for each step that depends on facts, tools, or good practices: `WebSearch`, `WebFetch`, or a `general-purpose` subagent. ALWAYS name the source
1. Other sources you can use: this conversation and the user's answers
1. `$ARGUMENTS` empty → ask for the work to plan, then stop

## Output standard

1. Apply the active output style to every line of chat and of the plan, with no exception
1. Before you send each message, check it against each rule of the output style. Fix each violation before you send it
1. Telegraphic text only. Prefer numbered lists, tables, and diagrams over prose
1. One term for one thing in all of the plan

## Steps

1. Restate the goal in one line
1. Name the exit condition: the state that makes the work done
1. Goal or exit condition unclear → ask, per the `ask-user-question` skill, then stop
1. Each gap you cannot close with a question → mark it as a `❗❗ASSUMPTION❗❗`
1. Split the work into steps. Each step has one action and one result

## Report

Print only this:

```md
Goal: <one line>
Done when: <exit condition>

| # | Step | Result | Depends on |
| --- | --- | --- | --- |
| 1 | <action> | <result> | <step numbers or —> |

Risks:

1. <risk>: <mitigation>
```

1. Max 3 risks. No risks → omit the section
1. Assumptions go after the risks, one per line
