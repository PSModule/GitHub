# Idempotent get-or-create helpers for the shared run-scoped test repositories.
#
# Background
# ----------
# `tests/BeforeAll.ps1` provisions one repository per (OS, TokenType, RunID) for the
# happy-path workflow run. Several *.Tests.ps1 files then read that repository via
# their per-context `BeforeAll`. Before this helper existed, each test file simply
# threw if the repository was missing, which broke the GitHub Actions
# **Re-run failed jobs** path: `AfterAll-ModuleLocal` deletes the shared repository
# at the end of every attempt, and a partial rerun does not re-execute the
# successful `BeforeAll-ModuleLocal` job, so the leaf jobs landed on a non-existent
# repository (issue #590).
#
# These helpers move ownership of "ensure the shared repository exists" from a
# fragile precondition-check into a declarative get-or-create that any leaf job
# can call. On the happy path the repositories already exist (created by
# `BeforeAll.ps1`) and the helpers are a single `Get-GitHubRepository` call. On a
# partial rerun where the repositories were torn down, the helpers recreate them
# transparently so the leaf job can proceed.
#
# Functions defined here:
# - Initialize-SharedTestRepository       primary `Test-{OS}-{TokenType}-{RunID}` repository (with readme/license/gitignore for release tests)
# - Initialize-SharedTestRepositoryExtras org-only `-2` and `-3` companion repositories used by Secrets/Variables tests

function Initialize-SharedTestRepository {
    [CmdletBinding()]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)]
        [string] $Owner,

        [Parameter(Mandatory)]
        [ValidateSet('user', 'organization')]
        [string] $OwnerType,

        [Parameter(Mandatory)]
        [string] $Name
    )

    $repo = switch ($OwnerType) {
        'user' {
            Get-GitHubRepository -Name $Name -ErrorAction SilentlyContinue
        }
        'organization' {
            Get-GitHubRepository -Owner $Owner -Name $Name -ErrorAction SilentlyContinue
        }
    }

    if ($repo) {
        return $repo
    }

    Write-Host "Shared test repository '$Name' not found for owner '$Owner' ($OwnerType). Creating it now (self-heal path for partial reruns / issue #590)."

    # The primary shared repository is initialized with readme/license/gitignore so
    # release tests have a default branch with content available for tag operations.
    $createParams = @{
        Name      = $Name
        AddReadme = $true
        License   = 'mit'
        Gitignore = 'VisualStudio'
    }

    try {
        $repo = switch ($OwnerType) {
            'user' { New-GitHubRepository @createParams }
            'organization' { New-GitHubRepository @createParams -Organization $Owner }
        }
    } catch {
        # Another leaf job in the same matrix may have created the repository
        # between our Get and our New. Re-fetch to recover from that race.
        Write-Host "Create attempt for '$Name' failed ($($_.Exception.Message)). Re-fetching in case a parallel job created it."
        $repo = switch ($OwnerType) {
            'user' { Get-GitHubRepository -Name $Name -ErrorAction SilentlyContinue }
            'organization' { Get-GitHubRepository -Owner $Owner -Name $Name -ErrorAction SilentlyContinue }
        }
        if (-not $repo) {
            throw
        }
    }

    return $repo
}

function Initialize-SharedTestRepositoryExtras {
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        [Parameter(Mandatory)]
        [string] $Owner,

        [Parameter(Mandatory)]
        [string] $BaseName
    )

    # Extras are only used for organization-scoped Secrets/Variables SelectedRepository tests.
    $extras = @()
    foreach ($suffix in 2, 3) {
        $extraName = "$BaseName-$suffix"
        $extra = Get-GitHubRepository -Owner $Owner -Name $extraName -ErrorAction SilentlyContinue
        if (-not $extra) {
            Write-Host "Shared extra test repository '$extraName' not found for owner '$Owner'. Creating it now (self-heal path for partial reruns / issue #590)."
            try {
                $extra = New-GitHubRepository -Organization $Owner -Name $extraName
            } catch {
                Write-Host "Create attempt for '$extraName' failed ($($_.Exception.Message)). Re-fetching in case a parallel job created it."
                $extra = Get-GitHubRepository -Owner $Owner -Name $extraName -ErrorAction SilentlyContinue
                if (-not $extra) {
                    throw
                }
            }
        }
        $extras += $extra
    }

    return $extras
}
