---
name: planning
description: MUST use in plan mode when writing plans
---

# How to plan

## Entry gate

1. Producing a plan is _not at all required_, we only do it once the process is clear, if not, we work on clarifying it
1. If the scope is too big and the details of the plan are getting lost, propose to scope down only the first step, or divide the plan in multiple milestone that we can plan into details with ease
1. If the scope is not clear enough to create a plan, don't do it, let's discuss the points that need clarification
1. NEVER offer to proceed to implementation, I'll tell you that when I decide that the plan is ready

### When is a plan too big?

1. If you struggle even a little to define clear diagrams
1. If it's more than one feature
1. Comparatively, the size of a CRUD endpoint (ui, api, db) should be as big a plan should go, and no further

## Related skills

1. ALWAYS incorporate the **coding skill** into implementation plans
1. When APIs are involved, incorporate the **api skill** into API-related planning decisions

## Thinking

1. Interactions with the user in chat should follow the active output style and be brief
1. Unless answering a direct question, drastically limit conversation, express yourself through the plan
  - This doesn't mean to add your thinking to the plan
  - If relevant, add our conclusions to the decision registry section

## User requests

1. The user can make mistakes and get confused, your job is to clarify and find the correct solution, not to blindly follow the user
1. If the user asks to change existing interfaces beyond the scope of the plan, explain and ask for confirmation

## Output document

1. You are allowed to create and edit documents (eg: `*.md`) in plan mode
1. Omit empty sections. Speculations NEED to be marked TODO in the plan
1. Accuracy here is paramount
1. Enforce your output style

Ask the user what the title should be, offer three short options

The plan consists of these H2 sections, in order:

1. Goal
  - One brief paragraph for the problem
  - One brief paragraph for the proposed solution
1. File structure
  - Print the structure of the relevant files in a code block like a `tree` command would do
1. Sequence diagram
  - Use mermaid and the **diagrams skill** to complete them
1. Class diagram
  - Use mermaid and the **diagrams skill** to complete them
1. API endpoints
  - Endpoint usage only
  - Follow the format in the **api skill**
1. DB migrations
  - Full SQL
1. Happy path automated tests:
  - Print in spec style reported output:
    Ie: `- {Class}#{method} when {xxx} returns {y}` or `- {Component} when {context} renders {result}`
    Nest common elements with indentation; eg: don't repeat `{Class}#{method}`, indent one for class and one for method
    No implementation needed
  - Tests the stated outcome and _important and complex_ internals, not just the easy cosmetics
  - We're here highlighting the most relevant for the feature; implementation should also include sad paths
1. Current weaknesses & risks (table)
  - Look critically at the problem and the latest proposed solution and find edge cases that we might need to consider now, or address as a second iteration
  - Will the plan work? Is there any hard blocker?
  - Are we including any work that is not necessary to achieve the goal?
  - One row per risk, ordered by impact, biggest first
  - Columns:

    | Column | Content |
    | --- | --- |
    | Risk | Short title, max 5 words |
    | Details | ELI5 (Explain Like I am 5): what breaks, and when. Plain words. Max 2 sentences |
    | Impact | T-shirt size: XS, S, M, L, XL |
    | Resolution | Status, then a one-sentence solution. Status is one of: open, accepted, mitigated, postponed, resolved |
1. Architecture
  - Design patterns, good practices, smells to avoid, relevant for a quality solution
  - Any relevant information that still needs to be expressed for the implementation to result in a quality solution
1. Decision registry table
  - The _only_ place allowed to store historical information about the evolution of the plan, all the rest of the plan must NOT be concerned with "how we got here", but only with how to _efficiently_ implement the final plan
  - Me correcting your misunderstandings doesn't belong in the decision registry
  - Keep entries at plan altitude: a wording/naming back-and-forth during the conversation is not a decision worth persisting, even here — only record it if it actually changed the approach
  - All options that were considered, mostly through user interaction, but add your comparisons if important
  - If the user decided but there's no reason in the conversation, say: "User decision." then you are allowed to elaborate with your speculations
  - Includes all the considered options, their tradeoffs, risks and WHY we picked one solution over another
  - Resolved weaknesses & Risks (from the section above)
1. Implementation steps (ordered numbered list)
  - Break down into small tasks, you'll implement them, so write them in a way that you can understand and implement them
  - Look for opportunities to parallelize work
  - Ask yourself if `./CONTEXT.md`, `./README.md`, `./CONTRIBUTING.md` etc need to be updated, and if so, add it to the steps
1. A list of every DRY infraction found (per the coding skill), or a brief confirmation that none is present
1. A brief sentence confirming whether the plan is ready, and suggest what model and effort are most suited
1. AI section
  - **Any other section you reckon will be useful for implementation**
  - IMPORTANT! the format for the doc is so that the user can understand the plan, but you're equally involved! You should record any information that is missing to implement the plan successfully
  - Consider the model in charge of implementation will be a little less capable than you
  - Plan for multi-agent implementation
  - Look for the available skills both global and specific to the folders the plan will touch, and load them when needed, and instruct sub-agents to do the same
