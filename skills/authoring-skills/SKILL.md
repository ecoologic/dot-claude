---
name: authoring-skills
description: MUST use when creating, editing, splitting or reviewing a Claude Code skill or slash command (SKILL.md, commands/*.md), or when the user says "make a skill", "turn this into a skill" or "improve this skill". Covers frontmatter, body structure, the 100-line rule, skill vs command vs hook choice, eval level choice and description tuning. Replaces the authoring part of skill-creator; hands off to skill-creator only for full evals.
---

# How to author skills and commands

## House rules (apply to every file)

1. ALWAYS keep each `.md` file at max 100 lines. Split into `references/` when longer. Short files load fast and stay readable
1. ALWAYS follow the active output style (ASD-STE100): numbered lists and tables, telegraphic, no prose
1. ALWAYS write directives as ALWAYS/NEVER/MUST plus a short why. The why lets Claude handle edge cases
1. Put the key rules at the top of `SKILL.md`. Compaction keeps only the first 5,000 tokens of an invoked skill
1. NEVER commit in `~/.claude`. The user manages its git

## Workflow

Copy this checklist and tick each step:

```
- [ ] 1. Capture intent
- [ ] 2. Pick the mechanism
- [ ] 3. Draft frontmatter
- [ ] 4. Draft body
- [ ] 5. Pick eval level and run it
- [ ] 6. Iterate
- [ ] 7. Tune description
```

### 1. Capture intent

1. Extract answers from the conversation first: tools used, step order, user corrections, output format
1. Then ask only what is left (use the `ask-user-question` skill):
    1. What does the skill make Claude do?
    1. Which user phrases or contexts trigger it?
    1. What is the expected output?
    1. Which near-miss requests must NOT trigger it?

### 2. Pick the mechanism

| Need | Mechanism |
|---|---|
| Rules Claude applies when the task matches | Skill, model-invocable |
| Procedure only the user starts, with side effects | Skill with `disable-model-invocation: true` (or a legacy command) |
| Background knowledge, hidden from the `/` menu | Skill with `user-invocable: false` |
| Behaviour that MUST happen every time | Hook. Skills are advisory, hooks are deterministic |
| Isolated heavy task, no chat history needed | Skill with `context: fork` |

1. Prefer a skill over a new `commands/*.md`. Same frontmatter; a same-name skill wins
1. Location: personal `~/.claude/skills/<name>/`, repo-only `.claude/skills/<name>/`

### 3. Draft frontmatter

Read `references/frontmatter.md`.

### 4. Draft body

1. Read `references/writing.md` for structure and patterns
1. Read `references/runtime.md` when the skill uses arguments, `` !`cmd` ``, scripts, hooks or `context: fork`
1. Read `references/distribution.md` when the skill is shared, packaged as a plugin, or runs scripts or URLs

### 5. Pick eval level and run it

Read `references/eval-levels.md`. Pick None, Lean or Full. Say which and why.

### 6. Iterate

1. Generalise from feedback. NEVER patch only the failing example; the skill must work for unseen prompts
1. Remove lines that do not change behaviour. Read run transcripts, not only outputs
1. Repeated helper code across runs → bundle it once in `scripts/`
1. Stop when the user is happy, feedback is empty, or progress stalls

### 7. Tune description

1. Test 3–5 should-trigger and 3–5 near-miss prompts in fresh subagents
1. Full eval level → `skill-creator` runs automatic tuning (see `references/eval-levels.md`)

## Done when

1. `wc -l` shows max 100 lines for each `.md`
1. Frontmatter passes every [HARD] check in `references/frontmatter.md`
1. The chosen eval level passed
1. Each reference file is linked from `SKILL.md` with "when to read it"
