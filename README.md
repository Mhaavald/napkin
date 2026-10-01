# Napkin

A persistent, curated runbook that helps an AI agent reuse what worked and avoid mistakes it has already encountered.

## Modes at a glance

Napkin has two usage modes:

| Mode | Status | Notes location | Best for |
|---|---|---|---|
| **Per-repository** | **Default** | `<current-repo>\.claude\napkin.md` | Guidance owned by one codebase and optionally shared with its contributors |
| **Global user-level** | Optional addition | A configured `napkin.md` in a separate private personal repository | Lessons spanning repositories, services, tools, and operational workflows |

If no global configuration is present, Napkin always uses the original **per-repository mode**.

The optional global mode extends the original [Aanerud/napkin](https://github.com/Aanerud/napkin) project while preserving its MIT license and default behavior.

---

# Default: per-repository Napkin

The original Napkin model is the default.

Each repository has its own:

```text
<repository>\.claude\napkin.md
```

## How the default mode works

1. At the start of work, the agent reads `.claude\napkin.md` from the current repository.
2. It silently applies relevant guidance.
3. During work, it adds verified recurring lessons, corrections, reliable methods, and repository-specific preferences.
4. It continuously curates the file by merging duplicates and removing stale guidance.

No configuration file is required.

## Install the default mode

### Claude Code

```powershell
git clone https://github.com/Aanerud/napkin.git `
  "$HOME\.claude\skills\napkin"
```

### Codex

```powershell
git clone https://github.com/Aanerud/napkin.git `
  "$HOME\.codex\skills\napkin"
```

### GitHub Copilot CLI

```powershell
$skillRoot = "$HOME\.copilot\skills\napkin"
New-Item -ItemType Directory -Force $skillRoot | Out-Null
Copy-Item ".\SKILL.md" "$skillRoot\SKILL.md" -Force
```

Do not create `config.json` when you want the default per-repository behavior.

## Per-repository template

When no file exists, Napkin creates:

```markdown
# Napkin Runbook

## Execution and Validation

## Shell and Tool Reliability

## Domain Behavior Guardrails

## User Directives
```

Each entry uses:

```markdown
1. **[YYYY-MM-DD] Short reusable rule**
   Do instead: <concrete repeatable action>
```

## Sharing per-repository notes

Choose one:

- Commit `.claude\napkin.md` when its guidance should be shared with every contributor.
- Add it to `.gitignore` when it should remain personal to one developer.

Do not put secrets, credentials, customer content, personal data, or temporary incident details in either form.

---

# Optional: global user-level Napkin

Global mode is an additional possibility for users whose work spans repositories and operational systems.

It does **not** replace or disable the per-repository model. It is enabled explicitly through a user-level `config.json`; when enabled, the agent reads both the current repository Napkin and the global Napkin.

## Global-mode architecture

Global mode separates reusable implementation from personal notes:

| Repository | Visibility | Contents |
|---|---|---|
| Existing Napkin project | Public/shared | `SKILL.md`, documentation, templates, and optional synchronization tooling |
| Personal Napkin notes | Private | The user's populated global `napkin.md` and its Git history |

Personal notes must not be placed in the public/shared Napkin project.

## Global entry format

Every global note declares where it applies:

```markdown
1. **[YYYY-MM-DD] Short reusable rule**
   Scope: `repo` | `origin` | `workflow` | `tool` | `global`
   Origin: `<Git remote, repository, service, workflow, or tool>`
   Applies when: <short applicability condition>
   Do instead: <concrete repeatable action>
```

### Global scope meanings

- `repo`: applies only to one repository.
- `origin`: applies to repositories or work sharing the same remote or service origin.
- `workflow`: applies to a named workflow across repositories.
- `tool`: applies whenever a named tool or telemetry source is used.
- `global`: safe regardless of repository.

Prefer the narrowest correct scope.

## Enable global mode

The examples use:

```text
C:\Users\<user>\source\repos\napkin
C:\Users\<user>\source\repos\napkin-notes
```

### 1. Clone the existing Napkin implementation

```powershell
git clone https://github.com/Aanerud/napkin.git `
  "$HOME\source\repos\napkin"
```

This is the existing Napkin project with the optional global-mode implementation.

### 2. Prepare a private personal notes repository

Create or clone a private repository used only for personal Napkin data:

```powershell
$notesRoot = "$HOME\source\repos\napkin-notes"
git clone git@github-personal:<account>/napkin-notes.git $notesRoot
```

Seed a new private notes repository from the templates:

```powershell
$skillRepo = "$HOME\source\repos\napkin"

Copy-Item "$skillRepo\napkin.example.md" "$notesRoot\napkin.md"
Copy-Item "$skillRepo\Sync-Napkin.ps1" "$notesRoot\Sync-Napkin.ps1"
```

### 3. Install the skill and enable global mode

```powershell
$skillRoot = "$HOME\.copilot\skills\napkin"
$skillRepo = "$HOME\source\repos\napkin"
$notesRoot = "$HOME\source\repos\napkin-notes"

New-Item -ItemType Directory -Force $skillRoot | Out-Null
Copy-Item "$skillRepo\SKILL.md" "$skillRoot\SKILL.md" -Force

@{
    mode = 'global'
    napkinPath = "$notesRoot\napkin.md"
} | ConvertTo-Json |
    Set-Content "$skillRoot\config.json"
```

Start a new session after installation so the skill is rediscovered.

Place `config.json` beside the installed `SKILL.md`. Typical skill directories are:

- GitHub Copilot CLI: `~/.copilot/skills/napkin`
- Claude Code: `~/.claude/skills/napkin`
- Codex: `~/.codex/skills/napkin`

The global extension is active only when `config.json` contains:

```json
{
  "mode": "global",
  "napkinPath": "C:\\Users\\<user>\\source\\repos\\napkin-notes\\napkin.md"
}
```

Removing `config.json`, or changing `mode` to `per-repo`, disables only the global extension. The default per-repository behavior remains active.

## Verify global mode

Ask:

```text
Read my global Napkin and tell me which entries apply to the current repository.
```

The skill should:

1. Read the user-level configuration.
2. Read the current repository's `.claude\napkin.md`.
3. Confirm that `mode` is `global`.
4. Resolve the current repository and Git origin.
5. Read the configured private `napkin.md`.
6. Apply repository guidance first, then matching global repository/origin entries, relevant workflow/tool entries, and safe global entries.

## Persist global notes

Run the synchronization script from the private notes repository:

```powershell
& "$HOME\source\repos\napkin-notes\Sync-Napkin.ps1"
```

The script:

1. Checks `napkin.md` for common identifier and credential patterns. This is defense in depth, not a complete secret scanner.
2. Fetches the private notes remote.
3. Fast-forwards when safe.
4. Commits only `napkin.md` when it changed, even if another file was already staged.
5. Pushes the update.

### Optional daily Windows synchronization

```powershell
$script = "$HOME\source\repos\napkin-notes\Sync-Napkin.ps1"
$action = New-ScheduledTaskAction `
    -Execute (Get-Command pwsh.exe).Source `
    -Argument "-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$script`""
$trigger = New-ScheduledTaskTrigger -Daily -At '18:00'
$settings = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 15) `
    -MultipleInstances IgnoreNew

Register-ScheduledTask `
    -TaskName 'Investigation Napkin Daily Sync' `
    -Description 'Validate, commit, and push sanitized personal Napkin notes.' `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Force
