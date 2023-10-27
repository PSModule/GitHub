filter Remove-GitHubUserSocials {
    <#
        .SYNOPSIS
        Delete social accounts for the authenticated user

        .DESCRIPTION
        Deletes one or more social accounts from the authenticated user's profile. This endpoint is accessible with the `user` scope.

        .PARAMETER AccountUrls
        Parameter description

        .EXAMPLE
        Remove-GitHubUserSocials -AccountUrls 'https://twitter.com/MyTwitterAccount'

        .NOTES
        https://docs.github.com/rest/users/social-accounts#delete-social-accounts-for-the-authenticated-user
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
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
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("Social accounts [$($AccountUrls -join ', ')]", "Delete")) {
        $null = (Invoke-GitHubAPI @inputObject).Response
    }

}
