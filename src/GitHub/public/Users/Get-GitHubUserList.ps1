function Get-GitHubUserList {
    <#
        .SYNOPSIS
        List users

        .DESCRIPTION
        Lists all users, in the order that they signed up on GitHub. This list includes personal user accounts and organization accounts.

        Note: Pagination is powered exclusively by the `since` parameter. Use the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers) to get the URL for the next page of users.

        .EXAMPLE
        Get-GitHubUserList -Since 17722253

        Get the authenticated user

        .NOTES
        https://docs.github.com/rest/users/users#list-users
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # A user ID. Only return users with an ID greater than this ID.
        [Parameter()]
        [int] $Since = 0,
        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    $body = @{
        since    = $Since
        per_page = $PerPage
    }

    $inputObject = @{
        APIEndpoint = "/users"
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject

}
