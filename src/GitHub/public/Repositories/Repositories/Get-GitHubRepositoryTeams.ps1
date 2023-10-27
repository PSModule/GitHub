filter Get-GitHubRepositoryTeams {
    <#
        .SYNOPSIS
        List repository teams

        .DESCRIPTION
        Lists the teams that have access to the specified repository and that are also visible to the authenticated user.

        For a public repository, a team is listed only if that team added the public repository explicitly.

        Personal access tokens require the following scopes:
        * `public_repo` to call this endpoint on a public repository
        * `repo` to call this endpoint on a private repository (this scope also includes public repositories)

        This endpoint is not compatible with fine-grained personal access tokens.

        .EXAMPLE
        Get-GitHubRepositoryTeams -Owner 'PSModule' -Repo 'GitHub'

        Lists the teams that have access to the specified repository and that are also visible to the authenticated user.

        .NOTES
        https://docs.github.com/rest/repos/repos#list-repository-teams

    #>
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'Owner', 'Repo' -RemoveTypes 'SwitchParameter'

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/teams"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
