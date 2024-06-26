﻿filter Get-GitHubOrganization {
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
    param (
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ParameterSetName = 'NamedOrg',
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [Alias('org')]
        [Alias('owner')]
        [string] $OrganizationName,

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
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    switch ($PSCmdlet.ParameterSetName) {
        '__DefaultSet' {
            Get-GitHubMyOrganization -PerPage $PerPage | Get-GitHubOrganizationByName
        }
        'NamedOrg' {
            Get-GitHubOrganizationByName -OrganizationName $OrganizationName
        }
        'NamedUser' {
            Get-GitHubUserOrganization -Username $Username
        }
        'AllOrg' {
            Get-GitHubAllOrganization -Since $Since -PerPage $PerPage
        }
    }
}
