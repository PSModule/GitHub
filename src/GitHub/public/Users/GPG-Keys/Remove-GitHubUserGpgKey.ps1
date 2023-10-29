filter Remove-GitHubUserGpgKey {
    <#
        .SYNOPSIS
        Delete a GPG key for the authenticated user

        .DESCRIPTION
        Removes a GPG key from the authenticated user's GitHub account.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `admin:gpg_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        Remove-GitHubUserGpgKey -ID '1234567'

        Gets the GPG key with ID '1234567' for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#delete-a-gpg-key-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
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
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("GPG key with ID [$ID]", 'Delete')) {
        $null = Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
    }

}
