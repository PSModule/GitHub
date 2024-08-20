filter Get-GitHubUserOrganization {
    <#
        .SYNOPSIS
        List organizations for a user

        .DESCRIPTION
        List [public organization memberships](https://docs.github.com/articles/publicizing-or-concealing-organization-membership)
        for the specified user.

        This method only lists _public_ memberships, regardless of authentication.
        If you need to fetch all of the organization memberships (public and private) for the authenticated user, use the
        [List organizations for the authenticated user](https://docs.github.com/rest/orgs/orgs#list-organizations-for-the-authenticated-user)
        API instead.

        .EXAMPLE
        Get-GitHubUserOrganization -Username 'octocat'

        List public organizations for the user 'octocat'.

        .NOTES
        https://docs.github.com/rest/orgs/orgs#list-organizations-for-a-user
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(Mandatory)]
        [string] $Username,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        APIEndpoint = "/users/$Username/orgs"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
