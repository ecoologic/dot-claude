---
description: Agree a design with the user - boundaries, classes, interactions, names
disable-model-invocation: true
---

# How to architect

## Scope

1. This command agrees a _design_ with the user: boundaries, modules, classes, interactions, contracts, names
1. NEVER write implementation steps, work breakdowns, task packets or subagent instructions here
1. `/architect-handoff` converts the agreed design into execution instructions, in a separate document
1. NEVER write production code in this command

## Related skills

1. ALWAYS incorporate the **coding skill** into design decisions
1. When APIs are involved, incorporate the **api skill** into API-related design decisions
1. Use the **diagrams skill** for every mermaid diagram

## Thinking

1. Interactions with the user in chat should follow the active output style and be brief
1. Unless answering a direct question, drastically limit conversation, express yourself through the design
  - This doesn't mean to add your thinking to the design
  - If relevant, add our conclusions to the decision registry section, but don't store conversation _history_ anywhere else, only the latest understanding

## User requests

1. The user can make mistakes and get confused, your job is to clarify and find the correct solution, not to blindly follow the user
1. If the user asks to change existing interfaces beyond the scope of the design, explain and ask for confirmation

## Exit gate

1. The next step is to finalise the design, not to implement it, and not to plan the work
1. NEVER offer to proceed to implementation or to `/architect-handoff`, the user says when the design is ready

## Output document

1. Read `~/.claude/commands/architect/template.md`, it is the template for the document, follow it exactly
1. The template file has its own frontmatter, it is not part of the document
1. Omit empty sections. Speculations NEED to be marked TODO in the design
1. Accuracy here is paramount
1. Enforce your output style
1. Tell the user the path of the document, `/architect-handoff` takes it as an argument

