---
description: Print session info
allowed-tools: [Bash(cd:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(gh pr status:*), Bash(ls:*), Bash(git fetch:*), Bash(git rev-list:*)]
model: haiku
---

# Info

Run everything in the folder this session works in now, NEVER the one it started in. When the shell is not there yet, `cd` there first in its own call.

1. In ONE message, two Bash calls:
   1. `git rev-parse --path-format=absolute --show-toplevel --git-common-dir; git branch --show-current; gh pr status --json url --jq '.currentBranch.url // "none"'`
   1. With `run_in_background: true`: `git fetch -q origin main && git rev-list --left-right --count HEAD...origin/main`
1. Only when the branch matches `<epic-slug>/<n>-<story-slug>`: `ls <main parent>/planning/<epic-slug>/epic*.md <main parent>/planning/<epic-slug>/story-<n>*.md`
1. Print this list, `~`-prefixed paths, `none` when empty. NOTHING else:

   - Worktree: <path>
   - Branch: <branch>
   - PR: <link>
   - Plan: <this session's plan-mode file; NEVER guess from `~/.claude/plans/`>
   - Artefacts: <one path per `ls` hit>

1. When the fetch finishes, print ONE line: `origin/main ahead <right>, <branch> ahead <left>`
