filter Get-GitHubMyRepositories {
    <#
        .SYNOPSIS
        List repositories for the authenticated user

        .DESCRIPTION
        Lists repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.
        The authenticated user has explicit permission to access repositories they own, repositories where
        they are a collaborator, and repositories that they can access through an organization membership.

        .EXAMPLE
        Get-GitHubMyRepositories

        Gets the repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Visibility 'private'

        Gets the private repositories for the authenticated user.

        .EXAMPLE
        $param = @{
            Visibility = 'public'
            Affiliation = 'owner','collaborator'
            Sort = 'created'
            Direction = 'asc'
            PerPage = 100
            Since = (Get-Date).AddYears(-5)
            Before = (Get-Date).AddDays(-1)
        }
        Get-GitHubMyRepositories @param

        Gets the public repositories for the authenticated user that are owned by the authenticated user
        or that the authenticated user has been added to as a collaborator. The results are sorted by
        creation date in ascending order and the results are limited to 100 repositories. The results
        are limited to repositories created between 5 years ago and 1 day ago.

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
    [CmdletBinding(DefaultParameterSetName = 'Type')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Private function, not exposed to user.')]
    param (
        # Limit results to repositories with the specified visibility.
        [Parameter(
            ParameterSetName = 'Aff-Vis'
        )]
        [ValidateSet('all', 'public', 'private')]
        [string] $Visibility = 'all',

        # Comma-separated list of values. Can include:
        # - owner: Repositories that are owned by the authenticated user.
        # - collaborator: Repositories that the user has been added to as a collaborator.
        # - organization_member: Repositories that the user has access to through being a member of an organization.
        #   This includes every repository on every team that the user is on.
        # Default: owner, collaborator, organization_member
        [Parameter(
            ParameterSetName = 'Aff-Vis'
        )]
        [ValidateSet('owner', 'collaborator', 'organization_member')]
        [string[]] $Affiliation = @('owner', 'collaborator', 'organization_member'),

        # Specifies the types of repositories you want returned.
        [Parameter(
            ParameterSetName = 'Type'
        )]
        [ValidateSet('all', 'owner', 'public', 'private', 'member')]
        [string] $Type = 'all',

        # The property to sort the results by.
        [Parameter()]
        [ValidateSet('created', 'updated', 'pushed', 'full_name')]
        [string] $Sort = 'created',

        # The order to sort by.
        # Default: asc when using full_name, otherwise desc.
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

        # Only show repositories updated after the given time.
        [Parameter()]
        [datetime] $Since,

        # Only show repositories updated before the given time.
        [Parameter()]
        [datetime] $Before
    )

    $PSCmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        Write-Verbose "Parameter: [$($_.Key)] = [$($_.Value)]"
        $paramDefaultValue = Get-Variable -Name $_.Key -ValueOnly -ErrorAction SilentlyContinue
        if (-not $PSBoundParameters.ContainsKey($_.Key) -and ($null -ne $paramDefaultValue)) {
            Write-Verbose "Parameter: [$($_.Key)] = [$($_.Value)] - Adding default value"
            $PSBoundParameters[$_.Key] = $paramDefaultValue
        }
        Write-Verbose " - $($PSBoundParameters[$_.Key])"
    }

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntries -Hashtable $body -RemoveNames 'Affiliation', 'Since', 'Before'

    if ($PSBoundParameters.ContainsKey('Affiliation')) {
        $body['affiliation'] = $Affiliation -join ','
    }
    if ($PSBoundParameters.ContainsKey('Since')) {
        $body['since'] = $Since.ToString('yyyy-MM-ddTHH:mm:ssZ')
    }
    if ($PSBoundParameters.ContainsKey('Before')) {
        $body['before'] = $Before.ToString('yyyy-MM-ddTHH:mm:ssZ')
    }

    $inputObject = @{
        APIEndpoint = '/user/repos'
        Method      = 'GET'
        body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
