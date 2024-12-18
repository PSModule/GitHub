﻿function Get-GitHubTeamListByOrg {
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
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        # If you don't provide this parameter, the command will use the owner of the context.
        [Parameter()]
        [Alias('Org')]
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

        if ([string]::IsNullOrEmpty($Organization)) {
            $Organization = $Context.Owner
        }
        Write-Debug "Organization: [$Organization]"
    }

    process {
        try {
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