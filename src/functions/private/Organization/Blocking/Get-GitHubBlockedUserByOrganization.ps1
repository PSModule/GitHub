filter Get-GitHubBlockedUserByOrganization {
    <#
        .SYNOPSIS
        List users blocked by an organization

        .DESCRIPTION
        List the users blocked by an organization.

        .EXAMPLE
        Get-GitHubBlockedUserByOrganization -OrganizationName 'github'

        Lists all users blocked by the organization `github`.

        .NOTES
        [List users blocked by an organization](https://docs.github.com/rest/orgs/blocking#list-users-blocked-by-an-organization)
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
        [ValidateRange(1, 100)]
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

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
