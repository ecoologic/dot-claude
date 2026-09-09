---
description: "Template: architecture document produced by /architect"
disable-model-invocation: true
---

# Architecture document template

The architecture consists of these H2 sections, in order:

## Goal

- **Problem**: One brief paragraph ELI5
- **Solution**: One brief paragraph ELI5

## File structure

- Print the structure of the relevant files in a code block like a `tree` command would do

## Sequence diagram

- Use mermaid and the **diagrams skill** to complete them

## Class diagram

- Use mermaid and the **diagrams skill** to complete them

## API endpoints

- Endpoint usage only
- Follow the format in the **api skill**

## DB migrations

- Full SQL in a single block, no comments

## Happy path automated tests

- Think "describing the high level results as tests" - this is useful for us to agree on how the system interacts
- Use a subagent, the first time decide what's the most suited effort, then reuse it
- Pass the subagent only the context it needs to update the section
- Tell the subagent to use the testing skill and use that format

## Current weaknesses & risks

- Use a subagent, the first time decide what's the most suited effort, then reuse it
- It will look critically at the problem and the latest proposed solution and find edge cases that we might need to consider now, or address as a second iteration
- Will the architecture work? Is there any hard blocker?
- Are we including any work that is not necessary to achieve the goal?
- One row per risk, ordered by impact, biggest first
- Columns:

  | Column | Content |
  | --- | --- |
  | Impact | T-shirt size |
  | Risk | Short title, max 5 words |
  | Details | ELI5 example. Max 3 sentences |
  | Resolution | Status (open, accepted, mitigated, postponed), then a one-sentence solution |

## Architecture

- Design patterns, good practices, smells to avoid, relevant for a quality solution
- Boundaries, dependency direction, ownership of each responsibility
- Any relevant information that still needs to be expressed for the implementation to result in a quality solution

## Decision registry table

- The _only_ place allowed to store historical information about the evolution of the design, all the rest of the document must NOT be concerned with "how we got here", but only with how to _efficiently_ implement the final design
- Me correcting your misunderstandings doesn't belong in the decision registry
- Keep entries at design altitude: a wording/naming back-and-forth during the conversation is not a decision worth persisting, even here — only record it if it actually changed the approach
- All options that were considered, mostly through user interaction, but add your comparisons if important
- If the user decided but there's no reason in the conversation, say: "User decision." then you are allowed to elaborate with your speculations
- Includes all the considered options, their tradeoffs, risks and WHY we picked one solution over another
- Resolved weaknesses & Risks (from the section above)

## AI notes

- **Any other missing section in your current understanding that you reckon will be useful to implement this design**
- Invariants, gotchas, and existing code to reuse that came up in conversation and have not been recorded elsewhere
- No need to think of work breakdown, task packets, model/effort choices or subagent instructions here, `/architect-handoff` owns those

## A brief sentence confirming whether the design is ready

- Work todo, or
- suggest `/architect-handoff <this-file-path>`