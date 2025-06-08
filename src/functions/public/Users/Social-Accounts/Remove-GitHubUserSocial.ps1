filter Remove-GitHubUserSocial {
    <#
        .SYNOPSIS
        Delete social accounts for the authenticated user

        .DESCRIPTION
        Deletes one or more social accounts from the authenticated user's profile. This endpoint is accessible with the `user` scope.

        .PARAMETER AccountUrls
        Parameter description

        .EXAMPLE
        Remove-GitHubUserSocial -AccountUrls 'https://twitter.com/MyTwitterAccount'

        .NOTES
        [Delete social accounts for the authenticated user](https://docs.github.com/rest/users/social-accounts#delete-social-accounts-for-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Social-Accounts/Remove-GitHubUserSocial
    #>
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [Alias('Remove-GitHubUserSocials')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Full URLs for the social media profiles to add.
        [Parameter(Mandatory)]
        [Alias('account_urls', 'social_accounts', 'AccountUrls')]
        [string[]] $URL,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            account_urls = $URL
        }

        $inputObject = @{
            Method      = 'DELETE'
            APIEndpoint = '/user/social_accounts'
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Social accounts [$($URL -join ', ')]", 'DELETE')) {
            Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
