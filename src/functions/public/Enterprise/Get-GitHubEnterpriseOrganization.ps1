function Get-GitHubEnterpriseOrganization {
    <#
        .SYNOPSIS
        Get the list of organizations in a GitHub Enterprise instance.

        .DESCRIPTION
        Use this function to retrieve the list of organizations in a GitHub Enterprise instance.

        .EXAMPLE
        Get-GitHubEnterpriseOrganization -Enterprise 'msx'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Enterprise,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    # Define GraphQL query
    $query = @"
query(`$enterpriseSlug: String!, `$first: Int = 100, `$after: String) {
  enterprise(slug: `$enterpriseSlug) {
    organizations(first: `$first, after: `$after) {
      edges {
        node {
          name
          login
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}
"@

    # Initialize pagination variables
    $variables = @{
        'enterpriseSlug' = $Enterprise
        'first'          = 100
        'after'          = $null
    }
    $allOrgs = @()

    # Loop through pages to retrieve all organizations
    do {
        $response = Invoke-GitHubGraphQLQuery -Query $query -Variables $variables -Context $Context
        # Check for errors
        if ($response.errors) {
            Write-Error "Error: $($response.errors[0].message)"
            break
        }

        # Extract organization names and add to the list
        foreach ($org in $response.data.enterprise.organizations.edges) {
            $allOrgs += $org.node.name
        }

        # Update pagination cursor
        $pageInfo = $response.data.enterprise.organizations.pageInfo
        $variables.after = $pageInfo.endCursor

    } while ($pageInfo.hasNextPage -eq $true)

    # Output the list of organization names
    $allOrgs | ForEach-Object { Write-Output $_ }
}
