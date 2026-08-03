---
name: planning
description: MUST use in plan mode when writing plans
---

# How to plan

## Exist gate

1. Producing a plan is _not at all required_, we only do it once the process is clear, if not, we work on clarifying it
1. If the scope is too big and the details of the plan are getting lost, propose to scope down only the first step, or divide the plan in multiple milestone that we can plan into details with ease
1. If the scope is not clear enough to create a plan, don't do it, let's discuss the points that need clarification

### When is a plan too big

1. If you struggle even a little to define clear diagrams
1. If it's more than one feature
1. Comparatively, the size of a CRUD endpoint (ui, api, db) should be as big a plan should go, and no further

## Related skills

1. ALWAYS incorporate the **coding skill** into implementation plans
1. When APIs are involved, incorporate the **api skill** into API-related planning decisions

## YAGNI

Plans should solve today's requirements with minimal complexity.

Do not plan speculative features, abstractions, or scalability work without concrete evidence they are needed. Over-planning increases cost, coordination, and divergence from real requirements.

## Thinking

1. Interactions with the user in chat should use the **chat skill** and be brief
1. Unless answering a direct question, drastically limit conversation, express yourself through the plan
  - This doesn't mean to add your thinking to the plan
  - If relevant, add our conclusions to the decision registry section

## Output document

Accuracy here is paramount. Include these H2 sections at the top of the plan:

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
1. Happy path automated test
  - Follow the format in the **testing skill**
1. Current weaknesses & risks
  - This critically at the problem and the latest proposed solution and find edge cases that we might need to consider now, or address as a second iteration
  - Will the plan work? Is there any hard blocker?
  - Are we including any work that is not necessary to achieve the goal?
1. Architecture
  - Design patterns, good practices, smells to avoid, relevant for a quality solution
  - Any relevant information that still needs to be expressed for the implementation to result in a quality solution
1. Decision registry table
  - The _only_ place allowed to store historical information about the evolution of the plan, all the rest of the plan must NOT be concerned with "how we got here", but only with how to _efficiently_ implement the final plan
  - All options that were considered, mostly through user interaction, but add your comparisons if important
  - If the user decided but there's no reason in the conversation, say: "User decision." then you are allowed to elaborate with your speculations
  - Includes all the considered options, their tradeoffs, risks and WHY we picked one solution over another
  - Resolved weaknesses & Risks (from the section above)
1. Any other section you reckon will be useful for implementation

Omit empty sections. Speculations NEED to be resolved through user communication, NOT ignored.
