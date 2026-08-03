---
name: coding
description: MUST use for code, ALWAYS produce quality code in all languages
---

# How to code

ALWAYS Aggressively optimize towards extensibility, NOT for immediate task completion.

## Paradigms

1. Prefer _declarative_ style over imperative
1. Prefer functional or object-oriented (best suited in each case) over procedural

## Simplicity (Keep It Simple Stupid!)

1. Defensive coding: AVOID at all cost, ALWAYS test at the edges and assume verified elsewhere
1. Belt and harness: only where it matters the most, and MUST be _explicitly_ agreed with the user
1. Prefer explicit data flow over hidden mutable state
1. NEVER write functions longer than 40 lines, extract to local functions

## Readability

1. Narrative Integrity: Function implementations must read like _short_ prose that naturally condense the _main_ value into their title. The name is the "TL;DR" of the logic
1. Secondary objectives (eg: validating input, reading FS) can be ignored or implied in the function name when they don't help readability

## YAGNI (You ain't gonna need it!)

1. ALWAYS optimize for the simplest correct implementation that satisfies the current requirements
1. NEVER add configuration, extensibility, or abstractions without a real existing requirement
1. Extract abstractions from existing patterns, not imagined future needs

YAGNI is about avoiding speculative features, abstractions, and flexibility that are not required today. Keep the scope small so the code stays easy to change and iterate on.

YAGNI does NOT apply to code organization:

1. Extracting functions
1. Improving naming
1. Separating responsibilities
1. Reducing cognitive load

Clean structure is not over-engineering!

## DRY (Don't Repeat Yourself)

_KNOWLEDGE_ should not be repeated and dispersed across multiple files, it should be extracted at _every_ opportunity. This is related to grouping domain logic. Avoids drift, bugs and shotgun surgery.

## Dependency direction

1. Higher level modules should not depend on lower level modules; dependencies point inward only
1. If logic is generic, place it in a generic boundary even if it is currently used by only one feature
1. If logic is domain-specific, place it with that domain even if some parts look technically reusable
1. Prefer co-locating code with element that truly owns its meaning. Locality is a tie-breaker, not the primary rule

## Separation of concerns (cohesion)

1. NEVER mix business logic with infrastructure concerns
1. ALWAYS separate concerns by abstraction layer (domain, math, file-system, HTTP, DB, UI)
1. ALWAYS keep each function operating at a single semantic level; extract lower-level operations into dedicated, well-named, functions (note: might be an chance of reuse)
1. ALWAYS keep function names semantically aligned with their implementation
1. Every module owns exactly one responsibility

Example: Email validation:

1. The regex
1. The function that checks a valid email
1. The type guard

All belong in the same file (cohesion). NOT a file mixing unrelated regex, one unrelated types etc.

## Confident code

1. Validate and sanitize data at trust boundaries (eg: HTTP, queues, external APIs, files)
1. Inside trusted layers, rely on validated types instead of defensive re-validation
1. Prefer normalized data shapes and safe defaults to excessive null checks
1. Avoid nullable types unless absence is semantically meaningful; every state should represent a distinct meaning

## Naming

1. Principle of Least Astonishment (POLA): A function's name must be a faithful summary of its primary action. If the code does it, the name should say it
1. NEVER use synonyms, one concept, one name
1. Long names are great, names should be accurate and precise
1. NEVER abbreviate, eg: `NO org -> YES organization`
1. NEVER `jamwordstogether`, `separateEachWord` one word in English, one word in code
1. NEVER use cheap tricks like `user1,user2`: _what_ makes them different? Be specific! (eg: `subjectUser,maliciousUser`, `pendingTask,doneTask`)
1. NEVER create magic numbers, extract to const with domain oriented names (eg: `YES debounceMs, NO time,twoSeconds`)

## Domain Driven Development (DDD)

1. NEVER create files named after technical categories like `*-types.ts`, `constants.ts`, or `hooks.tsx`
1. ALWAYS extract when the abstraction has a clear domain meaning or is reused by multiple domain concepts
1. Keep types, constants, hooks, and implementation details near the domain logic that uses them
1. Name and group elements by domain, not by technology (cohesion)
1. Business logic must not depend on framework types

## Monitoring

1. NEVER hide errors
1. ALWAYS log all error details
