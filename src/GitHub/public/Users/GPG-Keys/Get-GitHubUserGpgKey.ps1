filter Get-GitHubUserGpgKey {
    <#
        .SYNOPSIS
        List GPG keys for a given user or the authenticated user

        .DESCRIPTION
        Lists a given user's or the current user's GPG keys.

        .EXAMPLE
        Get-GitHubUserGpgKey

        Gets all GPG keys for the authenticated user.

        .EXAMPLE
        Get-GitHubUserGpgKey -Username 'octocat'

        Gets all GPG keys for the 'octocat' user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    if ($Username) {
        Get-GitHubUserGpgKeyForUser -Username $Username -PerPage $PerPage
    } else {
        Get-GitHubUserMyGpgKey -PerPage $PerPage
    }

}
