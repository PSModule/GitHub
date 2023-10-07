filter Get-GitHubUserKey {
    <#
        .SYNOPSIS
        List GPG keys for a given user or the authenticated user

        .DESCRIPTION
        Lists a given user's or the current user's GPG keys.

        .EXAMPLE
        Get-GitHubUserKey

        Gets all GPG keys for the authenticated user.

        .EXAMPLE
        Get-GitHubUserKey -Username 'octocat'

        Gets all GPG keys for the 'octocat' user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Username'
        )]
        [string] $Username,

        # The ID of the GPG key.
        [Parameter(
            ParameterSetName = 'Me'
        )]
        [Alias('gpg_key_id')]
        [string] $ID,

        # The number of results per page (max 100).
        [Parameter()]
        [int] $PerPage = 30
    )

    if ($Username) {
        Get-GitHubUserKeyForUser -Username $Username -PerPage $PerPage
    } else {
        if ($ID) {
            Get-GitHubUserMyKeyById -ID $ID
        } else {
            Get-GitHubUserMyKey -PerPage $PerPage
        }
    }
}
