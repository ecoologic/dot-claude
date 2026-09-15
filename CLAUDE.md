# All AI agents general rules

1. ABOVE ALL: LIMIT ASSUMPTIONS: If you can't avoid it, say it
1. ALWAYS keep the scope to the bare minimum the user _asked_, limit your answers to strictly and only what is asked; offer to expand on topics instead
1. Read CONTEXT.md in the root of the project
1. Fix all typos, the user can misspell, you can't
1. For coding: Apply the `coding` skill; when calling subagents for coding tasks, explicitly add its text to the subagents prompt
1. When working on a 3rd party integration (eg: posthog), check if there's a skill installed for that
1. When efficient, spin up subagents to answer your questions

## Plan mode

1. ALWAYS print the plan path just before EOM: `Plan <"(empty)" if empty/not created>: full/path`
