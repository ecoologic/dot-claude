---
description: Print session info
allowed-tools: [Bash(cd:*), Bash(git rev-parse:*), Bash(git branch:*), Bash(gh pr status:*), Bash(ls:*), Bash(git fetch:*), Bash(git rev-list:*)]
model: haiku
---

# Info

Run everything in the folder this session works in now, NEVER the one it started in. That folder is the latest `Primary working directory` the harness reported: an `Environment update`, or an `EnterWorktree` result. Only with neither, the one in the startup `Environment` block. NEVER derive it from `pwd`: the shell can reset between calls

1. FIRST, with NO tool call, print the bare path of the folder this session works in now, `~`-prefixed. NOTHING else: no label, no bullet, no formatting

1. In the same message, right after that line, make two Bash calls in parallel. NEVER use a subagent:
   1. `cd <path> && git rev-parse --path-format=absolute --show-toplevel --git-common-dir && git branch --show-current && gh pr status --json url --jq '.currentBranch.url // "none"'`
   1. `cd <path> && git fetch -q origin main && git rev-list --left-right --count HEAD...origin/main`
1. Only when the branch matches `<epic-slug>/story-<story-number>-ac-<criterion-number>-<ac-slug>`: `ls <main parent>/planning/<epic-slug>/epic*.md <main parent>/planning/<epic-slug>/story-<story-number>.md <main parent>/planning/<epic-slug>/story-<story-number>-*.md`
1. When the calls return, print this list, `~`-prefixed paths, `none` when empty. NOTHING else:

   - Plan: <this session's plan-mode file; NEVER guess from `~/.claude/plans/`>
   - Branch: <branch>
   - PR: <link>
   - Artefacts: <one path per `ls` hit>
   - `origin/main ahead <right>, <branch> ahead <left>`
