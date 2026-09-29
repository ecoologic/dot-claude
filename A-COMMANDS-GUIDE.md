# The `a-*` workflow

A pipeline for taking an idea from a rough note through to a shipped story using the agile process. Planning artifacts live outside every repo, in a sibling folder shared by the repos.

## Status

| Stage | Command | State |
| --- | --- | --- |
| Epic | `/a-epic` | Working |
| Architecture | `/a-architecture` | Working |
| Story | `/a-story` | Working |
| Design | `/a-design` | Working |
| Plan | `/a-plan` | Working |
| Implement | `/a-implement` | Working |
| Check | `/a-check` | Working |
| Finish | `/a-finish` | Working |

`/a-cont` drives any row above marked Working. It stops the moment it reaches a row that is not.

## The flow, as far as it goes today

```sh
/rtd
/a-epic <slug>
/a-architecture

/clear
/rtd
/a-story
/a-design
/a-plan                 # every criterion of the story, then a critic pass over the set

/a-implement            # one session per ready criterion, in parallel; ends by printing the /compact instructions
/compact                # paste what a-implement printed
                        # review the browser result, then verify what it did not cover
/a-check                # simplify, then code-review high --fix, then rebase onto main once the parent PR merged
/draft-pr               # one PR per criterion; --base <parent-branch> when stacked
/security-review        # optional
/clear

/a-finish               # after the story's last /draft-pr, from the main repo: applies findings, records drift, removes the worktrees
```

`/a-cont <slug>` runs the next unticked stage of this instead, and prints the exact next command to type. At the implement stage it prints every ready `/a-implement`, one session each.

## The three loops

The full pipeline has three loops. All three loops are complete.

| Loop | Commands | Artefacts |
| --- | --- | --- |
| Epic, once | `a-epic`, `a-architecture` | `epic-requirements.md`, `epic.md`, `epic-personas.md`, `epic-stretch-goals.md`, `epic-architecture.md` |
| Per story | `a-story`, `a-design`, `a-plan`, `a-finish` | `story-N.md`, `story-N-design.md`, `story-N-ac-M.md` |
| Per criterion | `a-implement`, `a-check` | code, commits, the plan's `## Findings` |

## Folder layout

```text
<dev-root>/
├── foo-bar/                                  # main repo, tracks ./CONTEXT.md
├── fb-checkout-flow-story-1-ac-1-guest-email/ # /wt worktree, sibling, per criterion
└── planning/                                 # git repo, the user commits it by hand
    └── checkout-flow/                        # epic slug
        ├── epic-architecture.md              # /a-architecture
        ├── epic-personas.md                  # /a-epic
        ├── epic-progress.md                  # the whole epic's state, /a-cont
        ├── epic-requirements.md              # /a-epic Step 0, from the raw idea
        ├── epic-stretch-goals.md             # /a-epic
        ├── epic.md                           # /a-epic
        ├── story-1-ac-1.md                   # /a-plan, story 1 criterion 1
        ├── story-1-ac-2.md
        ├── story-1-design.md                 # /a-design
        ├── story-1.md                        # /a-story
        └── story-2.md                        # ... one set per story
```

Planning is a git repository that the user commits by hand; no command ever commits in it. `CONTEXT.md` in each repo is the only tracked artefact this flow writes to outside `planning/`.

Every doc's shape lives in its own template, `~/.claude/commands/a-templates/<doc>.md`.

## Where commands run

`a-epic`, `a-architecture`, `a-story` and `a-design` run from the main repo root, and stop if started inside a worktree. `/wt` makes each criterion worktree for `a-implement` onwards, from `story-N-ac-M.md`'s `branch` header.

## Document header

Every planning doc starts with a YAML header: `updated` on every doc, `status` on the stage's primary doc (`epic.md`, `epic-architecture.md`, `story-N.md`, `story-N-design.md`, `story-N-ac-M.md`), `branch` and `pr` on `story-N-ac-M.md` only.

```yaml
---
updated: 2026-09-23T14:05+1000
status: draft
---
```

## Starting an epic

1. `/a-epic <slug>` — creates `planning/<slug>/`. With no `epic-requirements.md` yet, pass the idea as trailing text: `/a-epic <slug> <the idea>`
1. Answer the questions it asks: story boundaries, then which sibling repos the epic touches
1. `/a-architecture` — no argument needed; it defaults to the epic you just created
1. `/a-story` — no argument needed; it picks the first `## Story Order` story whose `story-N.md` is missing or neither `done` nor `finished`, and a `draft` one resumes at its first unfinished section. Name a number to pick another: `/a-story <n>`
1. `/a-design` — no argument needed; it defaults to the story you just broke down. It ends when you say the design is ready, not before
1. `/a-plan` — no argument needed; it defaults to the story in memory and plans every criterion with no plan file yet, one subagent each. A critic subagent then checks the set for overlaps, dependencies and a better design. `/a-edit plan <n> <m>` revises one plan
1. `/a-implement` — once per ready criterion, each in its own session. `/a-cont` prints every ready one

