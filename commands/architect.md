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
1. The `uml-diagram` agent owns the mermaid diagrams, see **Diagrams**

## Diagrams

1. The `uml-diagram` agent draws the Sequence diagram and the Class diagram, NEVER draw them yourself
1. Call the `Agent` tool with `subagent_type: "uml-diagram"`, once per section, every time the design changes what that diagram shows
1. The prompt carries these, and nothing else:
   1. The mode: `design`, and the form: `sequence` or `class`
   1. The current design text the diagram depends on
   1. The repository paths of the existing code the design touches
1. Paste what the agent returns VERBATIM under the section heading. The agent validates its own diagram, do NOT edit it
1. When the agent reports the section is undiagrammable, omit the section and say why in one clause

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

## Story folder

1. Every story owns one folder: `~/dev/plans/<epic>/<story-slug>/`
1. The slug identifies the work everywhere: the folder name, the git branch, and the `/continue` argument
1. Ask for the epic and the slug ONCE, at the point you are ready to write the document, never before
1. Derive both from the conversation first, then ask the user to confirm or correct them in one question
1. The slug is kebab-case, max 5 words, no dates, no ticket keys
1. The folder already exists with a `design.md` in it → say so, then overwrite that file, never create a second folder
1. Create the folder, then write the document as `design.md` inside it

## Output document

1. Read `~/.claude/commands/architect/template.md`, it is the template for the document, follow it exactly
1. The template file has its own frontmatter, it is not part of the document
1. Write the document to `~/dev/plans/<epic>/<story-slug>/design.md`, see **Story folder**
1. Omit empty sections. Speculations NEED to be marked TODO in the design
1. Accuracy here is paramount
1. Enforce your output style
1. Tell the user the path of the document, `/architect-handoff` takes it as an argument

