function Get-GitHubOrganizationListForAuthUser {
    <#
        .SYNOPSIS
        Retrieves a list of all GitHub organizations for the authenticated user.

        .DESCRIPTION
        This function retrieves detailed information about all GitHub organizations that the authenticated user belongs to, including their avatars,
        creation dates, member counts, and other metadata. It returns an array of objects of type GitHubOrganization populated with this information.

        .EXAMPLE
        ```powershell
        Get-GitHubOrganizationListForAuthUser
        ```

        Output:
        ```powershell
        Name              : MyOrganization
        Login             : my-org
        URL               : https://github.com/my-org
        CreatedAt         : 2022-01-01T00:00:00Z

        Name              : Another Organization
        Login             : another-org
        URL               : https://github.com/another-org
        CreatedAt         : 2021-12-01T00:00:00Z
        ```

        Retrieves details about the GitHub organizations the authenticated user belongs to.

        .OUTPUTS
        GitHubOrganization[]

        .NOTES
        An array of objects containing detailed information about the GitHub organizations, including member info, URLs, and metadata.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'hasNextPage', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'after', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [OutputType([GitHubOrganization[]])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

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
        $hasNextPage = $false
        $after = $null
        $perPageSetting = Resolve-GitHubContextSetting -Name 'PerPage' -Value $PerPage -Context $Context

        $graphQLFields = ([GitHubOrganization]::PropertyToGraphQLMap).Values

        do {
            $organizationQuery = @{
                query     = @"
query(`$perPage: Int!, `$after: String) {
    viewer {
        organizations(first: `$perPage, after: `$after) {
            nodes {
                $graphQLFields
            }
            pageInfo {
                endCursor
                hasNextPage
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
            Invoke-GitHubGraphQLQuery @organizationQuery | ForEach-Object {
                foreach ($organization in $_.viewer.organizations.nodes) {
                    [GitHubOrganization]::new($organization, $Context)
                }
                $hasNextPage = $_.viewer.organizations.pageInfo.hasNextPage
                $after = $_.viewer.organizations.pageInfo.endCursor
            }
        } while ($hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