## Resuming after `/clear`

Every `a-*` command defaults its selector from memory, so a bare `/a-architecture` or `/a-story` after a clear picks up the last epic or story you worked on. Name the selector explicitly to switch: `/a-architecture <other-slug>`, `/a-story <n>`.

Planning stages (`a-epic`, `a-architecture`, `a-story`, `a-design`) resolve the selector as: their own argument, then memory, then ask — never from the current branch.

`/a-cont <slug>` does the same, plus advances the pipeline itself, and prints the exact numbered command to run next (eg `/a-story 1`).

## Re-running a stage with extra guidance

Trailing text after the selector passes straight through to the command as high-priority guidance for that run: `/a-architecture <slug> focus on the billing service`, `/a-story <n> tighten the validation criteria`. Through `/a-cont`, trailing text after its own slug argument passes through the same way: `/a-cont <slug> focus on the billing service`.

## What each document holds

| File | Owner | Holds |
| --- | --- | --- |
| `epic-requirements.md` | `a-epic` | The raw idea and links to supporting material |
| `epic.md` | `a-epic` | The story list, touched repos, UI references, domain concepts, candidate terms. `a-architecture` may revise the story order when implementation reality forces it; `a-finish` applies any other confirmed finding |
| `epic-personas.md` | `a-epic` | Actors and usage context |
| `epic-stretch-goals.md` | `a-epic` | Later-scope stories, not required reading |
| `epic-architecture.md` | `a-architecture` | The epic's architecture: critique, decisions, diagrams, terminology, change inventory. There is no other architecture document — repo-level context comes from each repo's README, `CLAUDE.md`, `CONTRIBUTING.md`, and `CONTEXT.md`. `a-finish` is the only later command that writes it |
| `story-N.md` | `a-story` | WHAT the story delivers: user context, Given/When/Then acceptance criteria, UI references, a settled assumption ledger, and a `## Findings` log that `a-story`, `a-design` and `a-plan` append to and only `a-finish` applies, marking each row `Applied to <doc> on <date>` or `Rejected on <date>: <reason>`. `a-finish` sets `status: finished`. It carries no technical design |
| `story-N-design.md` | `a-design` | HOW the story is built: goal, UX, UI sketch, components, file structure, reuse and extractions, contracts, migrations, the two story-level diagrams, happy-path test lines, risks, and the decision registry |
| `story-N-ac-M.md` | `a-plan` | HOW one acceptance criterion gets built: the criterion verbatim, its outcome and parent criteria, the exact files, the numbered steps, the contracts copied from the design, the test lines, the verification commands with their source, the browser check, what is out of scope, and a `## Findings` log that `a-implement` and `a-check` append to. `a-plan` sets `branch` in its header. `a-implement` ticks its steps and sets `status: implemented` and `pr`; `a-check` appends `, simplified` and `, reviewed` to that status; `a-cont` ticks the `a-implement` and `a-check` rows from there |
| `epic-progress.md` | `a-cont` | The completion matrix: Done, Stage, Artefact, Status, Updated, Branch columns. `a-cont` ticks a row only on `status: done`, read from the artefact's own header |
| `CONTEXT.md` (in each repo) | `a-architecture` | That repo's naming baseline. `a-epic` puts candidate terms in `epic.md`'s `## Candidate Terms` instead of writing here; `a-architecture` confirms them. Later stages record term findings in `story-N.md` or in the plan's `## Findings`; `a-finish` applies them |

## Where the ordinary commands fit

These key on the current git branch, not on a slug, and this flow does not change them:

| Command | Fits in |
| --- | --- |
| `/rtd` | Run at the start of a session, before `/a-epic` and again before `/a-story` |
| `/wt` | Creates each criterion worktree. `/a-implement` follows it once per criterion, on the base conventions `## Criterion branches` picks |
| `/simplify`, `/code-review` | Run by `/a-check`, once per criterion, as skills |
| `/draft-pr`, `/security-review`, `/recommit` | Run in each criterion worktree after its `/a-check`. `/a-finish` then reads each PR number |

`/clear` and `/compact` are the user's own calls between stages; no `a-*` command runs them.

## Skills

Which skill each stage uses is listed in `~/.claude/commands/a-templates/conventions.md`'s `## Skills`.
