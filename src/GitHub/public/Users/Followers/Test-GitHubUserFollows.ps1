filter Test-GitHubUserFollows {
    <#
        .SYNOPSIS
        Check if a given user or the authenticated user follows a person

        .DESCRIPTION
        Returns a 204 if the given user or the authenticated user follows another user.
        Returns a 404 if the user is not followed by a given user or the authenticated user.

        .EXAMPLE
        Test-GitHubUserFollows -Follows 'octocat'
        Test-GitHubUserFollows 'octocat'

        Checks if the authenticated user follows the user 'octocat'.

        .EXAMPLE
        Test-GitHubUserFollows -Username 'octocat' -Follows 'ratstallion'

        Checks if the user 'octocat' follows the user 'ratstallion'.

        .NOTES
        https://docs.github.com/rest/users/followers#check-if-a-person-is-followed-by-the-authenticated-user
        https://docs.github.com/rest/users/followers#check-if-a-user-follows-another-user

    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account we want to check if is being followed.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Follows,

        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username

    )

    if ($Username) {
        Test-GitHubUserFollowedByUser -Username $Username -Follows $Follows
    } else {
        Test-GitHubUserFollowedByMe -Username $Follows
    }

}
