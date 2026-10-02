---
name: napkin
description: "Maintain either a configured global user-level Napkin or the default per-repository Napkin. Read and curate recurring high-value guidance before investigations, keep explicit actions, and avoid chronological session logs."
author: Codex
version: 7.1.0
date: 2026-10-02
---

# Napkin

Napkin supports two mutually exclusive modes:

1. **Global user-level Napkin — used exclusively when configured**
2. **Per-repository Napkin — fallback when global mode is not configured**

## Select the mode

Look for `config.json` beside the installed `SKILL.md`.

Typical locations:

- GitHub Copilot CLI: `~/.copilot/skills/napkin/config.json`
- Claude Code: `~/.claude/skills/napkin/config.json`
- Codex: `~/.codex/skills/napkin/config.json`

Use global mode only when the adjacent file contains:

```json
{
  "mode": "global",
  "napkinPath": "C:\\path\\to\\private\\napkin.md"
}
```

When this configuration is present, read and maintain only `napkinPath`. Do not read, create, or update `<current-repository>\.claude\napkin.md`.

Without that configuration, use per-repository behavior.

## Per-repository fallback

Only when global mode is not configured, read and maintain:

```text
<current-repository>\.claude\napkin.md
```

If it does not exist, create:

```markdown
# Napkin Runbook

## Execution and Validation

## Shell and Tool Reliability

## Domain Behavior Guardrails

## User Directives
```

Per-repository entries use:

```markdown
1. **[YYYY-MM-DD] Short reusable rule**
   Do instead: <concrete repeatable action>
```

The repository owner decides whether `.claude\napkin.md` is committed or ignored.

## Global mode

When explicitly configured, read and maintain only the private file at `napkinPath`.

Before applying global guidance:

1. Resolve the current Git repository and `git remote get-url origin`.
2. For non-repository work, identify a stable service, workflow, or tool origin.
3. Apply entries whose `Scope` is `global`, whose `Origin` matches, or whose workflow/tool scope clearly applies.
4. Never apply a repository-specific entry to an unrelated repository merely because terminology overlaps.

Global entries use:

```markdown
1. **[YYYY-MM-DD] Short reusable rule**
   Scope: `repo` | `origin` | `workflow` | `tool` | `global`
   Origin: <normalized Git origin, repository, service, workflow, or tool>
   Applies when: <short applicability condition>
   Do instead: <concrete repeatable action>
```

Prefer the narrowest correct scope.

Store every qualifying lesson in the global file and use `Scope`, `Origin`, and `Applies when` to prevent repository-specific guidance from leaking into unrelated work.

## What to record

Add or update an entry only when the lesson is verified and likely to recur:

- A query, table, cluster, command, or tool choice that is easy to get wrong.
- A correlation key or identifier transformation.
- A failed approach and the reliable alternative.
- A tool limitation and successful fallback.
- An interpretation rule that prevents false conclusions.
- A repeated user preference or useful route to a specialized runbook.

Do not record:

- Current progress, changing counts, timestamps, or one-time timelines.
- Tenant, connection, user, mailbox, object, or item identifiers.
- Customer content, raw payloads, secrets, credentials, tokens, or sensitive URLs.
- Speculation, unverified conclusions, or verbose postmortems.
- Large procedures already maintained by a canonical skill.

## Curation

- Read and apply the selected Napkin before an investigation or when explicitly asked to use or update it.
- Organize by investigation concern rather than chronology.
- Merge duplicates and remove stale guidance.
- Sort each category by importance.
- Keep at most 10 entries per category in per-repository mode.
- Keep at most 15 entries per category in global mode.
- Require an actionable `Do instead:` line.

## Precedence in global mode

1. Repository instructions and canonical repository skills.
2. Matching global `repo` or `origin` entries.
3. Matching global workflow and tool entries.
4. Global entries.

Narrower scoped guidance always wins.
