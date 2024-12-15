filter Get-GitHubOrganization {
    <#
        .SYNOPSIS
        List organization

        .DESCRIPTION
        List organizations for the authenticated user - if no parameters are provided.
        List organizations for a user - if a username is provided.
        Lists all organizations, in the order that they were created on GitHub - if '-All' is provided.
        Get an organization - if a organization name is provided.

        .EXAMPLE
        Get-GitHubOrganization

        List organizations for the authenticated user.

        .EXAMPLE
        Get-GitHubOrganization -Username 'octocat'

        List public organizations for the user 'octocat'.

        .EXAMPLE
        Get-GitHubOrganization -All -Since 142951047

        List organizations, starting with PSModule.

        .EXAMPLE
        Get-GitHubOrganization -Name 'PSModule'

        Get the organization 'PSModule'.

        .NOTES
        [List organizations](https://docs.github.com/rest/orgs/orgs)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = '__DefaultSet')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'All', Justification = 'Required for parameter set')]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ParameterSetName = 'NamedOrg',
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [Alias('org')]
        [Alias('owner')]
        [string] $Organization,

        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ParameterSetName = 'NamedUser',
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # List all organizations. Use '-Since' to start at a specific organization ID.
        [Parameter(
            Mandatory,
            ParameterSetName = 'AllOrg'
        )]
        [switch] $All,

        # A organization ID. Only return organizations with an ID greater than this ID.
        [Parameter(ParameterSetName = 'AllOrg')]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'AllOrg')]
        [Parameter(ParameterSetName = 'UserOrg')]
        [Parameter(ParameterSetName = '__DefaultSet')]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Organization = $Context.Owner
    }
    Write-Debug "Organization : [$($Context.Owner)]"

    switch ($PSCmdlet.ParameterSetName) {
        '__DefaultSet' {
            Get-GitHubMyOrganization -PerPage $PerPage -Context $Context | Get-GitHubOrganizationByName -Context $Context
        }
        'NamedOrg' {
            Get-GitHubOrganizationByName -Organization $Organization -Context $Context
        }
        'NamedUser' {
            Get-GitHubUserOrganization -Username $Username -Context $Context
        }
        'AllOrg' {
            Get-GitHubAllOrganization -Since $Since -PerPage $PerPage -Context $Context
        }
    }
}
