---
description: "Template: story-N-ac-M.md, the one-criterion implementation plan produced by /a-plan"
disable-model-invocation: true
---

# Plan document template

`story-<story-number>-ac-<criterion-number>.md` lives at `$EPIC_DIR/story-<story-number>-ac-<criterion-number>.md`, beside `story-<story-number>-design.md`. `/a-plan` writes it; `/a-edit plan <story-number> <criterion-number>` revises it.

One file per acceptance criterion, shipped on its own branch and PR, per conventions `## Criterion branches`. `/a-plan` writes every plan of a story in one run, and sets `branch` on each plan's first write. `/a-implement` executes it with no access to the story, the design, or the conversation that produced them. `/a-implement` ticks each step, then sets `status: implemented` and `pr` in the header. `/a-check` appends `, simplified` and `, reviewed` to `status`. Both append their findings to this file's `## Findings`.

## Shape

The document is these H2 sections, in this order.

`````md
---
updated: 2026-09-23T14:05+1000
status: draft
branch: PROP-123/story-1-ac-1-guest-email
pr: -
---

# Plan <story-number>-<criterion-number>: <criterion title>

> Epic: <epic name>
> Source Story: `$EPIC_DIR/story-<story-number>.md`
> Source Design: `$EPIC_DIR/story-<story-number>-design.md`
> Repos: <repo>, <repo>
> Skills: <repo>/<path>/SKILL.md, <repo>/<path>/SKILL.md, or none

## Criterion

> _Given_ [precondition] \
> _When_ [action] \
> _Then_ [expected result]

### Outcome
- What must be true when this criterion is complete

### Dependencies
- `none`, or one line per prerequisite:
- `AC <criterion-number>`: <the contract or file this plan consumes from that parent criterion>
- `Story <other-story-number>`: <the file, symbol or test that verifies it, or the user's decision>

## Files
| Path | Create or Edit | What Changes |
| ---- | -------------- | ------------ |
| `src/checkout/guest-email.ts` | create | Holds the guest email validator |
| `src/checkout/index.ts` | edit | Exports the validator |

## Steps
- [ ] Step <criterion-number>.1: <imperative title>
  **Type**: [component | hook | service | api | model | migration | test | config | refactor]
  **Files**: `path/a`, `path/b`
  **Implements**: the contract from `## Contracts`, or `none`
  **Description**: ...
  **Notes**: ...
  **Independent**: no

- [ ] Step <criterion-number>.2: <imperative title>
  **Type**: test
  **Files**: `path/c`
  **Implements**: none
  **Description**: ...
  **Notes**: ...
  **Independent**: yes

## Contracts

### `path/a`

```ts
<the exact signature, type, route or schema, copied from the design>
```

## Tests
| Spec Line | Test File | Create or Edit |
| --------- | --------- | -------------- |

## Verification
| Repo | Check | Command | Expected Result | Source |
| ---- | ----- | ------- | --------------- | ------ |
| `foo-bar` | test | `pnpm test src/checkout` | all green | `package.json` scripts |
| `foo-bar` | types | `pnpm typecheck` | exit 0 | `CLAUDE.md` |
| `foo-bar` | browser | `pnpm dev` | per `### Browser` | `README.md` |

### Browser
- URL: `http://localhost:3000/checkout`
1. Given: <the browser state that sets up the precondition>
1. When: <the clicks and inputs of the action>
1. Then: <what the page shows>

## Out Of Scope
- NEVER implement another criterion of this story:
  - <other-criterion-number>: <its title>
- NEVER broaden scope into unrelated cleanup or an opportunistic refactor
- NEVER run any git command from a step marked independent

## Assumptions
| ID | Assumption | Why It Matters | Status | Evidence or Decision |
| --- | ---------- | -------------- | ------ | -------------------- |

## Findings
| Doc | Finding | Suggested Change |
| --- | ------- | ----------------- |

## References
- `$EPIC_DIR/story-<story-number>.md`
- `$EPIC_DIR/story-<story-number>-design.md`
`````

## Section rules

| Section | Rule |
| --- | --- |
| Criterion | The criterion copied VERBATIM from `story-<story-number>.md`, one clause per line, per conventions.md's Canonical blocks rule |
| Outcome | What is true when the criterion is done, observable from outside the code. NEVER a restatement of the steps |
| Dependencies | `none`, or one line per prerequisite. A parent criterion is an `AC <criterion-number>` line, which commands parse; its number may be higher than this criterion's. Any other prerequisite is verified in the codebase, or asked about, before the plan is written |
| Files | One row per file this criterion touches. Exact path, `create` or `edit`, one clause on what changes. A file no step owns does not belong here |
| Steps | Numbered `Step <criterion-number>.<k>`, in execution order. Each step delivers a coherent slice through every layer it touches, never one technology layer of several. `**Independent**: yes` ONLY when the step shares no file with any other step, and its description carries every path, name and signature it needs |
| Contracts | The exact signatures, types, names, routes, schema and migrations, copied verbatim from `story-<story-number>-design.md`, one block per file. NEVER paraphrased, NEVER invented, NEVER completed from a `TODO` |
| Tests | The spec lines this criterion must make pass, in the repo's own test format, each with the file it lives in. The repo has no testing pattern for this area → say so, and name the manual check |
| Verification | The exact commands, with what counts as a pass and the file each one came from. `a-plan` reads them from the repo: its `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`, then `package.json` scripts, `Makefile`, CI files. A check with no command found is `- None`. The last row is `browser` when the criterion's _Then_ shows in a browser: its command starts the app, and `### Browser` holds the URL and the _Given_ / _When_ / _Then_ as browser steps. Otherwise no `browser` row and no `### Browser` |
| Out Of Scope | Explicit NEVERs. Every other criterion of this story is named, by number and title |
| Assumptions | Per conventions.md's Assumptions rule. No row may stay `open` or `cascaded` |
| Findings | Per conventions `## Findings`. `a-implement` and `a-check` append rows. No rows when none were found |

## Rules

1. The reader has no access to the conversation, the design document, or the story. Everything the steps need is in this file
1. Every path is real, or is marked `create`
1. Exactly one step owns each file. A shared file — an index, a route table, a migration list, a barrel export — belongs to ONE step, and that step is never `independent`
1. NEVER mention epic, story, acceptance criterion, AC, or any other workflow jargon in text the plan tells the implementer to write into code, comments or user-facing copy
1. NEVER record how the plan got here. `story-<story-number>-design.md`'s `## Decision Registry` holds that
1. NEVER write waves, task packets, subagent prompts, model tables or effort tables
