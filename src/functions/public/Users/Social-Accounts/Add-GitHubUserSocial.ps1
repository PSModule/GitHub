filter Add-GitHubUserSocial {
    <#
        .SYNOPSIS
        Add social accounts for the authenticated user

        .DESCRIPTION
        Add one or more social accounts to the authenticated user's profile. This endpoint is accessible with the `user` scope.

        .EXAMPLE
        Add-GitHubUserSocial -AccountUrls 'https://twitter.com/MyTwitterAccount', 'https://www.linkedin.com/company/MyCompany'

        Adds the Twitter and LinkedIn accounts to the authenticated user's profile.

        .NOTES
        [Add social accounts for the authenticated user](https://docs.github.com/rest/users/social-accounts#add-social-accounts-for-the-authenticated-user)
    #>
    [OutputType([void])]
    [Alias('Add-GitHubUserSocials')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links for documentation.')]
    [CmdletBinding()]
    param(
        # Full URLs for the social media profiles to add.
        [Parameter(Mandatory)]
        [Alias('account_urls')]
        [string[]] $AccountUrls,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $body = @{
        account_urls = $AccountUrls
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/user/social_accounts'
        Body        = $body
        Method      = 'POST'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
