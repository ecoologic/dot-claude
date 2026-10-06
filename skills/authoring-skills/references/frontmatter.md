# Frontmatter

1. The opening `---` MUST be on line 1. Malformed YAML turns the whole file into body with empty metadata
1. Keep it minimal. Add a key only when its default is wrong for this skill

## `name`

1. [HARD] Max 64 chars: lowercase letters, digits, hyphens
1. [HARD] No leading or trailing hyphen, no `--`
1. [HARD] No XML tags. No reserved words `anthropic` or `claude`
1. [HARD] Equal to the parent folder name
1. Prefer gerund form (`processing-pdfs`). Noun or verb-first is acceptable
1. NEVER use vague names (`helper`, `utils`, `tools`, `data`)
1. Claude Code (CC): optional, defaults to the folder name. It sets `/name`

## `description`

The description is the only trigger. Claude reads it in the skill listing to decide on invocation.

1. [HARD] Not empty, max 1,024 chars, no XML tags, no angle brackets
1. [HARD] CC: `description` + `when_to_use` truncate at 1,536 chars in the listing
1. State what the skill does AND when to use it, with concrete trigger words
1. Write in third person. It enters the system prompt; "I" or "you" hurts discovery
1. Put the key use case first. Truncation cuts the end
1. Name near-misses to exclude when a sibling skill competes
1. House style: start with `MUST use when ...` for rules Claude tends to skip
1. Claude under-triggers. A slightly pushy description ("even if the user does not say X") helps
1. Simple one-step tasks ("read this file") seldom trigger any skill. Do not tune for them

## Cross-surface optional keys

| Key | Rule |
|---|---|
| `license` | Short licence name or bundled licence file |
| `compatibility` | [HARD] 1–500 chars. Only for real environment needs |
| `metadata` | String-to-string map. CC ignores it |
| `allowed-tools` | Spec: space-separated, experimental |

## CC-only keys

| Key | Effect |
|---|---|
| `when_to_use` | Appended to the description in the listing. Trigger phrases and examples |
| `argument-hint` | Autocomplete hint, eg `[issue-number]` |
| `arguments` | Named positional args, enables `$name` |
| `disable-model-invocation: true` | User-only `/name`. Description leaves context. Use for side effects |
| `user-invocable: false` | Hidden from `/` menu. Claude can still invoke it |
| `allowed-tools` | Pre-approves tools for this turn. Does not block others. Eg `Bash(git add *)` |
| `disallowed-tools` | Removes whole tools while active. No wildcards |
| `model` | Model for this turn, or the fork's model. `inherit` keeps the session model |
| `effort` | `low`, `medium`, `high`, `xhigh`, `max` for this turn |
| `context: fork` | Runs in an isolated subagent without chat history |
| `agent` | Subagent type for the fork: `Explore`, `Plan`, `general-purpose` or custom |
| `background: false` | Fork returns in the same turn. Backgrounded forks lose some tools |
| `paths` | Globs that limit auto-invocation. Manual `/name` ignores them |
| `shell` | `bash` (default), `powershell` or `0` |
| `hooks` | Skill-scoped hooks, settings schema. See `runtime.md` |

1. Legacy `commands/*.md` take the same keys except `name` and `paths`
1. `skillOverrides` in settings sets a skill to `on`, `name-only`, `user-invocable-only` or `off`

## Validation checklist

1. `name` regex `^[a-z0-9]+(-[a-z0-9]+)*$` and equal to the folder
1. `grep -ciE 'anthropic|claude'` on `name` returns 0
1. Description length: `awk` or `python3 -c` count ≤1,024
1. No `<` or `>` in the description
1. Every key is in the tables above
