filter Get-GitHubUserMyFollowers {
    <#
        .SYNOPSIS
        List followers of the authenticated user

        .DESCRIPTION
        Lists the people following the authenticated user.

        .EXAMPLE
        Get-GitHubUserMyFollowers

        Gets all followers of the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/followers#list-followers-of-the-authenticated-user

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
        APIEndpoint = '/user/followers'
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
