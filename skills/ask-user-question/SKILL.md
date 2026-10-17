---
name: ask-user-question
description: MUST use before every `AskUserQuestion` call, when choosing between options, offering the user a choice, or asking which approach to take. Shapes the call only: one question, options without `preview`. Pros and cons are NOT written here; the user types `/pros-cons` for them.
---

# How to ask the user a question

1. ONE question per call. NEVER pass more than one, even though the tool accepts four. Why: one decision at a time stays reviewable
1. NEVER pass `preview`. Why: the pane truncates with `N lines hidden` and has no scroll. Pros and cons live in `/pros-cons`
1. NEVER research the options before the call. Why: `/pros-cons` does it on demand, so no tokens go to answers the user never reads

## Gate

1. The answer is discoverable in code, docs, memory or a tool schema → look it up and NEVER ask. State the source in one line
1. The answer turns on taste, priority, budget or risk appetite → ask. NEVER mark a winner

## Shape the call

1. Put the issue in the `question` field: 50 words max. Why: the dialog covers chat text above it, so the user cannot read a chat Print while it is open
1. Each option `description`: 15 words max, what the option does. No pros, no cons
1. Winner known from the Gate → put `(Recommended)` at the end of its label, and list it first. No winner, no mark
1. The user wants the options explained → they press Esc and type `/pros-cons`. NEVER write pros and cons yourself in this skill's flow
