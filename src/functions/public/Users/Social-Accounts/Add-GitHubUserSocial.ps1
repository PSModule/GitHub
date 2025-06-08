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

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Social-Accounts/Add-GitHubUserSocial
    #>
    [OutputType([void])]
    [Alias('Add-GitHubUserSocials')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links for documentation.')]
    [CmdletBinding()]
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
            Method      = 'POST'
            APIEndpoint = '/user/social_accounts'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
