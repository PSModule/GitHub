function Get-GitHubTeam {
    <#
        .SYNOPSIS
        Get the teams for an organization using the GitHub GraphQL API.

        .DESCRIPTION
        This command will get the teams for an organization using the GitHub GraphQL API.

        .EXAMPLE
        Get-GitHubTeam -Organization 'PSModule'

        Gets the teams for the PSModule organization.

        .EXAMPLE
        Get-GitHubTeam -Organization 'PSModule' -Context $Context

        Gets the teams for the PSModule organization using the provided context.
    #>
    [CmdletBinding()]
    param(
        # The name of the organization to get the teams for.
        [Parameter()]
        [string] $Name,

        # The owner of the organization to get the teams for.
        # If not provided, the owner from the context will be used.
        [Parameter()]
        [string] $Organization,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if ([string]::IsNullOrEmpty($Owner)) {
            $Organization = $Context.Owner
        }
        Write-Debug "Organization: [$Organization]"
    }

    process {
        try {
            $teamQuery = $null -ne $Name ? 'slug: `$teamSlug' : 'first: 100, after: `$after'
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
                org      = $Organization
                teamSlug = $Name
            }

            # Prepare to store results and handle pagination
            $hasNextPage = $true
            $after = $null

            while ($hasNextPage) {
                # Update the cursor for pagination
                $variables['after'] = $after

                # Send the request to the GitHub GraphQL API
                $response = Invoke-GitHubGraphQLQuery -Query $query -Variables $variables

                # Extract team data
                $teams = $response.data.organization.teams

                # Accumulate the teams in results
                $teams.nodes | ForEach-Object {
                    [PSCustomObject]@{
                        Name          = $_.name # PSModule Admins
                        Slug          = $_.slug # psmodule-admins
                        NodeID        = $_.id # T_kwDOCIVCh84AgoiD
                        CombinedSlug  = $_.combinedSlug # PSModule/psmodule-admins
                        DatabaseId    = $_.databaseId # 8554627
                        Description   = $_.description #
                        Notifications = $_.notificationSetting -eq 'NOTIFICATIONS_ENABLED' ? $true : $false
                        Privacy       = $_.privacy # VISIBLE
                        ParentTeam    = $_.parentTeam.slug
                        Organization  = $_.organization.login
                        ChildTeams    = $_.childTeams.nodes.name
                        CreatedAt     = $_.createdAt # 9/9/2023 11:15:12 AM
                        UpdatedAt     = $_.updatedAt # 3/10/2024 4:42:05 PM
                    }
                }

                # Check if there's another page to fetch
                $hasNextPage = $teams.pageInfo.hasNextPage
                $after = $teams.pageInfo.endCursor
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
