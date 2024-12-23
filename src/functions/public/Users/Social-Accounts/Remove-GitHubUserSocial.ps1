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
    #>
    #SkipTest:FunctionTest:Will add a test for this function in a future PR
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [Alias('Remove-GitHubUserSocials')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Full URLs for the social media profiles to add.
        [Parameter(Mandatory)]
        [Alias('account_urls')]
        [string[]] $AccountUrls,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                account_urls = $AccountUrls
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/user/social_accounts'
                Body        = $body
                Method      = 'DELETE'
            }

            if ($PSCmdlet.ShouldProcess("Social accounts [$($AccountUrls -join ', ')]", 'Delete')) {
                $null = Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
