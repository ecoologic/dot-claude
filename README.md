# Dot Claude

This is `~/.claude` under version control, so skills, commands, output styles and global rules sync across machines. Claude Code also writes its runtime state (sessions, caches, history) into this folder; that state is untracked.

## Layout

1. `CLAUDE.md`: global rules, loaded in every Claude Code session on this machine
1. `.claude/CLAUDE.md`: rules for editing this repository only
1. `commands/`: slash commands, invoked by name (eg: `/wt`)
1. `skills/`: standing rules, auto-applied when their description matches the task
1. `output-styles/`: selectable writing styles
1. `old/`: retired commands kept for reference, not loaded
