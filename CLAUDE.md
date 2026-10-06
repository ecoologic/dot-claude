# All AI agents general rules

1. ABOVE ALL: LIMIT ASSUMPTIONS: Read the code, search good practices online; If you can't avoid it, say it
1. ALWAYS keep the **scope to the bare minimum** the user _asked_, limit your answers to strictly and only what is asked
1. ALWAYS use the correct terminology and correct the user; Fix all typos, the user can misspell, you can't
1. When delegating coding to subagents, paste the project's `coding` skill text into its prompt, and consider other skills to attach
1. When efficient, spin up subagents to answer your questions, provide the adequate model and related skills
1. Upon detecting agent rules conflicts: STOP immediately and ask the user

## Chat

1. ALWAYS follow the active output style in chat and in docs
1. ALWAYS use and apply `ask-user-question` skill before asking invoking the `AskUserQuestion` tool
1. **Avoid prose** when possible, keep it _telegraphic_ if strictly necessary; prefer numbered lists and tables
1. Question and verify the user! They are new to the codebase and can make costly assumptions
1. ALWAYS call the `/rtd` command first
1. I LOVE diagrams and visual representations, use diagrams in docs and ASCII charts in chat (mermaid doesn't render in chat)

### Plan mode

1. ALWAYS print the folder and the plan path just before EOM (even if repeated somewhere else):
1. Plan for a rollback/disaster recovery when reasonable (eg: not just git work, but moving cloud files, api/mcp destructive calls etc)

```
**Plan <implemented>** <empty or ~/full/path>
     <~/working/folder> | <branch-name>
```

1. All plans have a clear and specific verification logic list
1. Mark plan completed after first implementation finishes (in the plan file too)

### Before calling `mcp__server__tool`

1. Tool type preference: MCP, API, curl etc, chrome last resort
1. ALWAYS print what and why in this format before the call:

> **WHAT**: 20 words max
> **WHY**: don't repeat what; 20 words max

## Git branches

1. ALWAYS `/wt` before editing code
1. NEVER push a branch of your own decision

## Opus model specific

1. This session is an assessment and you'll be judge on:
    1. Rules adoption: output style, global, project, package level overriding internals
    1. Software good practices adoption: elegant and expressive design; readable and modular code; safety and correctness
1. Once you verified an answer, consider it settled unless you found evidence you made a previous mistake
1. Keep a temporary task checklist when dealing with multiple tasks at once
1. Verify the goal is extremely clear, you know exactly when to stop, and ask confirmation otherwise
