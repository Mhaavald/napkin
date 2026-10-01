---
name: napkin
description: "Maintain the default per-repository Napkin and optionally a configured global user-level Napkin. Read and curate recurring high-value guidance before work, keep explicit actions, and avoid chronological session logs."
author: Codex
version: 7.0.0
date: 2026-10-01
---

# Napkin

Napkin supports:

1. **Per-repository Napkin — always the default**
2. **Global user-level Napkin — optional and additive**

## Detect the optional global extension

Look for `config.json` beside the installed `SKILL.md`.

Typical locations:

- GitHub Copilot CLI: `~/.copilot/skills/napkin/config.json`
- Claude Code: `~/.claude/skills/napkin/config.json`
- Codex: `~/.codex/skills/napkin/config.json`

Enable the global extension only when the adjacent file contains:

```json
{
  "mode": "global",
  "napkinPath": "C:\\path\\to\\private\\napkin.md"
}
```

Without that configuration, use only per-repository behavior.

## Default per-repository mode

Always read and maintain:

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

## Optional global extension

When explicitly configured, read both:

1. The current repository's `.claude\napkin.md`.
2. The private file at `napkinPath`.

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

Store repository-specific lessons in `.claude\napkin.md`. Store lessons that genuinely cross repositories, workflows, services, or tools in the global file.

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

- Read and apply the selected Napkin before work.
- Organize by investigation concern rather than chronology.
- Merge duplicates and remove stale guidance.
- Sort each category by importance.
- Keep at most 10 entries per category in per-repository mode.
- Keep at most 15 entries per category in global mode.
- Require an actionable `Do instead:` line.

## Precedence when the global extension is enabled

1. Repository instructions and canonical repository skills.
2. Per-repository `.claude\napkin.md`.
3. Matching global `repo` or `origin` entries.
4. Matching global workflow and tool entries.
5. Global entries.

Narrower repository guidance always wins.
