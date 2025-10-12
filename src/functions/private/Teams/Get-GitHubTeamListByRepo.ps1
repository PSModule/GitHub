filter Get-GitHubTeamListByRepo {
    <#
        .SYNOPSIS
        List repository teams.

        .DESCRIPTION
        Lists the teams that have access to the specified repository and that are also visible to the authenticated user.
        For a public repository, a team is listed only if that team added the public repository explicitly.
        OAuth app tokens and personal access tokens (classic) need the public_repo or repo scope to use this endpoint with a public repository,
        and repo scope to use this endpoint with a private repository.

        .EXAMPLE
        ```powershell
        Get-GitHubTeamListByRepo -Owner 'octocat' -Repository 'Hello-World'
        ```

        Output:
        ```powershell

        ```

        Lists all teams that have access to the 'Hello-World' repository owned by 'octocat'.

        .OUTPUTS
        GitHubTeam[]

        .NOTES
        [List repository teams](https://docs.github.com/rest/repos/repos#list-repository-teams)
    #>
    [OutputType([GitHubTeam[]])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

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
            APIEndpoint = "/repos/$Owner/$Repository/teams"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            foreach ($team in $_.Response) {
                [GitHubTeam]::new($team, $Organization)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
