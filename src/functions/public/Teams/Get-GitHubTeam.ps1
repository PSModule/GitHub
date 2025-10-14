function Get-GitHubTeam {
    <#
        .SYNOPSIS
        List teams from an org or get a team by name

        .DESCRIPTION
        Lists all teams in an organization that are visible to the authenticated user or gets a team using the team's slug.
        To create the slug, GitHub replaces special characters in the name string, changes all words to lowercase,
        and replaces spaces with a - separator. For example, "My TEam Näme" would become my-team-name.

        .EXAMPLE
        ```powershell
        Get-GitHubTeam -Organization 'GitHub'
        ```

        Gets all teams in the `github` organization.

        .EXAMPLE
        ```powershell
        Get-GitHubTeam -Organization 'github' -Slug 'my-team-name'
        ```

        Gets the team with the slug 'my-team-name' in the `github` organization.

        .EXAMPLE
        ```powershell
        Get-GitHubTeam -Organization 'github' -Repository 'my-repo'
        ```

        Lists all teams that have access to the 'my-repo' repository owned by `github`.

        .LINK
        https://psmodule.io/GitHub/Functions/Teams/Get-GitHubTeam
    #>
    [OutputType([GitHubTeam])]
    [CmdletBinding(DefaultParameterSetName = 'List all teams in an organization')]
    param(
        # The organization name. The name is not case sensitive.
        # If not provided, the owner from the context will be used.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'List all teams with access to a repository')]
        [string] $Repository,

        # The slug of the team name.
        [Parameter(Mandatory, ParameterSetName = 'Get a specific team by slug')]
        [string] $Slug,

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
        $params = @{
            Organization = $Organization
            Context      = $Context
        }
        switch ($PSCmdlet.ParameterSetName) {
            'Get a specific team by slug' {
                Get-GitHubTeamBySlug @params -Slug $Slug
            }
            'List all teams with access to a repository' {
                Get-GitHubTeamListByRepo @params -Repository $Repository
            }
            default {
                Get-GitHubTeamListByOrg @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
