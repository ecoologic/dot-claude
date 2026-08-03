---
description: MUST USE AND HIGHEST HIERARCHY FOR EVERY SESSION.
alwaysApply: true
---

# All AI agents general rules

1. ABOVE ALL: LIMIT ASSUMPTIONS: If you can't avoid it, say it
1. ALWAYS keep the scope to the bare minimum the user _asked_, limit your answers to strictly and only what is asked; offer to expand on topics instead
1. If any rule conflicts, tell the user and apply all global rules over project ones

1. For chats: Apply the `chatting` skill; subagents don't need it
1. For planning: Apply the `planning` skill; when calling subagents for planning tasks, explicitely add its text to the subagents prompt
1. For coding: Apply the `coding` skill; when calling subagents for coding tasks, explicitely add its text to the subagents prompt