```

## Multiple machines

On each machine:

1. Install the Napkin skill.
2. Clone the private notes repository.
3. Create a machine-local `config.json` pointing to that clone.
4. Pull before editing or run the synchronization script.

Machine-specific paths remain outside the shared implementation.

---

# Choosing a mode

Use **per-repository mode** when:

- Guidance is specific to one codebase.
- The repository team should share the same runbook.
- Repository ownership and review should govern the notes.

Use **global mode** when:

- Lessons apply across multiple repositories.
- Investigations span services, telemetry systems, or tools.
- Notes are personal and should not be committed to product repositories.
- The user wants one private Git history across machines.

If both forms exist, apply them in this order:

1. Repository instructions and canonical repository skills.
2. The current repository's `.claude\napkin.md`.
3. Matching `repo` or `origin` entries from the global Napkin.
4. Matching workflow and tool entries.
5. Global entries.

Repository-specific guidance always wins over broader global guidance.

---

# Curation and safety

Both modes should record only verified, reusable lessons:

- Correct tool, table, cluster, or command choices.
- Non-obvious correlation keys or identifier transformations.
- Failed approaches and reliable alternatives.
- Interpretation rules preventing false conclusions.
- User preferences that repeatedly affect execution.

Do not record:

- Current progress, changing counts, or one-time timelines.
- Tenant, connection, user, mailbox, object, or item identifiers.
- Customer content or raw payloads.
- Secrets, credentials, tokens, or sensitive URLs.
- Speculation or unverified conclusions.

Keep entries concise, actionable, and curated.

# License

MIT
