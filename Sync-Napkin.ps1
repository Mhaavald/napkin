[CmdletBinding()]
param(
    [string]$RepositoryRoot = $PSScriptRoot,
    [string]$Branch = 'main'
)

$ErrorActionPreference = 'Stop'

$relativeNapkinPath = 'napkin.md'
$napkinPath = Join-Path $RepositoryRoot $relativeNapkinPath

if (-not (Test-Path $napkinPath))
{
    throw "Napkin file was not found at $napkinPath."
}

$content = Get-Content $napkinPath -Raw
$blockedPatterns = [ordered]@{
    'email or UPN' = '(?i)\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b'
    'GUID identifier' = '(?i)\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b'
    'bearer credential' = '(?i)\bBearer\s+[A-Za-z0-9._~+/=-]{12,}'
    'GitHub token' = '(?i)\b(gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,})\b'
    'AWS access key' = '\b(AKIA|ASIA)[A-Z0-9]{16}\b'
    'private key block' = '-----BEGIN [A-Z ]*PRIVATE KEY-----'
    'connection string credential' = '(?i)\b(AccountKey|SharedAccessSignature|ClientSecret|Password)\s*=\s*[^;\s]+'
    'SAS signature parameter' = '(?i)[?&]sig=[A-Za-z0-9%+/=_-]{12,}'
    'secret assignment' = '(?i)\b(password|secret|access[_-]?token|refresh[_-]?token)\s*[:=]\s*\S+'
}

$violations = foreach ($entry in $blockedPatterns.GetEnumerator())
{
    if ($content -match $entry.Value)
    {
        $entry.Key
    }
}

if ($violations)
{
    throw "Napkin sync blocked by sensitive-data validation: $($violations -join ', ')."
}

Push-Location $RepositoryRoot
try
{
    & git check-ignore --quiet -- $relativeNapkinPath
    if ($LASTEXITCODE -eq 0)
    {
        Write-Output 'napkin.md is ignored and remains local-only; no Git synchronization was attempted.'
        return
    }

    & git fetch --quiet origin $Branch
    if ($LASTEXITCODE -ne 0)
    {
        throw 'Failed to fetch the Napkin repository.'
    }

    $behind = [int](& git rev-list --count "HEAD..origin/$Branch")
    if ($LASTEXITCODE -ne 0)
    {
        throw 'Failed to determine whether the Napkin repository is behind its remote.'
    }

    if ($behind -gt 0)
    {
        $otherChanges = @(
            & git status --porcelain |
                Where-Object { $_ -notmatch [regex]::Escape($relativeNapkinPath) }
        )

        if ($otherChanges.Count -gt 0)
        {
            throw 'Remote updates are available, but unrelated local changes prevent a safe fast-forward.'
        }

        & git merge --ff-only "origin/$Branch"
        if ($LASTEXITCODE -ne 0)
        {
            throw 'Failed to fast-forward the Napkin repository.'
        }
    }

    & git diff --quiet -- $relativeNapkinPath
    $hasTrackedChanges = $LASTEXITCODE -ne 0
    & git diff --cached --quiet -- $relativeNapkinPath
    $hasStagedChanges = $LASTEXITCODE -ne 0
    $isUntracked = @(& git ls-files --others --exclude-standard -- $relativeNapkinPath).Count -gt 0

    if (-not $hasTrackedChanges -and -not $hasStagedChanges -and -not $isUntracked)
    {
        Write-Output 'Napkin is already synchronized.'
        return
    }

    & git add -- $relativeNapkinPath
    if ($LASTEXITCODE -ne 0)
    {
        throw 'Failed to stage the Napkin.'
    }

    $date = Get-Date -Format 'yyyy-MM-dd'
    & git commit --only -m "docs(napkin): sync investigation notes $date" -- $relativeNapkinPath
    if ($LASTEXITCODE -ne 0)
    {
        throw 'Failed to commit the Napkin.'
    }

    & git push origin "HEAD:$Branch"
    if ($LASTEXITCODE -ne 0)
    {
        throw 'Failed to push the Napkin commit.'
    }

    Write-Output 'Napkin committed and pushed successfully.'
}
finally
{
    Pop-Location
}
