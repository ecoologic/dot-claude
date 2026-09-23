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
| Implement | `/a-implement` | Does not exist yet |
| Finish | `/a-finish` | Does not exist yet |

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
/a-plan                 # one criterion at a time
```

`/a-cont <slug>` runs the next unticked stage of this instead, one at a time, and prints the exact next command to type.

## The three loops

The full pipeline has three loops. The first is complete; the per-story loop stops after `a-design`, and the per-criterion loop stops after `a-plan`.

| Loop | Commands | Artefacts |
| --- | --- | --- |
| Epic, once | `a-epic`, `a-architecture` | `epic.md`, `personas.md`, `stretch-goals.md`, `architecture.md` |
| Per story | `a-story`, `a-design`, `a-finish` | `story-N.md`, `design-N.md` |
| Per criterion | `a-plan`, `a-implement` | `plan-N-M.md`, code, commits |

## Folder layout

```text
<dev-root>/
├── foo-bar/                          # a repo the epic touches, tracks ./CONTEXT.md
└── planning/
    └── checkout-flow/                # epic slug
        ├── idea.md
        ├── epic.md
        ├── personas.md
        ├── stretch-goals.md
        ├── architecture.md
        ├── progress.md                # the whole epic's state
        ├── story-1.md                 # /a-story, one file per story
        ├── design-1.md                # /a-design, one file per story
        ├── plan-1-1.md                # /a-plan, one file per acceptance criterion
        └── plan-1-2.md
```

Planning is a git repository that the user commits by hand; no command ever commits in it. `CONTEXT.md` in each repo is the only tracked artefact this flow writes to outside `planning/`.

Every doc's shape lives in its own template, `~/.claude/commands/a-templates/<doc>.md`.

## Where commands run

`a-epic`, `a-architecture`, `a-story` and `a-design` run from the main repo root, and stop if started inside a worktree. `/wt` makes the story worktree for `a-implement` onwards, from `story-N.md`'s `branch` header.

## Document header

Every planning doc starts with a YAML header: `updated` on every doc, `status` on the stage's primary doc (`epic.md`, `architecture.md`, `story-N.md`, `design-N.md`, `plan-N-M.md`), `branch` on `story-N.md` only.

```yaml
---
updated: 2026-09-23T14:05+1000
status: draft
branch: checkout-flow/1-guest-email
---
```

## Starting an epic

1. `/a-epic <slug>` — creates `planning/<slug>/`. With no `idea.md` yet, pass the idea as trailing text: `/a-epic <slug> <the idea>`
1. Answer the questions it asks: story boundaries, then which sibling repos the epic touches
1. `/a-architecture` — no argument needed; it defaults to the epic you just created
1. `/a-story` — no argument needed; it picks the first `## Story Order` story whose `story-N.md` is missing or not `done`, and a `draft` one resumes at its first unfinished section. Name a number to pick another: `/a-story <n>`
1. `/a-design` — no argument needed; it defaults to the story you just broke down. It ends when you say the design is ready, not before
1. `/a-plan` — no argument needed; it defaults to the story in memory and the first criterion with no plan file yet. One criterion per run: `/a-plan <n> <m>` picks another

## Resuming after `/clear`

Every `a-*` command defaults its selector from memory, so a bare `/a-architecture` or `/a-story` after a clear picks up the last epic or story you worked on. Name the selector explicitly to switch: `/a-architecture <other-slug>`, `/a-story <n>`.

Planning stages (`a-epic`, `a-architecture`, `a-story`, `a-design`) resolve the selector as: their own argument, then memory, then ask — never from the current branch.

`/a-cont <slug>` does the same, plus advances the pipeline itself, and prints the exact numbered command to run next (eg `/a-story 1`).

## Re-running a stage with extra guidance

Trailing text after the selector passes straight through to the command as high-priority guidance for that run: `/a-architecture <slug> focus on the billing service`, `/a-story <n> tighten the validation criteria`. Through `/a-cont`, trailing text after its own slug argument passes through the same way: `/a-cont <slug> focus on the billing service`.

## What each document holds

| File | Owner | Holds |
| --- | --- | --- |
| `idea.md` | `a-epic` | The raw idea and links to supporting material |
| `epic.md` | `a-epic` | The story list, touched repos, UI references, domain concepts, candidate terms. `a-architecture` may revise the story order when implementation reality forces it; `a-finish` applies any other confirmed finding |
| `personas.md` | `a-epic` | Actors and usage context |
| `stretch-goals.md` | `a-epic` | Later-scope stories, not required reading |
| `architecture.md` | `a-architecture` | The epic's architecture: critique, decisions, diagrams, terminology, change inventory. There is no other architecture document — repo-level context comes from each repo's README, `CLAUDE.md`, `CONTRIBUTING.md`, and `CONTEXT.md`. `a-finish` is the only later command that writes it |
| `story-N.md` | `a-story` | WHAT the story delivers: its slug, user context, Given/When/Then acceptance criteria, UI references, a settled assumption ledger, and a `## Findings` log that every later stage appends to and only `a-finish` applies. It carries no technical design |
| `design-N.md` | `a-design` | HOW the story is built: goal, UX, UI sketch, components, file structure, reuse and extractions, contracts, migrations, the two story-level diagrams, happy-path test lines, risks, and the decision registry |
| `plan-N-M.md` | `a-plan` | HOW one acceptance criterion gets built: the criterion verbatim, its outcome and dependencies, the exact files, the numbered steps, the contracts copied from the design, the test lines, the verification commands, and what is out of scope |
| `progress.md` | `a-cont` | The completion matrix: Done, Stage, Artefact, Status, Updated, Branch columns. `a-cont` ticks a row only on `status: done`, read from the artefact's own header |
| `CONTEXT.md` (in each repo) | `a-architecture` | That repo's naming baseline. `a-epic` puts candidate terms in `epic.md`'s `## Candidate Terms` instead of writing here; `a-architecture` confirms them. Later stages record term findings in `story-N.md`; `a-finish` applies them |

## Where the ordinary commands fit

These key on the current git branch, not on a slug, and this flow does not change them:

| Command | Fits in |
| --- | --- |
| `/rtd` | Run at the start of a session, before `/a-epic` and again before `/a-story` |
| `/wt` | Creates the worktree `/a-implement` will use, once that stage exists |
| `/simplify`, `/code-review`, `/security-review`, `/pr-draft`, `/recommit` | Run after `/a-implement`, once that stage exists |

`/clear` and `/compact` are the user's own calls between stages; no `a-*` command runs them.

## Skills

Which skill each stage uses is listed in `~/.claude/commands/a-templates/conventions.md`'s `## Skills`.
