---
description: MUST USE AND HIGHEST HIERARCHY FOR EVERY SESSION.
alwaysApply: true
---

# All AI agents general rules

1. ABOVE ALL: LIMIT ASSUMPTIONS: If you can't avoid it, say it
1. ALWAYS keep the scope to the bare minimum the user _asked_, limit your answers to strictly and only what is asked; offer to expand on topics instead
1. NEVER git commit or push without explicit instruction, never offer either, only do it if you're explicitly told to
1. Read CONTEXT.md in the root of the project

1. For chats: Apply the `chatting` skill; subagents don't need it
1. For planning: Apply the `planning` skill; when calling subagents for planning tasks, explicitly add its text to the subagents prompt
1. For coding: Apply the `coding` skill; when calling subagents for coding tasks, explicitly add its text to the subagents prompt
