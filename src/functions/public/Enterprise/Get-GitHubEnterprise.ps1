function Get-GitHubEnterprise {
    <#
        .SYNOPSIS
        Retrieves details about a GitHub Enterprise instance by name (slug).

        .DESCRIPTION
        This function retrieves detailed information about a GitHub Enterprise instance, including its avatar, billing details, storage usage,
        creation date, and other metadata based on the provided name (slug). It returns an object of type GitHubEnterprise populated with this
        information.

        .EXAMPLE
        Get-GitHubEnterprise -Name 'my-enterprise'

        Output:
        ```powershell
        Name              : My Enterprise
        Slug              : my-enterprise
        URL               : https://github.com/enterprises/my-enterprise
        CreatedAt         : 2022-01-01T00:00:00Z
        ViewerIsAdmin     : True
        ```

        Retrieves details about the GitHub Enterprise instance named 'my-enterprise'.

        .OUTPUTS
        GitHubEnterprise

        .NOTES
        An object containing detailed information about the GitHub Enterprise instance, including billing info, URLs, and metadata.

        .LINK
        https://psmodule.io/GitHub/Functions/Get-GitHubEnterprise/
    #>
    [OutputType([GitHubEnterprise])]
    [CmdletBinding()]
    param(
        # The name (slug) of the GitHub Enterprise instance to retrieve.
        [Parameter(Mandatory)]
        [Alias('Slug')]
        [string] $Name,

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
        $enterpriseQuery = @{
            query     = @'
query($Slug: String!) {
  enterprise(slug: $Slug) {
    avatarUrl
    billingEmail
    billingInfo {
        allLicensableUsersCount
        assetPacks
        bandwidthQuota
        bandwidthUsage
        bandwidthUsagePercentage
        storageQuota
        storageUsage
        storageUsagePercentage
        totalAvailableLicenses
        totalLicenses
    }
    createdAt
    databaseId
    description
    descriptionHTML
    id
    location
    name
    readme
    readmeHTML
    resourcePath
    slug
    updatedAt
    url
    viewerIsAdmin
    websiteUrl
  }
}
'@
            Variables = @{
                Slug = $Name
            }
            Context   = $Context
        }
        $enterpriseResult = Invoke-GitHubGraphQLQuery @enterpriseQuery
        [GitHubEnterprise]::new($enterpriseResult.enterprise)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
