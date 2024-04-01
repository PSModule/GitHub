filter Get-GitHubUserFollower {
    <#
        .SYNOPSIS
        List followers of a given user or the authenticated user

        .DESCRIPTION
        Lists the people following a given user or the authenticated user.

        .EXAMPLE
        Get-GitHubUserFollower

        Gets all followers of the authenticated user.

        .EXAMPLE
        Get-GitHubUserFollower -Username 'octocat'

        Gets all followers of the user 'octocat'.

        .NOTES
        [List followers of the authenticated user](https://docs.github.com/rest/users/followers#list-followers-of-the-authenticated-user)
    #>
    [OutputType([pscustomobject])]
    [Alias('Get-GitHubUserMyFollowers')]
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
        Get-GitHubUserFollowersOfUser -Username $Username -PerPage $PerPage
    } else {
        Get-GitHubUserMyFollowers -PerPage $PerPage
    }

}
