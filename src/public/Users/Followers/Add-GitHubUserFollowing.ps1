filter Add-GitHubUserFollowing {
    <#
        .SYNOPSIS
        Follow a user

        .DESCRIPTION
        Note that you'll need to set `Content-Length` to zero when calling out to this endpoint.
        For more information, see "[HTTP verbs](https://docs.github.com/rest/overview/resources-in-the-rest-api#http-verbs)."
        Following a user requires the user to be logged in and authenticated with basic auth or OAuth with the `user:follow` scope.

        .EXAMPLE
        Follow-GitHubUser -Username 'octocat'

        Follows the user with the username 'octocat'.

        .NOTES
        [Follow a user](https://docs.github.com/rest/users/followers#follow-a-user)

    #>
    [OutputType([pscustomobject])]
    [Alias('Follow-GitHubUser')]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username
    )

    $inputObject = @{
        APIEndpoint = "/user/following/$Username"
        Method      = 'PUT'
    }

    $null = Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
