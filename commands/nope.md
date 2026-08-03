---
description: Audit the previous response against all loaded rules and surface violations
argument-hint: [hint about what went wrong]
allowed-tools: [Read, Glob, Grep]
---

# Nope — Rule Violation Audit

Audit the most recent response (immediately before `/nope`, including if you were stopped mid-thinking) against every instruction loaded in this conversation. If $ARGUMENTS is provided, treat it as a hint about what the user suspects went wrong.

## Goal

Determine not just **which** instructions were violated, but **why** they were not followed and **how the instructions should be _briefly_ amended** so the same failure is less likely to happen again.

## Step 1: Capture the response under review

Re-read the last prompt and assistant response verbatim (note this request might come mid-ai-thinking). Identify and quote:

1. **Key decisions** made (tool choices, structure, tone, format)
2. **Omissions** — anything conspicuously absent (missing sections, skipped steps)
3. **Assertions** — claims about what was done or why

Output a brief summary (3-5 bullets max):

```
Response under review:
- [decision/omission/assertion #1]
- [decision/omission/assertion #2]
- ...
```

DO NOT skip this step. The response must be fresh in context before auditing.

## Step 2: Enumerate and read all instruction sources

List every instruction source currently loaded in this conversation. Exclude project-specific application code and documentation — only include files that govern agent behaviour (CLAUDE.md, SKILL.md, command files, settings, system prompts).

Read each file now using the Read tool. Output a numbered reference list:

```
Instruction sources:
1. [path] — [one-line summary of what it governs]
2. [path] — [one-line summary]
...
```

## Step 3: Extract rules, cross-check, and diagnose root cause

For **each** instruction source from Step 2, perform the following:

1. Extract every directive, constraint, preference, or rule from that source
2. Compare each rule against the response summary from Step 1
3. Check $ARGUMENTS for additional clues about suspected violations
4. Flag any rule that was violated, partially followed, or ignored
5. For each flagged issue, determine the **most likely reason** it happened

When diagnosing the reason, check for these failure modes first:

- **Instruction conflict** — two sources pushed in different directions and the response appears to have satisfied one by violating another
- **Priority ambiguity** — the source did not make clear which rule should win
- **Ambiguous wording** — the rule exists, but the wording leaves room for a reasonable misread
- **Missing command guidance** — the command did not explicitly require a step, output section, or check that the user expected
- **Low-salience instruction** — the rule was present but buried, easy to miss, or not reinforced at the moment it mattered
- **Execution drift** — the response appears to have prioritized convenience, habit, or momentum over the written instructions

Do not invent certainty. If the cause is not clear from the evidence, say `unclear` and list the top 1-2 plausible explanations.

For each violation found, record:

| # | Source | Rule (quoted) | What went wrong | Likely cause | Severity |
|---|--------|---------------|-----------------|--------------|----------|
| 1 | Source #N | `"<exact quote>"` | <specific failure> | <conflict / ambiguity / missing guidance / low salience / execution drift / unclear> | high/medium/low |

Severity guide:
- **high** — directly contradicts an explicit MUST/NEVER/ALWAYS directive
- **medium** — ignores a SHOULD/preference or skips a required step
- **low** — misses a stylistic convention or soft guideline

## Step 4: Report findings

Output the final report in this format:

```
## /nope Audit Results

**Response audited**: [first 10 words of the response]...
**Sources checked**: [count]
**Rules extracted**: [count]
**Violations found**: [count]

### Violations

[table from Step 3]

### Why This Happened

[1 short paragraph: identify the main failure pattern. Call out whether this looks like a true instruction conflict, a priority mistake, ambiguous wording, or a gap in the command itself.]

### Suggestions

- [specific amendment to an instruction or command]
- [specific wording change, ordering change, or required checkpoint]
- [only include suggestions that directly reduce the chance of this exact failure happening again]

Suggestion rules:
- Don't say something "just because", ONLY provide suggestions that are grounded in _facts_; We don't want to keep altering rules for no gain
- Focus on **improving the instructions**, not fixing the audited response
- Tie each suggestion to one or more violations above
- Prefer changes like: clarifying precedence, making a step explicit, requiring a section in the output, adding a stop/checkpoint, or rewriting ambiguous wording
- If the problem was a genuine conflict, suggest the exact priority rule that should be added
- If you "forgot", why could that have happened, context slop? something else?
- Provide a confidence score on your suggestions and order them from most-likely
```

If no violations are found, say so explicitly:

```
No violations detected across [N] sources and [M] rules.
The response appears compliant. If something still feels off,
re-invoke with a specific hint: /nope "the tone was wrong"
```

After the report, end the response with this exact follow-up question:

`Do you want me to draft a prompt to improve that skill in the project where you keep its source?`

## Important Notes

- **NEVER fabricate violations** — only flag rules with exact quotes from instruction sources
- **NEVER skip Step 1** — reviewing the response first prevents confirmation bias when reading rules
- **DO NOT read application code** — only read instruction/config files
- **DO NOT suggest application-level fixes** — suggestions must be limited to instruction, command, or rule improvements
- **DO explain likely causes** — especially when a conflict, ambiguity, or missing command step appears to be the reason
- **STOP after the report** — do not take corrective action
