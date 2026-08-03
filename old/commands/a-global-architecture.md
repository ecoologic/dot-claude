---
description: Map the repo-wide architecture and write the shared glossary and global architecture artifacts
argument-hint: "[instructions-or-suggestions]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Agent, Skill, AskUserQuestion]
---

# Global Architecture

### Pipeline I/O

| Direction | File | Description |
| --------- | ---- | ----------- |
| **In** | codebase | Read-only repo structure, conventions, modules, contracts, and domain language |
| **In** | durable repo docs | Product docs, architecture docs, ADRs, README files, and stable references |
| **Out** | `./planning/global-architecture.md` | Lean cross-epic map of major system areas, boundaries, and communication paths |
| **Out** | `./planning/glossary.md` | Shared domain glossary with canonical names, code names, sources, and statuses |

## Purpose

Build the shared workflow baseline before epic-specific work begins.

This command owns two cross-epic artifacts:
- `global-architecture.md` for structure and communication paths
- `glossary.md` for domain language and canonical naming

Later commands may refine them, but this command is the baseline producer.

The architecture map must explicitly call out the shared reuse surface of the repo, especially any `common` package and any durable reusable folders such as `types/`, `components/`, `utils/`, `hooks/`, or similar shared locations.

## Skills

Use these skills when relevant:
- `explore` for repo-wide discovery
- `ecoologic-code` for naming and convention alignment
- `mermaid-diagrams` if diagrams materially improve the repo map

## Rules

- NEVER write or modify application code
- NEVER put epic-specific rationale into `global-architecture.md`
- NEVER put temporary aliases or speculative names into `glossary.md`
- NEVER define synonyms for the same concept
- prefer durable structure over local implementation noise
- prefer code and stable project conventions over aspirational docs when they disagree

## Step 0: Parse optional guidance

`$ARGUMENTS` = `[instructions-or-suggestions]` — high-priority guidance for this run. Does not override verified repo structure or durable naming.

## Step 1: Explore the repo-wide structure

Assemble stable repo docs for this run (README, ADRs, architecture docs, integration specs, contracts). Stop and report any unreadable reference.

Inspect the codebase and stable docs to identify:
- major apps, services, packages, and modules
- shared or common reuse areas, including packages and reusable folders
- reusable code buckets such as general types, shared UI components, hooks, helpers, utils, schemas, or constants
- responsibilities and ownership boundaries
- communication paths between major parts
- stable integrations and infrastructure touchpoints
- OpenAPI files, generated API clients, and other machine-readable API contracts
- external API integrations and the durable docs or specs that describe them
- durable shared contracts
- whether shared building blocks live in packages, folders, or both
- cross-epic domain language already present in docs or code

Use targeted exploration with parallel agents when helpful, but keep the result focused on durable shared context.

## Step 2: Build the glossary

Write `./planning/glossary.md` as the canonical shared naming artifact.

Use this structure:

```md
# Glossary

> Generated: <date>

| Domain Term | Code Name | Definition | Source | Status |
| ----------- | --------- | ---------- | ------ | ------ |
| ... | ... | ... | ... | ... |
```

Rules:
- **Domain Term** is the human planning term to use across commands
- **Code Name** is the current code-level name, or `—` if not yet implemented
- **Source** points to the file, module, doc, or artifact that justifies the row
- **Status** should be `exists`, `new`, `rename-request`, or `exists (extend with ...)`

Only include durable terms that later planning and implementation work should inherit.

## Step 3: Build the global architecture map

Write `./planning/global-architecture.md` as a lean cross-epic map.

Use this structure:

```md
# Global Architecture

> Generated: <date>

## Major System Areas
### <area>
- responsibility
- key boundaries

## Code Reuse Surface
Briefly explain where engineers should look first for code that is designed to be reused across features or epics.

| Reusable Area | Type | What Lives Here | Reuse Guidance | Main Consumers |
| ------------- | ---- | --------------- | -------------- | -------------- |
| `src/components` | folder | shared UI building blocks | reuse as-is before creating feature-local UI | web app, admin app |
| `src/types` | folder | shared domain and API types | extend carefully; avoid duplicate type aliases elsewhere | frontend, backend |
| ... | ... | ... | ... | ... |

### Notes
- Prefer durable shared folders over feature-local folders when both exist.
- Call out when a folder appears reusable in practice even if it is not formally named `shared` or `common`.
- Mention when the same concern is split across multiple reusable folders, for example `types/` plus `schemas/`.

## Shared Reuse Details
### <shared package or folder>
- type: `package` | `folder`
- purpose
- what is intended for reuse
- who consumes it

## Communication Paths
- `ui -> api`
- `api -> db`
- ...

## Stable Contracts And Integrations
- ...

## Shared Constraints
- ...

## References
- ...
```

If the repo has a `common` package, name it explicitly and describe what kinds of code should be reused from it.

If reusable code lives in general folders instead of packages, name those folders explicitly too, for example shared `types/`, `components/`, `utils/`, `hooks/`, `schemas/`, or similar locations.

The `Code Reuse Surface` section must be easy to scan and must explicitly list the most reusable folders or packages in the repo, not just describe reuse abstractly.

If the repo contains OpenAPI files, generated clients, or integrations to external APIs, call them out in `Stable Contracts And Integrations` and include the relevant source docs or specs in `References`.

Do not include:
- current epic goals
- story-specific design detail
- temporary assumptions
- local implementation notes that do not matter across epics

## Step 4: Present to user

Summarize:
1. major system areas identified
2. key communication paths
3. glossary terms created or updated
4. open conflicts or rename requests

Ask the user to review before epic-specific planning begins.

## Success Criteria

- [ ] `./planning/global-architecture.md` exists
- [ ] `./planning/glossary.md` exists
- [ ] all required inputs and followed references were validated before synthesis continued
- [ ] the architecture file is lean and cross-epic
- [ ] the architecture file contains a clear `Code Reuse Surface` section
- [ ] reusable areas such as a `common` package or reusable folders are explicit when they exist
- [ ] common reusable folders such as `types/`, `components/`, `utils/`, or equivalents are listed when they exist
- [ ] OpenAPI files and external API integrations are named when they exist
- [ ] relevant API docs or specs are linked in `References` when those contracts or integrations exist
- [ ] the glossary is domain-based and canonical
- [ ] no synonyms were introduced
- [ ] the user reviewed the shared artifacts before moving on

## Error Handling

@include includes/error-protocol.md

- **No meaningful codebase structure found** — say so explicitly and produce the leanest truthful map possible
- **Naming conflicts found** — record them as conflicts or rename requests instead of choosing silently
- **Docs and code disagree** — prefer the codebase, record the disagreement, and surface it to the user
