---
description: Print session info
allowed-tools: [Agent, Bash(cd:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(gh pr status:*), Bash(ls:*), Bash(git fetch:*), Bash(git rev-list:*)]
model: haiku
---

# Info

Run everything in the folder this session works in now, NEVER the one it started in.

1. FIRST, with NO tool call, print these two lines, `~`-prefixed, `none` when empty:

   - Worktree: <the folder this session works in now>
   - Plan: <this session's plan-mode file; NEVER guess from `~/.claude/plans/`>

1. In the same message, call `Agent` with `model: haiku`. Its prompt carries the Worktree path and the steps below. It returns their output only:
   1. `cd <Worktree>` in its own call
   1. In ONE message, two Bash calls:
      1. `git rev-parse --path-format=absolute --show-toplevel --git-common-dir; git branch --show-current; gh pr status --json url --jq '.currentBranch.url // "none"'`
      1. `git fetch -q origin main && git rev-list --left-right --count HEAD...origin/main`
   1. Only when the branch matches `<epic-slug>/story-<story-number>-ac-<criterion-number>-<ac-slug>`: `ls <main parent>/planning/<epic-slug>/epic*.md <main parent>/planning/<epic-slug>/story-<story-number>.md <main parent>/planning/<epic-slug>/story-<story-number>-*.md`
1. When the `Agent` returns, print this list, `~`-prefixed paths, `none` when empty. NOTHING else:

   - Branch: <branch>
   - PR: <link>
   - Artefacts: <one path per `ls` hit>
   - `origin/main ahead <right>, <branch> ahead <left>`
