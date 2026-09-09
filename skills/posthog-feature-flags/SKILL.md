---
name: posthog-feature-flags
description: >-
  Add PostHog feature flags to gate new functionality. Use after implementing
  features or reviewing PRs to ensure safe rollouts with feature flag controls.
metadata:
  author: PostHog
  version: 1.9.4
---

# Add PostHog feature flags

Use this skill to add PostHog feature flags that gate new or changed functionality. Use it after implementing features or reviewing PRs to ensure safe rollouts with feature flag controls. Assumes the PostHog SDK is already installed and initialised.

Supported platforms: React, Next.js (client and server), Python, and the REST API.

## Instructions

Follow these steps IN ORDER:

STEP 1: Locate where the flag will be checked.
  - Determine which part of the stack gates the feature: React or Next.js client, Next.js server (app or pages router), or Python.
  - Confirm PostHog is already initialised there (`posthog-js`, `posthog-node`, or `posthog`), and find the env vars it reads for the project key and host.

STEP 2: Research flag evaluation.
  2.1. Find the reference file below that matches the detected platform — it is the source of truth for flag evaluation methods and framework-specific patterns. Read it now.
  2.2. If no reference matches, fall back to your general knowledge and web search. Use posthog.com/docs as the primary search source.

STEP 3: Create or find the feature flag.
  - Check if a PostHog MCP server is connected. If available, use its tools to search for an existing feature flag the user wants to instrument, or create a new one.
  - If no MCP server is available, instruct the user to create the flag in the PostHog dashboard.

STEP 4: Plan release conditions.
  - Determine the rollout strategy (percentage rollout, user targeting, group targeting, etc.).
  - Plan how the feature flag will gate the new functionality in code.

STEP 5: Instrument the feature.
  - Add the feature flag code following the platform-specific reference patterns.
  - Use server-side evaluation when possible to avoid UI flicker.
  - Do not alter the fundamental architecture of existing files. Make additions minimal and targeted.
  - You must read a file immediately before attempting to write it.

## Reference files

- `references/adding-feature-flag-code.md` - Adding feature flag code - docs
- `references/next-js.md` - Next.js feature flags - docs
- `references/best-practices.md` - Feature flag best practices - docs

`adding-feature-flag-code.md` is the source of truth for flag evaluation, with a section per platform: Web (`posthog-js`), React, Node.js, Python, and the REST API. `next-js.md` adds the Next.js-specific client and server patterns. If something is not covered, fall back to posthog.com/docs.

## Key principles

- **Environment variables**: Always use environment variables for PostHog keys. Never hardcode them.
- **Minimal changes**: Add feature flag code alongside existing logic. Don't replace or restructure existing code.
- **Boolean flags first**: Default to boolean flag checks unless the user specifically asks for multivariate flags.
- **Server-side when possible**: Prefer server-side flag evaluation to avoid UI flicker.

## Trimmed official skill

1. Deleted platforms: react-native, php, ruby, go, java, rust, dotnet, elixir, android, ios, flutter
1. Deleted other: per-platform-skill-dirs, plugin-manifest, readme, page-footers, next-js-analytics
1. Deleted setup: install-commands, sdk-init, env-var-provisioning, package-manager-detection, send-events, experiments, next-steps
1. Deleted redundant refs: react, web, nodejs, python, api — all superseded by adding-feature-flag-code
1. Note you can install the missing bits when needed
