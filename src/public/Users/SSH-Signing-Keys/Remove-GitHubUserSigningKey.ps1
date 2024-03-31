filter Remove-GitHubUserSigningKey {
    <#
        .SYNOPSIS
        Delete an SSH signing key for the authenticated user

        .DESCRIPTION
        Deletes an SSH signing key from the authenticated user's GitHub account.
        You must authenticate with Basic Authentication, or you must authenticate with OAuth with at least
        `admin:ssh_signing_key` scope. For more information, see
        "[Understanding scopes for OAuth apps](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/)."

        .EXAMPLE
        Remove-GitHubUserSigningKey -ID '1234567'

        Removes the SSH signing key with the ID of `1234567` from the authenticated user's GitHub account.

        .NOTES
        https://docs.github.com/rest/users/ssh-signing-keys#delete-an-ssh-signing-key-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The unique identifier of the SSH signing key.
        [Parameter(
            Mandatory
        )]
        [Alias('ssh_signing_key_id')]
        [string] $ID
    )

    $inputObject = @{
        APIEndpoint = "/user/ssh_signing_keys/$ID"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("SSH signing key with ID [$ID]", 'Delete')) {
        $null = Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

}
