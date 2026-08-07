---
name: diagrams
description: MUST USE when writing mermaid diagrams; Write accurate and complete diagrams
---

# How to write all diagrams

1. Diagrams must be detailed and logically correct, so they require full understanding
1. All domain module/classes/libs/services involved MUST be present in the diagram
  - Start with the relative `path/file-name.extension` (when local), then the name of the element, eg: `src/fs/file.ts Class`, `Stripe API`
  - Utils, non-domain logic or implementation details can be omitted for clarity, provided the diagram still clearly expresses _how_ the goal is achieved
1. Arrows description should be: API calls, methods invocations and functions, a separate text line _can_ add intent and notes _if needed_
1. Don't override colors, it breaks dark mode

## Legend

After, outside of the diagram, ONLY for existing code, add a legend list with the most important functions in the diagram arrows linked to their code location:

Example:

1. [User#email](./api/user.py:123)

## Sequence diagrams

1. Actors should be shown both at the top and bottom
1. All function calls to each actor MUST be present, eg: `readFile(fileName)`, `GET /users`
