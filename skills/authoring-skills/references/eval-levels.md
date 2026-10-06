# Eval levels

An eval runs Claude on realistic prompts with the skill and without it (baseline). Equal outputs mean the skill adds nothing.

## Pick a level

Pick the lowest level that can show the skill works. Tell the user the level and the why. The user can override.

| Level | Pick when | Cost |
|---|---|---|
| None | Short rule list or style skill, subjective output, one user, cheap to revert | Minutes |
| Lean | Checkable output (files, commands, fixed steps), personal or repo use | 2–5 subagent pairs |
| Full | Shared or plugin skill, many competing skills, trigger accuracy matters, output must be stable across runs | Long; viewer, benchmark, auto description tuning |

Raise the level when:

1. A Lean run shows flaky results across repeats
1. The skill triggers wrongly or not at all in real use
1. Other people install the skill

## None

1. Run 1–2 realistic prompts in a fresh subagent with the skill
1. Read the transcript. Check that Claude read the right reference files in the right order
1. Fix and stop

## Lean

1. Write 2–5 realistic prompts: concrete paths, names, casual wording. Show them to the user before the runs
1. Add 2–3 trigger prompts: should-trigger and near-miss should-not-trigger
1. In ONE message, spawn per prompt:
    1. With-skill subagent: "Read `<skill-path>/SKILL.md`, then do: `<prompt>`"
    1. Baseline subagent: same prompt, no skill. Improving an existing skill → the old version as baseline
1. Meanwhile, draft objective assertions per prompt. Skip assertions for subjective output
1. Grade with one subagent, or a script when checks are mechanical
1. Print one table:

| Prompt | Assertion | With skill | Baseline | Evidence |
|---|---|---|---|---|

1. Ask the user for feedback per prompt
1. Iterate (see `SKILL.md` step 6). Re-run into a new round, same baseline

Extra checks:

1. Multi-model: run the with-skill side on Haiku, Sonnet and Opus. Haiku may need more detail; Opus may overdo it
1. Claude A/B: you (A) wrote the skill, a fresh subagent (B) uses it. Watch B for missed references, odd read order, ignored files
1. Drift: re-run the prompts after model or skill changes

## Full

Delegate to the official `skill-creator`. It owns the scripts, the viewer and the description optimiser.

1. Invoke the `skill-creator` skill with this brief:
    1. "The skill at `<skill-path>` is drafted. Skip Creating a skill. Start at Running and evaluating test cases"
    1. "After the loop, run Description Optimization with the current model id"
    1. "Skip Package and Present: its validator rejects Claude Code-only frontmatter"
1. Its workspace goes to `<skill-name>-workspace/` next to the skill. NEVER put it inside `~/.claude/skills/`; the folder would load as content
1. Apply its `best_description` only after the 1,024-char and house-style checks in `frontmatter.md`
1. Keep the house rules: any skill edit during the loop stays within 100 lines per `.md`
