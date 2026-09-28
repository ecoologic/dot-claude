---
description: "Template: story-N-acM.md, the one-criterion implementation plan produced by /a-plan"
disable-model-invocation: true
---

# Plan document template

`story-<story-number>-ac<criterion-number>.md` lives at `$EPIC_DIR/story-<story-number>-ac<criterion-number>.md`, beside `story-<story-number>-design.md`. `/a-plan` writes it; `/a-edit plan <story-number> <criterion-number>` revises it.

One file per acceptance criterion. `/a-implement` executes it with no access to the story, the design, or the conversation that produced them. `/a-implement` ticks each step, then sets `status: implemented`, `branch` and `pr` in the header. `/a-check` appends `, simplified` and `, reviewed` to `status`.

## Shape

The document is these H2 sections, in this order.

`````md
---
updated: 2026-09-23T14:05+1000
status: draft
branch: -
pr: -
---

# Plan <story-number>-<criterion-number>: <criterion title>

> Epic: <epic name>
> Source Story: `$EPIC_DIR/story-<story-number>.md`
> Source Design: `$EPIC_DIR/story-<story-number>-design.md`
> Repos: <repo>, <repo>

## Criterion

> _Given_ [precondition] \
> _When_ [action] \
> _Then_ [expected result]

### Outcome
- What must be true when this criterion is complete

### Dependencies
- `none`, or `Criterion <n>` of this story, or `Story <other-story-number>`, each with the file, symbol or test that verifies it, or the user's decision

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
| Repo | Check | Command | Expected Result |
| ---- | ----- | ------- | --------------- |
| `foo-bar` | test | `pnpm test src/checkout` | all green |
| `foo-bar` | types | `pnpm typecheck` | exit 0 |

## Out Of Scope
- NEVER implement acceptance criterion <criterion-number + 1>: <its title>
- NEVER broaden scope into unrelated cleanup or an opportunistic refactor
- NEVER run any git command from a step marked independent

## Assumptions
| ID | Assumption | Why It Matters | Status | Evidence or Decision |
| --- | ---------- | -------------- | ------ | -------------------- |

## References
- `$EPIC_DIR/story-<story-number>.md`
- `$EPIC_DIR/story-<story-number>-design.md`
`````

## Section rules

| Section | Rule |
| --- | --- |
| Criterion | The criterion copied VERBATIM from `story-<story-number>.md`, one clause per line, per conventions.md's Canonical blocks rule |
| Outcome | What is true when the criterion is done, observable from outside the code. NEVER a restatement of the steps |
| Dependencies | `none`, or the prerequisite, with what verifies it. A dependency that is not `none` is verified in the codebase, or asked about, before the plan is written |
| Files | One row per file this criterion touches. Exact path, `create` or `edit`, one clause on what changes. A file no step owns does not belong here |
| Steps | Numbered `Step <criterion-number>.<k>`, in execution order. Each step delivers a coherent slice through every layer it touches, never one technology layer of several. `**Independent**: yes` ONLY when the step shares no file with any other step, and its description carries every path, name and signature it needs |
| Contracts | The exact signatures, types, names, routes, schema and migrations, copied verbatim from `story-<story-number>-design.md`, one block per file. NEVER paraphrased, NEVER invented, NEVER completed from a `TODO` |
| Tests | The spec lines this criterion must make pass, in the repo's own test format, each with the file it lives in. The repo has no testing pattern for this area → say so, and name the manual check |
| Verification | The exact commands, as the user gave them, with what counts as a pass. NEVER a detected or inferred command. A check the user named no command for is `- None` |
| Out Of Scope | Explicit NEVERs. The next criterion is named every time, by number and title |
| Assumptions | Per conventions.md's Assumptions rule. No row may stay `open` or `cascaded` |

## Rules

1. The reader has no access to the conversation, the design document, or the story. Everything the steps need is in this file
1. Every path is real, or is marked `create`
1. Exactly one step owns each file. A shared file — an index, a route table, a migration list, a barrel export — belongs to ONE step, and that step is never `independent`
1. NEVER mention epic, story, acceptance criterion, AC, or any other workflow jargon in text the plan tells the implementer to write into code, comments or user-facing copy
1. NEVER record how the plan got here. `story-<story-number>-design.md`'s `## Decision Registry` holds that
1. NEVER write waves, task packets, subagent prompts, model tables or effort tables
