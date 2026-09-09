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

## Validate before delivering

ALWAYS render every mermaid block with the CLI after the last edit; never deliver an unrendered diagram.

1. Extract each block to a `.mmd` in the scratchpad:
   `awk '/^```mermaid/{n++; f=1; next} /^```/{f=0} f{print > ("diagram" n ".mmd")}' <file>.md`
1. Render with explicit paths (mmdc exists only under nvm v26.5.0):
   `/Users/erik.trapin/.nvm/versions/node/v26.5.0/bin/node /Users/erik.trapin/.nvm/versions/node/v26.5.0/bin/mmdc -i in.mmd -o out.svg`
1. On failure, grep the output for `Parse error`, fix, re-render until every block passes

Known traps: `;` inside sequence-diagram message text ends the statement (use commas or "then"); `#`, `:` and `()` in node labels need quoting.
