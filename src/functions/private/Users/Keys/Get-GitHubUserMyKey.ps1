filter Get-GitHubUserMyKey {
    <#
        .SYNOPSIS
        List public SSH keys for the authenticated user

        .DESCRIPTION
        Lists the public SSH keys for the authenticated user's GitHub account.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `read:public_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        Get-GitHubUserMyKey

        Gets all public SSH keys for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/keys#list-public-ssh-keys-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    $body = @{
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/user/keys'
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
