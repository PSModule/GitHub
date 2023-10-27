filter Remove-GitHubUserKey {
    <#
        .SYNOPSIS
        Delete a public SSH key for the authenticated user

        .DESCRIPTION
        Removes a public SSH key from the authenticated user's GitHub account.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `admin:public_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        Remove-GitHubUserKey -ID '1234567'

        Deletes the public SSH key with ID '1234567' from the authenticated user's GitHub account.

        .NOTES
        https://docs.github.com/rest/users/keys#delete-a-public-ssh-key-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The unique identifier of the key.
        [Parameter(
            Mandatory
        )]
        [Alias('key_id')]
        [string] $ID
    )

    $inputObject = @{
        APIEndpoint = "/user/keys/$ID"
        Method      = 'DELETE'
    }

    if ($PSCmdlet.ShouldProcess("Key with ID [$ID]", "Delete")) {
        $null = (Invoke-GitHubAPI @inputObject).Response
    }

}
