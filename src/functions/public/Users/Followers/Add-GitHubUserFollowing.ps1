filter Add-GitHubUserFollowing {
    <#
        .SYNOPSIS
        Follow a user

        .DESCRIPTION
        Note that you'll need to set `Content-Length` to zero when calling out to this endpoint.
        For more information, see "[HTTP verbs](https://docs.github.com/rest/overview/resources-in-the-rest-api#http-verbs)."
        Following a user requires the user to be logged in and authenticated with basic auth or OAuth with the `user:follow` scope.

        .EXAMPLE
        ```powershell
        Follow-GitHubUser -Username 'octocat'
        ```

        Follows the user with the username 'octocat'.

        .NOTES
        [Follow a user](https://docs.github.com/rest/users/followers#follow-a-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Followers/Add-GitHubUserFollowing
    #>
    [OutputType([pscustomobject])]
    [Alias('Follow-GitHubUser')]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

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
        $apiParams = @{
            Method      = 'PUT'
            APIEndpoint = "/user/following/$Username"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
