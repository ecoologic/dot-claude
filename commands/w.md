---
description: Force-invoke a skill for the rest of the session, optionally propagating it to subagents
argument-hint: <skill> [<skill>...] [sa]
disable-model-invocation: true
---

1. Parse `$ARGUMENTS`: skill name(s) + optional trailing `sa` token (sets sa mode; persists rest of session, unions across `/w` calls, never auto-deactivates). No args → stop, ask which skill(s), don't guess.
2. Validate each skill name by EXACT match only against the session's available-skills list (not a directory listing). Never fuzzy/prefix-match. Any failure → stop, name the bad token + list valid names, invoke nothing.
3. Call `Skill` once per valid name, in order, before anything else in the message; report in one line what activated; continue into any accompanying task, else stop.
4. If sa mode: before every subagent call this session, default to including each sa skill unless clearly irrelevant. Embed its real text in the prompt — Read its SKILL.md if one exists, else (built-in/plugin skill) tell the subagent to call `Skill` itself. Never fabricate its contents.
