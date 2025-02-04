function Get-GitHubRESTTeam {
    <#
        .SYNOPSIS
        List teams from an org or get a team by name

        .DESCRIPTION
        Lists all teams in an organization that are visible to the authenticated user or gets a team using the team's slug.
        To create the slug, GitHub replaces special characters in the name string, changes all words to lowercase,
        and replaces spaces with a - separator. For example, "My TEam Näme" would become my-team-name.

        .EXAMPLE
        Get-GitHubRESTTeam -Organization 'GitHub'

        Gets all teams in the `github` organization.

        .EXAMPLE
        Get-GitHubRESTTeam -Organization 'github' -Name 'my-team-name'

        Gets the team with the slug 'my-team-name' in the `github` organization.

        .NOTES
        [List teams](https://docs.github.com/rest/teams/teams#list-teams)
        [Get team by name](https://docs.github.com/en/rest/teams/teams#get-a-team-by-name)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The organization name. The name is not case sensitive.
        # If not provided, the organization from the context is used.
        [Parameter(Mandatory)]
        [string] $Organization,

        # The slug of the team name.
        [Parameter(
            Mandatory,
            ParameterSetName = 'GetByName'
        )]
        [Alias('Team', 'TeamName', 'slug', 'team_slug')]
        [string] $Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $params = @{
            Organization = $Organization
            Context      = $Context
        }
        switch ($PSCmdlet.ParameterSetName) {
            'GetByName' {
                Get-GitHubRESTTeamByName @params -Name $Name
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
