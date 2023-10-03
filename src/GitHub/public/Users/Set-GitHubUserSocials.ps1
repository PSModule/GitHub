filter Set-GitHubUserSocials {
    <#
        .SYNOPSIS
        Add social accounts for the authenticated user

        .DESCRIPTION
        Add one or more social accounts to the authenticated user's profile. This endpoint is accessible with the `user` scope.

        .EXAMPLE
        Set-GitHubUserSocials -AccountUrls 'https://twitter.com/MyTwitterAccount', 'https://www.linkedin.com/company/MyCompany'

        Adds the Twitter and LinkedIn accounts to the authenticated user's profile.

        .NOTES
        https://docs.github.com/rest/users/social-accounts#add-social-accounts-for-the-authenticated-user
    #>
    [OutputType([void])]
    [CmdletBinding()]
    param (
        # Full URLs for the social media profiles to add.
        [Parameter(Mandatory)]
        [Alias('account_urls')]
        [string[]] $AccountUrls
    )

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case

    $inputObject = @{
        APIEndpoint = '/user/social_accounts'
        Body        = $body
        Method      = 'POST'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
