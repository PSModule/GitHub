filter Get-GitHubUserMySigningKeyById {
    <#
        .SYNOPSIS
        Get an SSH signing key for the authenticated user

        .DESCRIPTION
        Gets extended details for an SSH signing key.
        You must authenticate with Basic Authentication, or you must authenticate with OAuth with at least `read:ssh_signing_key` scope.
        For more information, see
        "[Understanding scopes for OAuth apps](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/)."

        .EXAMPLE
        Get-GitHubUserMySigningKeyById -ID '1234567'

        Gets the SSH signing key with the ID '1234567' for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/ssh-signing-keys#get-an-ssh-signing-key-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The unique identifier of the SSH signing key.
        [Parameter(
            Mandatory
        )]
        [Alias('ssh_signing_key_id')]
        [string] $ID,

        # The context to run the command in.
        [Parameter()]
        [string] $Context
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/user/ssh_signing_keys/$ID"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
