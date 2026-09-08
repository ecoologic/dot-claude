---
name: diagrams
description: MUST USE when writing mermaid diagrams; Write accurate and complete diagrams
---

# How to write all diagrams

1. Diagrams must be detailed and logically correct, so they require full understanding
1. Arrows description should be: API calls, methods invocations and functions, a separate text line _can_ add intent and notes _if needed_; don't use prose when you can use a method call
1. If you use colors, you MUST specify light and dark mode
1. Use blue for new and planned elements
1. ONLY display information that is relevant to context, not everything needs to be rendered
1. Use UML
1. Beware of character escaping in mermaid

## Legend

Right after, outside of the diagram, add a legend and list with the most important elements and their code location. The text of the link must be verbatim what's in the diagram

Example:

1. [User#email](./api/user.py:123)

Telegraphically explain choices like dotted lines and the use of blue for planned elements.

