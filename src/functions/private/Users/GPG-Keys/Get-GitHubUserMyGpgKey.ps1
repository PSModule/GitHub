filter Get-GitHubUserMyGpgKey {
    <#
        .SYNOPSIS
        List GPG keys for the authenticated user

        .DESCRIPTION
        Lists the current user's GPG keys.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `read:gpg_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        ```pwsh
        Get-GitHubUserMyGpgKey
        ```

        Gets all GPG keys for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-the-authenticated-user

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = '/user/gpg_keys'
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
