---
description: Convert an agreed design into parallel subagent instructions
argument-hint: <path-to-design.md>
disable-model-invocation: true
---

# How to hand off a design

## Input

1. `$ARGUMENTS` is the path to the design document from `/architect`. No argument → stop, ask for the path, never guess
1. Read the whole design document before you write anything
1. Read every file the design touches, the packets must name real paths and real symbols
1. NEVER change the design here. A design gap → stop and ask the user

## Parallel quality assessment 

One subagent with opus xhigh on each:

1. Architecture & boundaries — coupling, dependency direction, ownership, patterns, smells (coding)
2. Contracts & data — endpoints, signatures, types, names, migrations, cross-section agreement (api, coding)
3. Tests & verifiability — do the spec lines cover the outcome and the complex internals (testing)
4. Repo reality & reuse — named paths and symbols exist, conflicts with existing code, code to reuse (coding)

Each returns at most 5 findings, ordered by impact, as rows in the design's Current weaknesses & risks columns (Risk, Details, Impact, Resolution), and edits nothing.

## Scope

1. Convert the agreed design into execution instructions
1. The reader is a smaller model, in a subagent, with no access to this conversation and no access to the design document
1. Every packet is self-contained: no "as discussed", no "see the design", no chat references
1. Copy the exact names, signatures and test lines from the design into the packet that needs them

## Parallelism

1. Group the tasks into waves. Tasks in one wave run at the same time
1. Exactly one task owns each file. Two tasks in one wave NEVER write the same file
1. A shared file (eg: an index, a route table, a migration list) is owned by one task in a later wave
1. Use the smallest number of waves that respects the dependencies
1. Split a task when it is too big for its model, not to create false parallelism

## Model and effort

1. Assign a model and an effort to every task. Justify each choice in one clause
1. Available models: `haiku`, `sonnet`, `opus`, `fable`. Available effort: `low`, `medium`, `high`, `xhigh`, `max`
1. Starting point, override it when the task says otherwise:

    | Task shape | Model | Effort |
    | --- | --- | --- |
    | Mechanical edit, rename, boilerplate, config | haiku | low |
    | Single-file feature or test suite with a clear contract | sonnet | medium |
    | Cross-cutting logic, tricky state, concurrency, security | opus | high |
    | Final integration, wiring, conflict resolution | opus | high |

## Skills

1. List the skills that apply to each task. Check the global skills in `~/.claude/skills/` and the project skills in `./.claude/skills/`
1. Per the global rules, embed the real skill text in the subagent prompt
1. Read the `SKILL.md` and paste its text, or, for a built-in skill with no file, tell the subagent to call `Skill` itself
1. NEVER paraphrase or invent skill content
1. `coding` applies to every task that writes code. `testing` applies to every task that writes tests

## Git

1. The orchestrator owns git. `/continue` runs every `git` command, single-threaded, after a wave joins
1. A task packet NEVER calls `git`. Put `NEVER run any git command` in the **Out of scope** list of EVERY packet
1. A packet writes its owned files, then reports the exact paths it wrote. Nothing else
1. NEVER tell a packet to commit, stage, stash, branch, pull or push
1. Parallel packets share one `.git/index`. Two concurrent `git add` calls give `fatal: Unable to create '.git/index.lock'`, and one packet's `git add -A` stages another's half-written files

## Output document

1. The design lives in a story folder, `~/dev/plans/<epic>/<story-slug>/design.md`. Write into that same folder
1. Write the handoff as `handoff.md`. NEVER name it after the design file
1. Read `~/.claude/commands/architect/handoff.md`, it is the template for the document, follow it exactly
1. The template file has its own frontmatter, it is not part of the document
1. NEVER edit the design document
1. Enforce your output style

## Seed the progress file

1. Write `progress.md` into the same story folder, AFTER the handoff is complete
1. Read `~/.claude/commands/architect/progress.md`, it is the template for that file, follow it exactly
1. `progress.md` already exists → STOP. Report it. Never overwrite a run in progress
1. The **Open questions** section is not empty → do NOT seed `progress.md`. The handoff is not runnable
1. Take `Verify` from the handoff **Final verification** VERBATIM. NEVER detect a test or lint command
1. Ask the user ONCE whether `/recommit` runs, then record `yes` or `no`
1. One unticked row per task, in wave order, then one unticked row each for `verify`, `simplify`, `code-review`, `recommit` (when `yes`) and `pr-draft`
1. Row 1 is `handoff`, ticked. Its evidence is the design content hash, the wave count and the packet count
1. `~/dev/plans` is NOT a git repository, so the design has no commit. Hash its content with `shasum -a 1 design.md`, and record the first 7 characters

## Exit gate

1. NEVER start the implementation. The user launches the agents
1. NEVER offer to launch them
