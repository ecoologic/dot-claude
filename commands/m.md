---
description: Maybe — verify a claim the user is unsure about, or find a better design for an architecture question
argument-hint: "[<origin>;] <claim to verify>"
disable-model-invocation: true
---

# Maybe

Verify the claim in `$ARGUMENTS`. The user is not sure it holds.

## Rules

1. Read-only. NEVER edit, write, commit, or run a command that changes state
1. NEVER assume the claim is true because the user wrote it
1. NEVER contradict for the sake of it. Agreeing is a valid verdict. An alternative counts only when the evidence shows it is truly better
1. Be brief. The user asks for depth on a verdict or an option they like
1. `$ARGUMENTS` empty → ask for the claim, then stop

## Arguments

1. `$ARGUMENTS` holds a `;` → the text before the first `;` is the origin, the rest is the claim. No `;` → all of it is the claim
1. The origin names where to check: a repo path, a file, a URL, `web`, a library with its version. Check it first. Look elsewhere only when it does not settle the claim, and say so
1. No origin → look in this order, and stop at the first source that settles it:
   1. This conversation and the memory files
   1. The codebase: `Grep`, `Glob`, `Read`
   1. Git history: `git log -S`, `git log --grep`, `git blame`
   1. The web, only for public, versioned facts. ALWAYS name the version checked

## Steps

1. Restate the claim in one line as a statement that can be true or false. Ambiguous → name the reading you check, as a `❗❗ASSUMPTION❗❗`
1. Classify it:
   1. Fact: a behaviour, a location, a version, a rule → verify it
   1. Architecture: a design, a structure, an approach → verify it, then look for better implementations
1. Delegate when the search is wide. Send independent agents in ONE message:

| Need | `subagent_type` | `model` |
| --- | --- | --- |
| Sweep many files or naming conventions | `Explore` | `haiku` |
| Public docs, libs, APIs, standards | `general-purpose` | `sonnet` |
| Compare designs, trade-offs, a better structure | `Plan` | `opus` |

1. Each agent prompt carries the claim, the origin, and what you already found. Paste the text of every skill whose description matches the domain, per the global rules
1. Judge the findings yourself. NEVER relay an agent's verdict unchecked

## Report

Print only this:

```md
<verdict>: <the restated claim>

- <evidence, as `path:line`, a commit, or a URL with its version>
```

1. Verdict is one of `✅ True`, `❌ False`, `⚠️ Partly`, `❓ Unverified`
1. `⚠️ Partly` → say which part fails. `❓ Unverified` → name what would settle it
1. Max 3 evidence lines
1. Architecture only: then a numbered list of implementations that beat the current one, best first, one line each: the change, and what it wins. NEVER list an option only because it differs. None better → say the current design holds, and why, in one line
1. NEVER suggest a fix for a fact claim unless asked
