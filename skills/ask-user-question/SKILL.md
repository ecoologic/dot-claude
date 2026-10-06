---
name: ask-user-question
description: MUST use when choosing between options, offering the user a choice, or asking which approach to take, and before every `AskUserQuestion` call; ALWAYS research the options first
---

# How to ask the user a question

1. ONE question per call. NEVER pass more than one, even though the tool accepts four


## Gate

1. The answer turns on taste, priority, budget, risk appetite, or anything only the user knows → NEVER research, NEVER pick a winner. `Print` with no `✅`, then ask
1. The trade-off is discoverable in code, docs, benchmarks or a tool schema → carry on

## Where to look

1. FIRST drop every channel whose `Skip it when` fires. A channel that cannot hold the answer is NEVER opened
1. THEN work DOWN what survives, in the order below. STOP at the first channel that settles it, NEVER walk the rest

| Channel | How | Open it when | Skip it when |
|---|---|---|---|
| Memory | `~/.claude/projects/*/memory/` | the choice is a standing preference the user could have ruled on before | the subject did not exist in earlier sessions |
| Codebase | `Grep`, `Glob`, `Explore` | the repo already solves something comparable | nothing comparable exists yet |
| Git history | `git log -S`, `git log --grep`, `git blame` | the thing is in the tree now, or once was | it was never in the tree, eg a lib you are adding |
| Web | `WebSearch`, `WebFetch` | the answer is public and versioned: libs, APIs, standards. ALWAYS name the version you checked | the answer is repo-internal |

## Research what is left

1. Call `Agent` and `model: sonnet`. The prompt MUST carry the exact option list you will put in the tool call, which channels the subagent is to search, and what the ones you already ran returned. NEVER send it back over a channel you have exhausted, or one you dropped at `Where to look`
1. Name the skills that fit the question's domain and embed their real text in the prompt, per the global rules. Read the `SKILL.md` and paste it.
1. Demand this return shape:
    - Per option: pros and cons, 15 words max each
    - Per option: ONE concrete example of it working, chosen to separate it from the options beside it
    - Per con: how hard it bites, `always`, `edge case` or `theoretical`
1. While it runs, carry on with the work that does not depend on the answer; NEVER idle
1. Judge the findings YOURSELF. Settled means you can rule every option but one `impossible` or `dominated`, or the survivor's only cons are `theoretical`. Settled and cheap to reverse, do not ask. Nothing settled it, ask. A question settled by the channels is NEVER asked, `Print` it with the winner marked and the source named, then move on

## Print (always)

```md
---
# Issue

50 words max describing the issue

15 words max on WHY is this a problem

## Option 1 <✅ if winner>

> ELI5 20 words max example

### Pros/cons

Pros|cons| table 15 words max each example
```

1. One `## Option N` section per option, in the order they appear in the tool call
1. `✅` marks the winner in both its heading and its table row. No winner, no `✅` anywhere
1. The blockquoted example shows the option working, it does not describe it
1. Word caps are hard limits
