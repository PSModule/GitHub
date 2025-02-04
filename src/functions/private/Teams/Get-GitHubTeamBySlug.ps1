function Get-GitHubTeamBySlug {
    <#
        .SYNOPSIS
        Get a team by name

        .DESCRIPTION
        Gets a team using the team's slug. To create the slug, GitHub replaces special characters in the name string, changes all words to lowercase,
        and replaces spaces with a - separator. For example, "My TEam Näme" would become my-team-name.

        .EXAMPLE
        Get-GitHubTeamBySlug -Organization 'github' -Slug 'my-team-name'
    #>
    [OutputType([GitHubTeam])]
    [CmdletBinding()]
    param(
        # The slug of the team name.
        [Parameter(Mandatory)]
        [Alias('team_slug')]
        [string] $Slug,

        # The organization name. The name is not case sensitive.
        # If not provided, the owner from the context will be used.
        [Parameter()]
        [string] $Organization,

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
        try {
            $query = @"
query(`$org: String!, `$teamSlug: String!) {
  organization(login: `$org) {
    team(slug: `$teamSlug) {
        id
        name
        slug
        combinedSlug
        databaseId
        description
        notificationSetting
        privacy
        parentTeam {
          name
          slug
        }
        organization {
          login
        }
        childTeams(first: 100) {
          nodes {
            name
          }
        }
        createdAt
        updatedAt
      }
    }
  }
}
"@

            # Variables hash that will be sent with the query
            $variables = @{
                org      = $Organization
                teamSlug = $Slug
            }

            # Send the request to the GitHub GraphQL API
            $response = Invoke-GitHubGraphQLQuery -Query $query -Variables $variables -Context $Context

            # Extract team data
            $team = $response.data.organization.team

            # Output the team object
            if (-not $team) {
                return
            }

            [GitHubTeam](
                @{
                    Name          = $team.name
                    Slug          = $team.slug
                    NodeID        = $team.id
                    CombinedSlug  = $team.CombinedSlug
                    DatabaseID    = $team.DatabaseId
                    Description   = $team.description
                    Notifications = $team.notificationSetting -eq 'NOTIFICATIONS_ENABLED' ? $true : $false
                    Visible       = $team.privacy -eq 'VISIBLE' ? $true : $false
                    ParentTeam    = $team.parentTeam.slug
                    Organization  = $team.organization.login
                    ChildTeams    = $team.childTeams.nodes.name
                    CreatedAt     = $team.createdAt
                    UpdatedAt     = $team.updatedAt
                }
            )
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
