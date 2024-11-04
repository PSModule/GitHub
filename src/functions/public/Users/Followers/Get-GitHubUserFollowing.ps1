filter Get-GitHubUserFollowing {
    <#
        .SYNOPSIS
        List the people a given user or the authenticated user follows

        .DESCRIPTION
        Lists the people who a given user or the authenticated user follows.

        .EXAMPLE
        Get-GitHubUserFollowing

        Gets all people the authenticated user follows.

        .EXAMPLE
        Get-GitHubUserFollowing -Username 'octocat'

        Gets all people that 'octocat' follows.

        .NOTES
        [List the people the authenticated user follows](https://docs.github.com/rest/users/followers#list-the-people-the-authenticated-user-follows)
        [List the people a user follows](https://docs.github.com/rest/users/followers#list-the-people-a-user-follows)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('login')]
        [string] $Username,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    if ($Username) {
        Get-GitHubUserFollowingUser -Username $Username -PerPage $PerPage
    } else {
        Get-GitHubUserFollowingMe -PerPage $PerPage
    }

}
