---
description: Explain the options of the last AskUserQuestion in chat (pros and cons), then re-ask on `ask`
argument-hint: "[ask | <channel or focus>]"
disable-model-invocation: true
---

# Pros and cons

The `AskUserQuestion` preview pane truncates with `N lines hidden`, with no scroll. Chat has no such limit. The user presses Esc on the dialog, then types this command.

## Modes

| Command argument, or next user message | Mode |
|---|---|
| empty, or a focus (eg `web`, `git`) | Explain |
| `ask` (also as a plain next message, after Explain) | Ask |

1. The options come from the most recent `AskUserQuestion` call in this conversation, rejected or not. Keep its labels and its order
1. No such call exists → say so in one line, then stop. NEVER invent options

## Explain

1. Gate. The answer turns on taste, priority, budget, risk appetite, or anything only the user knows → NEVER research, NEVER pick a winner. Skip to Print, no `✅`
1. Where to look. FIRST drop each channel whose `Skip it when` fires. THEN work DOWN what is left. STOP at the first channel that settles it. A focus given as the command argument goes first

| Channel | How | Open it when | Skip it when |
|---|---|---|---|
| Memory | `~/.claude/projects/*/memory/` | the choice is a standing preference | the subject is new |
| Codebase | `Grep`, `Glob`, `Explore` | the repo already solves something comparable | nothing comparable exists |
| Git history | `git log -S`, `git log --grep`, `git blame` | the thing is in the tree, or once was | it was never in the tree |
| Web | `WebSearch`, `WebFetch` | the answer is public and versioned. ALWAYS name the version checked | the answer is repo-internal |

1. Research what is left. Call `Agent` with `model: sonnet`. The prompt MUST carry the exact option list, the channels to search, and what the channels you ran returned. NEVER send it over a channel you dropped or exhausted
1. Name the skills that fit the domain. Paste their real `SKILL.md` text into the prompt, per the global rules
1. Demand this return shape:
    1. Per option: pros and cons, 15 words max each
    1. Per option: ONE concrete example of it working, chosen to separate it from the other options
    1. Per con: how hard it bites: `always`, `edge case` or `theoretical`
1. Judge the findings YOURSELF. Settled = every option but one is `impossible` or `dominated`, or the survivor's only cons are `theoretical`. Settled → mark the winner and name the source. Not settled → no winner

## Print

Print in chat, never in `preview`. ALWAYS end with the line `Say "ask" to put the question again.` and END the turn. Why: the user reads first, then decides.

```md
---
# Issue

50 words max describing the issue

15 words max on WHY it is a problem

## Option N <✅ if winner>

Example: <ELI5, 20 words max: the option working>

Pros
1. <15 words max>

Cons
1. <15 words max> (always | edge case | theoretical)
```

1. One `## Option N` section per option, same order as the tool call
1. `✅` marks the winner in its heading. No winner, no mark anywhere
1. The example shows the option working. It does not describe it
1. Word caps are hard limits

## Ask

1. Call `AskUserQuestion` ONE time, with the SAME question, header, labels, order and `multiSelect` as the rejected call
1. NEVER pass `preview`. Why: the pane truncates and hides lines
1. Each `description`: 15 words max. Put `(Recommended)` at the end of the winner's label. No winner → no mark
1. Print nothing else in chat. The dialog covers it
