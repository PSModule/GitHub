filter Get-GitHubOrganizationBlockedUser {
    <#
        .SYNOPSIS
        List users blocked by an organization

        .DESCRIPTION
        List the users blocked by an organization.

        .EXAMPLE
        Get-GitHubOrganizationBlockedUser -OrganizationName 'github'

        Lists all users blocked by the organization `github`.

        .NOTES
        https://docs.github.com/rest/orgs/blocking#list-users-blocked-by-an-organization
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
        [string] $OrganizationName,

        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        APIEndpoint = "/orgs/$OrganizationName/blocks"
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
