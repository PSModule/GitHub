function Get-GitHubEnterpriseOrganization {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Token,

        [Parameter()]
        [string] $EnterpriseSlug = 'dnb',

        [Parameter()]
        $URL = $env:GITHUB_GRAPHQL_URL
    )
    $headers = @{
        'Authorization' = "Bearer $token"
        'Content-Type'  = 'application/json'
    }

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
        'enterpriseSlug' = $EnterpriseSlug
        'first'          = 100
        'after'          = $null
    }
    $allOrgs = @()

    # Function to make the GraphQL request
    function Invoke-GraphQLQuery {
        param (
            [string]$query,
            [hashtable]$variables,
            [string]$URL
        )

        $body = @{
            'query'     = $query
            'variables' = $variables
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri $URL -Method Post -Headers $headers -Body $body
        return $response
    }

    # Loop through pages to retrieve all organizations
    do {
        $response = Invoke-GraphQLQuery -query $query -variables $variables -URL $URL
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

function Get-GitHubAppInstallationAccessToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $InstallationID,

        [Parameter(Mandatory)]
        [string] $Token,

        [Parameter()]
        $BaseURL = $env:GITHUB_API_URL
    )

    $result = Invoke-RestMethod -Method Post -Uri "$BaseURL/app/installations/$InstallationID/access_tokens" -Headers @{
        'Authorization' = "Bearer $token"
        'Accept'        = 'application/vnd.github+json'
    }

    $result
}

function Get-GitHubRepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string] $OrganizationName,

        [Parameter(Mandatory)]
        [string] $Token,

        [Parameter()]
        $BaseURL = $env:GITHUB_API_URL
    )

    $result = Invoke-RestMethod -Method Get -Uri "$BaseURL/orgs/$OrganizationName/repos" -Headers @{
        'Authorization' = "Bearer $token"
        'Accept'        = 'application/vnd.github+json'
    } -FollowRelLink

    $result | ForEach-Object {
        Write-Output $_
    }
}
