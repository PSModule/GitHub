<#
    .SYNOPSIS
        Idempotent get-or-create helpers for the shared run-scoped test repositories.

    .DESCRIPTION
        The integration test suite uses a small set of GitHub repositories whose names are
        scoped to the current `GITHUB_RUN_ID` and shared across the leaf jobs in the
        `Test-ModuleLocal` matrix. Any leaf job that depends on these repositories calls
        the helpers in this file from its `BeforeAll` block to ensure the repositories
        are present before the tests execute.

        The helpers are declarative: they fetch the repository if it already exists and
        create it if it does not. This keeps test setup independent of the order in which
        jobs run, makes individual tests safe to execute in isolation, and lets the
        suite recover when shared infrastructure is missing for any reason.

        Naming and scope are owned by the caller. The helpers do not list, rename, or
        delete repositories, and they do not widen ownership beyond the names they are
        given.

    .NOTES
        Functions:
        - Initialize-SharedTestRepository       Primary `Test-{OS}-{TokenType}-{RunID}` repository, initialized with a readme, license, and gitignore so a default branch with content is available.
        - Initialize-SharedTestRepositoryExtras Companion `-2` and `-3` repositories used by organization-scoped Secrets/Variables `SelectedRepository` tests.
#>

function Initialize-SharedTestRepository {
    <#
        .SYNOPSIS
            Returns the named shared test repository, creating it if it does not exist.

        .DESCRIPTION
            Looks up the repository by name in the given owner scope and returns it if
            found. If it is not found, creates it with a readme, MIT license, and
            VisualStudio gitignore so release-related tests have a default branch with
            content to operate on. If creation races with a parallel caller, the
            repository is re-fetched and returned.
    #>
    [CmdletBinding()]
    [OutputType([object])]
    param(
        # Login of the user or organization that owns the repository.
        [Parameter(Mandatory)]
        [string] $Owner,

        # Whether $Owner is a user account or an organization. Determines which
        # Get-/New-GitHubRepository parameter set is used.
        [Parameter(Mandatory)]
        [ValidateSet('user', 'organization')]
        [string] $OwnerType,

        # Repository name within the owner scope.
        [Parameter(Mandatory)]
        [string] $Name
    )

    $repo = switch ($OwnerType) {
        'user' { Get-GitHubRepository -Name $Name -ErrorAction SilentlyContinue }
        'organization' { Get-GitHubRepository -Owner $Owner -Name $Name -ErrorAction SilentlyContinue }
    }

    if ($repo) {
        return $repo
    }

    Write-Host "Provisioning shared test repository '$Owner/$Name' ($OwnerType)."

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
        # A parallel caller may have created the repository between the lookup above
        # and this create call. Re-fetch and treat the existing repository as success.
        Write-Host "Create attempt for '$Name' failed ($($_.Exception.Message)). Re-fetching in case a parallel caller created it."
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
    <#
        .SYNOPSIS
            Returns the `-2` and `-3` companion repositories for an organization-scoped base name, creating any that are missing.

        .DESCRIPTION
            Some Secrets and Variables tests exercise `SelectedRepositories` visibility,
            which requires more than one repository in the same organization. This helper
            ensures the two companion repositories exist alongside the primary shared
            repository and returns them in `-2`, `-3` order.
    #>
    [CmdletBinding()]
    [OutputType([object[]])]
    param(
        # Organization that owns the companion repositories.
        [Parameter(Mandatory)]
        [string] $Owner,

        # Name of the primary shared repository. Companions are derived as
        # "$BaseName-2" and "$BaseName-3".
        [Parameter(Mandatory)]
        [string] $BaseName
    )

    $extras = @()
    foreach ($suffix in 2, 3) {
        $extraName = "$BaseName-$suffix"
        $extra = Get-GitHubRepository -Owner $Owner -Name $extraName -ErrorAction SilentlyContinue
        if (-not $extra) {
            Write-Host "Provisioning shared test repository '$Owner/$extraName'."
            try {
                $extra = New-GitHubRepository -Organization $Owner -Name $extraName
            } catch {
                Write-Host "Create attempt for '$extraName' failed ($($_.Exception.Message)). Re-fetching in case a parallel caller created it."
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
