filter Get-GitHubRepositoryTeam {
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
        Get-GitHubRepositoryTeam -Owner 'PSModule' -Repo 'GitHub'

        Lists the teams that have access to the specified repository and that are also visible to the authenticated user.

        .NOTES
        [List repository teams](https://docs.github.com/rest/repos/repos#list-repository-teams)

    #>
    [CmdletBinding()]
    [Alias('Get-GitHubRepositoryTeams')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $contextObj = Get-GitHubContext -Context $Context
    if (-not $contextObj) {
        throw 'Log in using Connect-GitHub before running this command.'
    }
    Write-Debug "Context: [$Context]"

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $contextObj.Owner
    }
    Write-Debug "Owner : [$($contextObj.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $contextObj.Repo
    }
    Write-Debug "Repo : [$($contextObj.Repo)]"

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo/teams"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
