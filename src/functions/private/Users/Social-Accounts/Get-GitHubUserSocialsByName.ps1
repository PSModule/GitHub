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
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/users/$Username/social_accounts"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
