function Get-GitHubTeamBySlug {
    <#
        .SYNOPSIS
        Get a team by name

        .DESCRIPTION
        Gets a team using the team's slug. To create the slug, GitHub replaces special characters in the name string, changes all words to lowercase,
        and replaces spaces with a - separator. For example, "My TEam Näme" would become my-team-name.

        .EXAMPLE
        Get-GitHubTeamBySlug -Organization 'github' -Slug 'my-team-name'

        .NOTES
        [Get a team by name](https://docs.github.com/rest/teams/teams#get-a-team-by-name)
    #>
    [OutputType([GitHubTeam])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        # If not provided, the owner from the context will be used.
        [Parameter(Mandatory)]
        [string] $Organization,

        # The slug of the team name.
        [Parameter(Mandatory)]
        [string] $Slug,

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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Organization/teams/$Name"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubTeam]::new($_.Response, $Organization)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
