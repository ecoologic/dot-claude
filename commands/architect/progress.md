---
description: "Template: progress.md, the pipeline state file seeded by /architect-handoff and driven by /continue"
disable-model-invocation: true
---

# Progress file template

`progress.md` lives in the story folder, beside `design.md` and `handoff.md`. `/architect-handoff` seeds it. `/continue` is the only writer after that.

## Shape

````md
# <story-slug>

Epic: <epic>
Repo: <git toplevel>
Branch: <story-slug>
Verify: <the exact commands from the handoff Final verification, one per line>
Review gate: high
Recommit: yes | no

## Completion matrix

| # | Stage | Model | Evidence | Status |
| --- | --- | --- | --- | --- |
| 1 | handoff | fable | handoff.md, design hash 4f2a1c9, 3 waves, 7 packets | [x] |
| 2 | T1 session store | sonnet | 2 files, wave commit a1b2c3d | [x] |
| 3 | T2 login route | sonnet | 1 file, wave commit a1b2c3d | [x] |
| 4 | verify | haiku | `pnpm test` exit 0, 41 passed | [ ] |

## Blocked

<empty, or the gate that stopped the run and what the user must decide>
````

## Header fields

| Field | Content |
| --- | --- |
| Epic | The parent folder name under `~/dev/plans/` |
| Repo | The output of `git rev-parse --show-toplevel` |
| Branch | The story slug. The folder name, the branch and the `/continue` argument are the same string |
| Verify | The exact commands from the handoff **Final verification**. NEVER detect them |
| Review gate | The lowest code-review severity that stops the run. Default `high` |
| Recommit | `yes` runs `/recommit` before the PR (Pull Request). `no` skips it |

## Rules

1. NEVER tick a box without citable evidence: a commit SHA, a test name, or an exit code.
2. Tick per TASK, never per wave. A wave ticked as one unit re-runs its finished tasks on resume, and `Action: create` rows then fail or double-apply.
3. Every stage records the command string and its EXIT CODE, never the agent's prose.
4. One row per task and one row per stage, in execution order.
5. `## Blocked` is empty while the run is healthy. A gate writes the stage, the exact failure, and the decision the user must make.
