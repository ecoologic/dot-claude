# Security and distribution

## Security

1. Audit every bundled file before install or share: `SKILL.md`, references, scripts
1. Flag network calls, odd file access, and text that hides actions or overrides safety rules
1. A skill that fetches external URLs is a risk. Fetched text can carry instructions
1. NEVER hard-code credentials. Use environment variables or a credential store
1. NEVER write a skill whose purpose would surprise the user if described plainly
1. The author does not review their own shared skill. Another reviewer does
1. `~/.claude` is a public repo. NEVER put secrets or internal URLs in a skill there

## Share scope

| Scope | Where | Who gets it |
|---|---|---|
| Personal | `~/.claude/skills/` | You, every project |
| Project | `<repo>/.claude/skills/` | Everyone who clones the repo |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Everyone who installs the plugin |
| Managed | Managed settings `.claude/skills/` | Whole org, top priority |

1. A standalone skill suffices for personal or project use
1. Use a plugin to ship several skills, agents, hooks or MCP servers as one versioned unit
1. Skills do not sync across claude.ai, the API and Claude Code. Git is the source of truth

## Plugin packaging

```
my-plugin/
├── .claude-plugin/plugin.json
└── skills/<name>/SKILL.md
```

1. Manifest at `.claude-plugin/plugin.json`
1. A marketplace is `.claude-plugin/marketplace.json` that lists plugins
1. Test locally with `claude --plugin-dir ./my-plugin`, no marketplace
1. Install scopes: user, project (committed `.claude/settings.json`), local
1. A plugin-root skill (`my-plugin/SKILL.md`) MUST set `name`
1. Every enabled plugin skill costs description tokens each session, used or not
1. `/reload-plugins` picks up plugin changes

## Context budget

1. The skill listing gets ~1 % of the context window
1. Overflow drops descriptions of least-used skills first
1. Free budget: set low-value skills to `"name-only"` in `skillOverrides`
1. `/doctor` shows the listing cost

## Lifecycle at scale

1. Record per shared skill: purpose, owner, version, dependencies, eval status
1. Start narrow. Merge skills only when evals show equal results
1. Re-run evals after model updates. Fix or retire failing skills
