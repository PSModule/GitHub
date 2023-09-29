function Get-GitHubMyOrganization {
    <#
        .SYNOPSIS
        List organizations for the authenticated user

        .DESCRIPTION
        List organizations for the authenticated user.

        **OAuth scope requirements**

        This only lists organizations that your authorization allows you to operate on in some way (e.g., you can list teams with `read:org` scope, you can publicize your organization membership with `user` scope, etc.). Therefore, this API requires at least `user` or `read:org` scope. OAuth requests with insufficient scope receive a `403 Forbidden` response.

        .EXAMPLE
        Get-GitHubMyOrganization

        List organizations for the authenticated user.

        .NOTES
        https://docs.github.com/rest/orgs/orgs#list-organizations-for-the-authenticated-user
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        APIEndpoint = '/user/orgs'
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject

}
