filter Get-GitHubUserMyKeyById {
    <#
        .SYNOPSIS
        Get a public SSH key for the authenticated user

        .DESCRIPTION
        View extended details for a single public SSH key.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `read:public_key` [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        Get-GitHubUserMyKeyById -ID '1234567'

        Gets the public SSH key with the ID '1234567' for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/keys#get-a-public-ssh-key-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
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
        Method      = 'GET'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
