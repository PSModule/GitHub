filter Get-GitHubUserMyGpgKey {
    <#
        .SYNOPSIS
        List GPG keys for the authenticated user

        .DESCRIPTION
        Lists the current user's GPG keys.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `read:gpg_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        Get-GitHubUserMyGpgKey

        Gets all GPG keys for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

        # The context to run the command in.
        [Parameter()]
        [string] $Context
    )

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/user/gpg_keys'
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
