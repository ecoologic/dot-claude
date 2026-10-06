# Writing the body

## Size and progressive disclosure

Three load levels:

| Level | Loads | Cost |
|---|---|---|
| Name + description | Every session | ~100 tokens per skill |
| `SKILL.md` body | On invocation, stays for the session | Full body |
| `references/`, `scripts/`, `assets/` | Only when read or run | Zero until used; script code never enters context, only output |

1. House rule: max 100 lines per `.md`. Docs allow 500; house wins
1. Keep references ONE level deep from `SKILL.md`. Nested chains cause partial reads
1. Link each reference with when to read it: "Read `references/x.md` when ..."
1. If Claude never reads a bundled file, the link signal is weak or the file is unneeded
1. Name files by content (`form-validation-rules.md`, not `doc2.md`). Group by domain (`references/aws.md`)
1. Forward slashes in every path

## Layout

```
skill-name/
├── SKILL.md       router + key rules
├── references/    docs read on demand
├── scripts/       code Claude runs
└── assets/        templates, files used in output
```

## Content rules

1. Assume Claude is smart. Add only what it lacks. Challenge each line's token cost
1. One term per concept. NEVER rotate synonyms
1. One default approach plus an escape hatch. NEVER list equal options
1. No time-sensitive text ("until August"). Put legacy content in an "Old patterns" section
1. Explain the why behind each rule. Claude generalises from reasons, not from bare commands
1. Write standing instructions for the whole task, not one-shot steps. The body stays in context for later turns

## Degrees of freedom

Match strictness to fragility:

| Task | Freedom | Form |
|---|---|---|
| Many valid ways, judgement | High | Short principles |
| Preferred pattern, some variation | Medium | Pseudocode or parameterised script |
| Fragile, exact order | Low | Exact commands, "run exactly" |

## Patterns

1. Output format → a template. "ALWAYS use this exact template" for strict, "sensible default" for flexible
1. Style matters → input/output example pairs
1. Multi-step task → numbered steps plus a copyable checklist
1. Quality-critical → feedback loop: run validator → fix → repeat until clean
1. Batch or destructive work → plan-validate-execute: write a plan file, validate it with a script, then execute
1. Branching task → conditional routing: "Creating? → section A. Editing? → section B"

## Scripts

1. Say "Run `scripts/x.py`" (execute) or "See `scripts/x.py`" (read). Prefer execute
1. Scripts handle errors themselves with clear messages. Solve, do not defer to Claude
1. Justify every constant in a comment. No unexplained values
1. List required packages in `SKILL.md`. NEVER assume a tool is installed
1. Prefer a script for deterministic work: more reliable, fewer tokens, same result each time
1. MCP tools by fully qualified name: `ServerName:tool_name`
1. Reference bundled files with `${CLAUDE_SKILL_DIR}` (see `runtime.md`)

## Review pass

1. Re-read the draft as a fresh reader. Cut what does not change behaviour
1. Check the house rules in `SKILL.md`
