filter Get-GitHubRepositoryListByTeam {
    <#
        .SYNOPSIS
        List team repositories.

        .DESCRIPTION
        Lists a team's repositories visible to the authenticated user.

        .EXAMPLE
        ```powershell
        Get-GitHubRepositoryListByTeam -Owner 'octocat' -Team 'core'
        ```

        Output:
        ```powershell
        ```

        Lists all repositories that the 'core' team has access to in the organization owned by 'octocat'.

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRepository

        .NOTES
        [List team repositories](https://docs.github.com/rest/teams/teams#list-team-repositories)
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The slug of the team to add or update repository permissions for.
        [Parameter(Mandatory)]
        [Alias('Slug', 'TeamSlug')]
        [string] $Team,

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
            APIEndpoint = "/orgs/$Owner/teams/$Team/repos"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            foreach ($repo in $_.Response) {
                [GitHubRepository]::new($repo)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
