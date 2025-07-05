function Get-GitHubEnterpriseList {
    <#
        .SYNOPSIS
        Retrieves a list of all GitHub Enterprise instances.

        .DESCRIPTION
        This function retrieves detailed information about all GitHub Enterprise instances, including their avatars, billing details, storage usage,
        creation dates, and other metadata. It returns an array of objects of type GitHubEnterprise populated with this information.

        .EXAMPLE
        Get-GitHubEnterpriseList

        Output:
        ```powershell
        Name              : My Enterprise
        Slug              : my-enterprise
        URL               : https://github.com/enterprises/my-enterprise
        CreatedAt         : 2022-01-01T00:00:00Z

        Name              : Another Enterprise
        Slug              : another-enterprise
        URL               : https://github.com/enterprises/another-enterprise
        CreatedAt         : 2021-12-01T00:00:00Z
        ```

        Retrieves details about the GitHub Enterprise instance.

        .OUTPUTS
        GitHubEnterprise[]

        .NOTES
        An array of objects containing detailed information about the GitHub Enterprise instances, including billing info, URLs, and metadata.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'hasNextPage', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'after', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [OutputType([GitHubEnterprise[]])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $hasNextPage = $true
        $after = $null
        $perPageSetting = Resolve-GitHubContextSetting -Name 'PerPage' -Value $PerPage -Context $Context

        $graphQLFields = ([GitHubEnterprise]::PropertyToGraphQLMap).Values

        do {
            $enterpriseQuery = @{
                query     = @"
query(`$perPage: Int!, `$after: String) {
    viewer {
        enterprises(first: `$perPage, after: `$after) {
            nodes {
                $graphQLFields
            }
        }
    }
}
"@
                Variables = @{
                    perPage = $perPageSetting
                    after   = $after
                }
                Context   = $Context
            }
            Invoke-GitHubGraphQLQuery @enterpriseQuery | ForEach-Object {
                foreach ($enterprise in $_.viewer.enterprises.nodes) {
                    [GitHubEnterprise]::new($enterprise)

                    $hasNextPage = $_.viewer.enterprises.pageInfo.hasNextPage
                    $after = $_.viewer.enterprises.pageInfo.endCursor
                }
            }
        } while ($hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
