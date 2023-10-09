filter Get-GitHubUserFollowingMe {
    <#
        .SYNOPSIS
        List the people the authenticated user follows

        .DESCRIPTION
        Lists the people who the authenticated user follows.

        .EXAMPLE
        Get-GitHubUserFollowingMe

        Gets all people the authenticated user follows.

        .NOTES
        https://docs.github.com/rest/users/followers#list-the-people-the-authenticated-user-follows

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = '/user/following'
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
