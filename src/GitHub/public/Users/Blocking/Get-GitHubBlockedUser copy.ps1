filter Assert-GitHubBlockedUser {
    <#
        .SYNOPSIS
        Check if a user is blocked by the authenticated user

        .DESCRIPTION
        Returns a 204 if the given user is blocked by the authenticated user. Returns a 404 if the given user is not blocked by the authenticated user, or if the given user account has been identified as spam by GitHub.

        .EXAMPLE

        .NOTES
        https://docs.github.com/rest/users/blocking#check-if-a-user-is-blocked-by-the-authenticated-user
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = "/user/blocks"
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
