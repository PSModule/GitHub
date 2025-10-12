function Get-GitHubEnterpriseByName {
    <#
        .SYNOPSIS
        Retrieves details about a GitHub Enterprise instance by name (slug).

        .DESCRIPTION
        This function retrieves detailed information about a GitHub Enterprise instance, including its avatar, billing details, storage usage,
        creation date, and other metadata based on the provided name (slug). It returns an object of type GitHubEnterprise populated with this
        information.

        .EXAMPLE
        ```powershell
        Get-GitHubEnterpriseByName -Name 'my-enterprise'
        ```

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
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $graphQLFields = ([GitHubEnterprise]::PropertyToGraphQLMap).Values

        $enterpriseQuery = @{
            query     = @"
query(`$Slug: String!) {
    enterprise(slug: `$Slug) {
        $graphQLFields
    }
}
"@
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
