# Claude Code runtime

## Arguments

| Token | Value |
|---|---|
| `$ARGUMENTS` | All arguments as typed |
| `$ARGUMENTS[N]`, `$N` | 0-based positional argument |
| `$name` | Named argument from the `arguments` key |

1. Shell-style quoting: multi-word values need quotes
1. Escape a literal `$` as `\$` (eg `\$1.00`)
1. Inserted values are not re-expanded

## Variables

1. `${CLAUDE_SKILL_DIR}`: skill folder. ALWAYS use it for bundled scripts; cwd varies
1. `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`
1. Plugin skills also get `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_PLUGIN_DATA}` (persists across updates)
1. `${CLAUDE_SKILL_DIR}` also works inside `allowed-tools` Bash rules

## Dynamic context

1. `` !`cmd` `` at line start or after whitespace runs before Claude sees the skill. Output replaces it
1. Multi-line form: a fenced block that opens with three backticks then `!`
1. After non-whitespace, `` !`cmd` `` stays literal
1. Timeout 2 minutes. stderr merges into stdout. Output over ~8 KB arrives as a file path plus preview
1. A non-zero exit aborts the whole invocation. Append `|| true` when failure is expected (grep/find/diff exit 1 is allowed)
1. Deny rules abort injection. Outside auto mode, unapproved commands abort too → pre-approve them in `allowed-tools`
1. Synced claude.ai skills never run `!` commands locally

## Lifecycle

1. On invocation, the rendered body enters context once and stays. Claude does not re-read it
1. Compaction keeps the first 5,000 tokens per skill, 25,000 total. Key rules go on top
1. A user can chain up to 6 skills at message start
1. Edits to an existing skill load live. A new top-level skills folder needs `/reload-skills`
1. `Skill(name)` permission rules allow or block a skill
1. A forked skill (`context: fork`) needs explicit task steps. Guidelines alone give the subagent nothing to do
1. Fork edits sit outside checkpoints. `/rewind` cannot undo them

## Locations and priority

1. Highest first: managed (enterprise), personal `~/.claude/skills/`, project `.claude/skills/`, nested, `--add-dir`, plugin, claude.ai
1. Plugin skills are namespaced `/plugin:skill`
1. Nested `.claude/skills/` load on first file edit in that folder
1. In a worktree, project skills load from the worktree root
1. A skill folder can be a symlink

## Hooks in skills

Use a hook when behaviour MUST happen. A skill only advises.

```yaml
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "~/.claude/skills/my-skill/scripts/check.sh"
          once: true
```

1. Use an absolute script path. Docs confirm `${CLAUDE_SKILL_DIR}` only in the body and `allowed-tools`, not in hook commands
1. Schema equals settings hooks: event → matcher → hooks list
1. Hooks register on invocation and stay for the rest of the session
1. `once: true` removes the handler after its first success
1. `Stop` in a skill fires as `Stop`. In a subagent it becomes `SubagentStop`
1. Project-skill hooks follow the workspace-trust rule of settings hooks
1. Skill events: `UserPromptExpansion` (matcher = skill name), `InstructionsLoaded`, `ConfigChange` (matcher `skills`)
