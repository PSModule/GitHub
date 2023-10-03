filter Get-GitHubMyUserSocials {
    <#
        .SYNOPSIS
        List social accounts for the authenticated user

        .DESCRIPTION
        Lists all of your social accounts.

        .EXAMPLE
        Get-GitHubMyUserSocials

        Lists all of your social accounts.

        .NOTES
        https://docs.github.com/rest/users/social-accounts#list-social-accounts-for-the-authenticated-user
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
        APIEndpoint = '/user/social_accounts'
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
