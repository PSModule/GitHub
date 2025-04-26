function Get-GitHubTeamListByOrg {
    <#
        .SYNOPSIS
        List teams

        .DESCRIPTION
        Lists all teams in an organization that are visible to the authenticated user.

        .EXAMPLE
        Get-GitHubTeamListByOrg -Organization 'github'
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
        $inputObject = @{
            Query     = @'
query($org: String!, $after: String) {
  organization(login: $org) {
    teams(first: 100, after: $after) {
      nodes {
        id
        name
        slug
        url
        combinedSlug
        databaseId
        description
        notificationSetting
        privacy
        parentTeam {
          name
          slug
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
'@
            Variables = @{
                org = $Organization
            }
            Context   = $Context
        }
        $hasNextPage = $true
        $after = $null

        do {
            # Update the cursor for pagination
            $inputObject['Variables']['after'] = $after
            $data = Invoke-GitHubGraphQLQuery @inputObject
            $teams = $data.organization.teams
            $teams.nodes | ForEach-Object {
                [GitHubTeam](
                    @{
                        Name          = $_.name
                        Slug          = $_.slug
                        NodeID        = $_.id
                        Url           = $_.url
                        CombinedSlug  = $_.combinedSlug
                        ID            = $_.databaseId
                        Description   = $_.description
                        Notifications = $_.notificationSetting -eq 'NOTIFICATIONS_ENABLED' ? $true : $false
                        Visible       = $_.privacy -eq 'VISIBLE' ? $true : $false
                        ParentTeam    = $_.parentTeam.slug
                        Organization  = $Organization
                        ChildTeams    = $_.childTeams.nodes.name
                        CreatedAt     = $_.createdAt
                        UpdatedAt     = $_.updatedAt
                    }
                )
            }
            $hasNextPage = $teams.pageInfo.hasNextPage
            $after = $teams.pageInfo.endCursor
        } while ($hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
