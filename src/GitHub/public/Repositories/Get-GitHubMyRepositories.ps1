filter Get-GitHubMyRepositories {
    <#
        .SYNOPSIS
        List repositories for the authenticated user

        .DESCRIPTION
        Lists repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.
        The authenticated user has explicit permission to access repositories they own, repositories where they are a collaborator,
        and repositories that they can access through an organization membership.

        .EXAMPLE
        Get-GitHubMyRepositories

        Gets the repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Visibility 'private'

        Gets the private repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Visibility 'public' -Affiliation 'owner','collaborator' -Sort 'created' -Direction 'asc' -PerPage 100 -Since (Get-Date).AddYears(-5) -Before (Get-Date).AddDays(-1)

        Gets the public repositories for the authenticated user that are owned by the authenticated user or that the authenticated user has been added to as a collaborator.
        The results are sorted by creation date in ascending order and the results are limited to 100 repositories.
        The results are limited to repositories created between 5 years ago and 1 day ago.

        .EXAMPLE
        Get-GitHubMyRepositories -Type 'forks'

        Gets the forked repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Type 'sources'

        Gets the non-forked repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Type 'member'

        Gets the repositories for the authenticated user that are owned by an organization.

        .NOTES
        https://docs.github.com/rest/repos/repos#list-repositories-for-the-authenticated-user

    #>
    [CmdletBinding()]
    param (

        #Limit results to repositories with the specified visibility.
        [Parameter(
            ParameterSetName = 'Aff-Vis'
        )]
        [validateSet('all', 'public', 'private')]
        [string] $Visibility = 'all',

        # Comma-separated list of values. Can include:
        # - owner: Repositories that are owned by the authenticated user.
        # - collaborator: Repositories that the user has been added to as a collaborator.
        # - organization_member: Repositories that the user has access to through being a member of an organization. This includes every repository on every team that the user is on.
        # Default: owner, collaborator, organization_member
        [Parameter(
            ParameterSetName = 'Aff-Vis'
        )]
        [validateset('owner', 'collaborator', 'organization_member')]
        [string[]] $Affiliation = @('owner', 'collaborator', 'organization_member'),

        # Specifies the types of repositories you want returned.
        [Parameter(
            ParameterSetName = 'Type'
        )]
        [validateSet('all', 'public', 'private', 'forks', 'sources', 'member')]
        [string] $Type = 'all',

        # The property to sort the results by.
        [Parameter()]
        [validateSet('created', 'updated', 'pushed', 'full_name')]
        [string] $Sort = 'created',

        # The order to sort by.
        # Default: asc when using full_name, otherwise desc.
        [Parameter()]
        [validateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30,

        # Only show repositories updated after the given time.
        [Parameter()]
        [datetime] $Since,

        # Only show repositories updated before the given time.
        [Parameter()]
        [datetime] $Before
    )

    $Affiliation = $Affiliation -join ','

    # This is a timestamp in ISO 8601 format: YYYY-MM-DDTHH:MM:SSZ.
    $Since = $Since.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $Before = $Before.ToString('yyyy-MM-ddTHH:mm:ssZ')

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntries -Hashtable $body -RemoveNames 'Owner'

    $inputObject = @{
        APIEndpoint = "/user/repos"
        Method      = 'GET'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
