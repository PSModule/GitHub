filter Get-GitHubUserFollowers {
    <#
        .SYNOPSIS
        List followers of a given user or the authenticated user

        .DESCRIPTION
        Lists the people following a given user or the authenticated user.

        .EXAMPLE
        Get-GitHubUserFollowers

        Gets all followers of the authenticated user.

        .EXAMPLE
        Get-GitHubUserFollowers -Username 'octocat'

        Gets all followers of the user 'octocat'.

        .NOTES
        https://docs.github.com/rest/users/followers#list-followers-of-the-authenticated-user

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
        [int] $PerPage = 30
    )

    if ($Username) {
        Get-GitHubUserFollowersOfUser -Username $Username -PerPage $PerPage
    } else {
        Get-GitHubUserMyFollowers -PerPage $PerPage
    }

}
