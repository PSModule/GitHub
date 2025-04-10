function Get-GitHubTeamListByOrg {
    <#
        .SYNOPSIS
        List teams

        .DESCRIPTION
        Lists all teams in an organization that are visible to the authenticated user.

        .EXAMPLE
        Get-GitHubTeamListByOrg -Organization 'github'

        .NOTES
        [List teams](https://docs.github.com/rest/teams/teams#list-teams)
    #>
    [OutputType([GitHubTeam[]])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        # If you don't provide this parameter, the command will use the owner of the context.
        [Parameter(Mandatory)]
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
        $query = @"
query(`$org: String!, `$after: String) {
  organization(login: `$org) {
    teams(first: 100, after: `$after) {
      nodes {
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
      pageInfo {
        endCursor
        hasNextPage
      }
    }
  }
}
"@

        # Variables hash that will be sent with the query
        $variables = @{
            org = $Organization
        }

        # Prepare to store results and handle pagination
        $hasNextPage = $true
        $after = $null

        while ($hasNextPage) {
            # Update the cursor for pagination
            $variables['after'] = $after

            # Send the request to the GitHub GraphQL API
            $response = Invoke-GitHubGraphQLQuery -Query $query -Variables $variables -Context $Context

            # Extract team data
            $teams = $response.data.organization.teams

            # Accumulate the teams in results
            $teams.nodes | ForEach-Object {
                [GitHubTeam](
                    @{
                        Name          = $_.name
                        Slug          = $_.slug
                        NodeID        = $_.id
                        CombinedSlug  = $_.combinedSlug
                        ID            = $_.databaseId
                        Description   = $_.description
                        Notifications = $_.notificationSetting -eq 'NOTIFICATIONS_ENABLED' ? $true : $false
                        Visible       = $_.privacy -eq 'VISIBLE' ? $true : $false
                        ParentTeam    = $_.parentTeam.slug
                        Organization  = $_.organization.login
                        ChildTeams    = $_.childTeams.nodes.name
                        CreatedAt     = $_.createdAt
                        UpdatedAt     = $_.updatedAt
                    }
                )
            }

            # Check if there's another page to fetch
            $hasNextPage = $teams.pageInfo.hasNextPage
            $after = $teams.pageInfo.endCursor
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
