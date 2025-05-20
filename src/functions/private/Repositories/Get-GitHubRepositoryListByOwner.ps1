filter Get-GitHubRepositoryListByOwner {
    <#
        .SYNOPSIS
        List repositories for a user

        .DESCRIPTION
        Lists public repositories for the specified user.
        Note: For GitHub AE, this endpoint will list internal repositories for the specified user.

        .EXAMPLE
        Get-GitHubRepositoryListByOwner -Owner 'octocat'

        Gets the repositories for the user 'octocat'.

        .EXAMPLE
        Get-GitHubRepositoryListByOwner -Owner 'octocat' -Type 'member'

        Gets the repositories of organizations where the user 'octocat' is a member.

        .EXAMPLE
        Get-GitHubRepositoryListByOwner -Owner 'octocat' -Sort 'created' -Direction 'asc'

        Gets the repositories for the user 'octocat' sorted by creation date in ascending order.

        .OUTPUTS
        GitHubRepository

        .NOTES
        [List repositories for a user](https://docs.github.com/rest/repos/repos#list-repositories-for-a-user)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'hasNextPage', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', 'after', Scope = 'Function',
        Justification = 'Unknown issue with var scoping in blocks.'
    )]
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # Limit the results to repositories with a visibility level.
        [ValidateSet('Internal', 'Private', 'Public')]
        [Parameter()]
        [string] $Visibility,

        # Limit the results to repositories where the user has this role.
        [ValidateSet('Owner', 'Collaborator', 'Organization_member')]
        [Parameter()]
        [string[]] $Affiliation,

        # Limit the results to repositories where the owner has this affiliation (e.g., OWNER only).
        [ValidateSet('Owner', 'Collaborator', 'Organization_member')]
        [Parameter()]
        [string[]] $OwnerAffiliations = 'Owner',

        # Properties to include in the returned object.
        [Parameter()]
        [string[]] $Property = @('Name', 'Owner', 'Url', 'Size', 'Visibility'),

        # Additional properties to include in the returned object.
        [Parameter()]
        [string[]] $AdditionalProperty = @(),

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
        $hasNextPage = $true
        $after = $null
        $perPageSetting = Resolve-GitHubContextSetting -Name 'PerPage' -Value $PerPage -Context $Context
        $graphParams = @{
            PropertyList         = $Property + $AdditionalProperty
            PropertyToGraphQLMap = [GitHubRepository]::PropertyToGraphQLMap
        }
        $graphQLFields = ConvertTo-GitHubGraphQLField @graphParams

        do {
            $inputObject = @{
                Query     = @"
query(
    `$Owner: String!,
    `$PerPage: Int!,
    `$Cursor: String,
    `$Affiliations: [RepositoryAffiliation],
    `$OwnerAffiliations: [RepositoryAffiliation!],
    `$Visibility: RepositoryVisibility,
    `$IsArchived: Boolean,
    `$IsFork: Boolean
) {
  repositoryOwner(
    login: `$Owner
  ) {
    repositories(
        first: `$PerPage,
        after: `$Cursor,
        affiliations: `$Affiliations,
        ownerAffiliations: `$OwnerAffiliations,
        visibility: `$Visibility,
        isArchived: `$IsArchived,
        isFork: `$IsFork
    ) {
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
                    Owner             = $Owner
                    PerPage           = $perPageSetting
                    Cursor            = $after
                    Affiliations      = [string]::IsNullOrEmpty($Affiliation) ? $null : $Affiliation.ToUpper()
                    OwnerAffiliations = [string]::IsNullOrEmpty($OwnerAffiliations) ? $null : $OwnerAffiliations.ToUpper()
                    Visibility        = [string]::IsNullOrEmpty($Visibility) ? $null : $Visibility.ToUpper()
                    IsArchived        = $IsArchived
                    IsFork            = $IsFork
                }
                Context   = $Context
            }

            Invoke-GitHubGraphQLQuery @inputObject | ForEach-Object {
                foreach ($repository in $_.repositoryOwner.repositories.nodes) {
                    [GitHubRepository]::new($repository)
                }
                $hasNextPage = $_.repositoryOwner.repositories.pageInfo.hasNextPage
                $after = $_.repositoryOwner.repositories.pageInfo.endCursor
            }
        } while ($hasNextPage)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
