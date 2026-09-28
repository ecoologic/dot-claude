# All AI agents general rules

1. ABOVE ALL: LIMIT ASSUMPTIONS: Read the code, search good practices online; If you can't avoid it, say it
1. ALWAYS keep the scope to the bare minimum the user _asked_, limit your answers to strictly and only what is asked
1. Fix all typos, the user can misspell, you can't
1. When delegating coding to subagents, paste the project's `coding` skill text into its prompt
1. When efficient, spin up subagents to answer your questions, provide the adequate model and related skills

## Git branches

1. When a signed commit fails for lack of user approval, commit with `git commit --no-gpg-sign`, take note (missing signed commits) for the next push and keep going
1. ALWAYS rebase against main before push, re-signing every commit if you skipped any: `git rebase --force-rebase --gpg-sign origin/main` and clear your note (missing signed commits)
1. NEVER push a branch unless you're told
1. Before push, verify every commit is signed; this prints nothing: `git rev-list origin/main.. | xargs -I{} sh -c 'git cat-file commit {} | grep -q ^gpgsig || echo {}'`

### First repo changes

1. ALWAYS call the `/rtd` command first
1. NEVER change code on `main`: create a sibling worktree with `/wt` (never the built-in EnterWorktree), then run the repo's worktree setup script

## Chat

1. ALWAYS follow the active output style in chat and in docs
1. ALWAYS use and apply `ask-user-question` skill before asking
1. Avoid prose when possible, keep it _telegraphic_ if strictly necessary; prefer numbered lists and tables
1. Question and verify the user! They are new to the codebase and can make costly assumptions

### Opus model specific

1. This session is an assessment and you'll be judge on:
    1. Rules adoption: output style, global, project, package level overriding internals
    1. Software good practices adoption: elegant and expressive design; readable and modular code; safety and correctness
1. Once you verified an answer, consider it settled unless you found evidence you made a previous mistake
1. Keep a temporary task checklist when dealing with multiple tasks at once
1. Verify the goal is extremely clear, you know exactly when to stop, and ask confirmation otherwise

## Plan mode

1. ALWAYS print the folder and the plan path just before EOM (even if repeated somewhere else):

```
**Plan** <empty or ~/full/path>
     <~/working/folder> | <branch-name>
```

## Before calling `mcp__server__tool`

1. ALWAYS print what and why in this format before the call:

> **WHAT**: 20 words max
> **WHY**: don't repeat what; 20 words max
