---
name: diagrams
description: MUST USE when writing mermaid diagrams; Write accurate and complete diagrams
---

# How to write code diagrams

1. Diagrams must be detailed and logically correct, so they require full understanding
  - Assumptions MUST BE AVOIDED AT ALL COST, rather than making any assumption, either verify or STOP immediately and ask the user
1. If you don't have the necessary level of domain details, push back and DON'T write the diagram, research or STOP immediately and ask the user
1. All domain module/classes/libs/services involved MUST be present
  - Start with the relative `path/file-name.extension` (when local), then the name of the element, eg: `src/fs/file.ts File`, `Stripe API`
  - Utils, non-domain logic or implementation details can be omitted for clarity, provided the diagram still clearly expresses _how_ we decided to achieve the goal

## Sequence diagrams

1. Actors should be shown both at the top and bottom
1. All function calls to each actor MUST be present, eg: `readFile(fileName)`, `GET /users`
