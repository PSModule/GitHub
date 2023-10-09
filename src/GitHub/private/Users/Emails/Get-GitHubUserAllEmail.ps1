filter Get-GitHubUserAllEmail {
    <#
        .SYNOPSIS
        List email addresses for the authenticated user

        .DESCRIPTION
        Lists all of your email addresses, and specifies which one is visible to the public. This endpoint is accessible with the `user:email` scope.

        .EXAMPLE
        Get-GitHubUserAllEmail

        Gets all email addresses for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/emails#list-email-addresses-for-the-authenticated-user

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
        APIEndpoint = "/user/emails"
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
