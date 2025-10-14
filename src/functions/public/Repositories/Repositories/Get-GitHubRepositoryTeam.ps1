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
        ```powershell
        Get-GitHubRepositoryTeam -Owner 'PSModule' -Name 'GitHub'
        ```

        Lists the teams that have access to the specified repository and that are also visible to the authenticated user.

        .NOTES
        [List repository teams](https://docs.github.com/rest/repos/repos#list-repository-teams)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Repositories/Get-GitHubRepositoryTeam
    #>
    [CmdletBinding()]
    [Alias('Get-GitHubRepositoryTeams')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Name,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Name/teams"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
