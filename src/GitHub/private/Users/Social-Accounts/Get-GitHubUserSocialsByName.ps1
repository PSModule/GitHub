filter Get-GitHubUserSocialsByName {
    <#
        .SYNOPSIS
        List social accounts for a user

        .DESCRIPTION
        Lists social media accounts for a user. This endpoint is accessible by anyone.

        .EXAMPLE
        Get-GitHubUserSocialsByName -Username 'octocat'

        Lists social media accounts for the user 'octocat'.

        .NOTES
        https://docs.github.com/rest/users/social-accounts#list-social-accounts-for-a-user
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username
    )

    $inputObject = @{
        APIEndpoint = "/users/$Username/social_accounts"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
