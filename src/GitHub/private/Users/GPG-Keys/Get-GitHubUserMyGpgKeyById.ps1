filter Get-GitHubUserMyGpgKeyById {
    <#
        .SYNOPSIS
        Get a GPG key for the authenticated user

        .DESCRIPTION
        View extended details for a single GPG key.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `read:gpg_key` [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        Get-GitHubUserMyGpgKeyById -GpgKeyID '4AEE18F83AFDEB23'

        Gets the GPG key with ID '4AEE18F83AFDEB23' for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#get-a-gpg-key-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The ID of the GPG key.
        [Parameter(
            Mandatory
        )]
        [Alias('gpg_key_id')]
        [string] $ID
    )

    $inputObject = @{
        APIEndpoint = "/user/gpg_keys/$ID"
        Method      = 'GET'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
