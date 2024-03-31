filter Get-GitHubUserSigningKey {
    <#
        .SYNOPSIS
        List SSH signing keys for a given user or the authenticated user.

        .DESCRIPTION
        Lists a given user's or the current user's SSH signing keys.

        .EXAMPLE
        Get-GitHubUserSigningKey

        Gets all SSH signing keys for the authenticated user.

        .EXAMPLE
        Get-GitHubUserSigningKey -ID '1234567'

        Gets the SSH signing key with the ID '1234567' for the authenticated user.

        .EXAMPLE
        Get-GitHubUserSigningKey -Username 'octocat'

        Gets all SSH signing keys for the 'octocat' user.

        .NOTES
        [List SSH signing keys for the authenticated user](https://docs.github.com/rest/users/ssh-signing-keys#list-ssh-signing-keys-for-the-authenticated-user)
        [Get an SSH signing key for the authenticated user](https://docs.github.com/rest/users/ssh-signing-keys#get-an-ssh-signing-key-for-the-authenticated-user)
        [List SSH signing keys for a user](https://docs.github.com/rest/users/ssh-signing-keys#list-ssh-signing-keys-for-a-user)

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

        # The unique identifier of the SSH signing key.
        [Parameter(
            ParameterSetName = 'Me'
        )]
        [Alias('gpg_key_id')]
        [string] $ID,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30
    )

    if ($Username) {
        Get-GitHubUserSigningKeyForUser -Username $Username -PerPage $PerPage
    } else {
        if ($ID) {
            Get-GitHubUserMySigningKeyById -ID $ID
        } else {
            Get-GitHubUserMySigningKey -PerPage $PerPage
        }
    }
}
