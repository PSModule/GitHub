﻿filter Remove-GitHubUserFollowing {
    <#
        .SYNOPSIS
        Unfollow a user

        .DESCRIPTION
        Unfollowing a user requires the user to be logged in and authenticated with basic auth or OAuth with the `user:follow` scope.

        .EXAMPLE
        Unfollow-GitHubUser -Username 'octocat'

        Unfollows the user with the username 'octocat'.

        .NOTES
        [Unfollow a user](https://docs.github.com/rest/users/followers#unfollow-a-user)
    #>
    [OutputType([pscustomobject])]
    [Alias('Unfollow-GitHubUser')]
    [CmdletBinding(SupportsShouldProcess)]
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
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'Delete'
            APIEndpoint = "/user/following/$Username"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("User [$Username]", 'Unfollow')) {
            Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
