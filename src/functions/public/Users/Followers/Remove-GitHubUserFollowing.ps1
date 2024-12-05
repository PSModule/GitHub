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

    $Context = Resolve-GitHubContext -Context $Context

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/user/following/$Username"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("User [$Username]", 'Unfollow')) {
        $null = Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
