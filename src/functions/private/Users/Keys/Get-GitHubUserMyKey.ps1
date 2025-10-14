filter Get-GitHubUserMyKey {
    <#
        .SYNOPSIS
        List public SSH keys for the authenticated user

        .DESCRIPTION
        Lists the public SSH keys for the authenticated user's GitHub account.
        Requires that you are authenticated via Basic Auth or via OAuth with at least `read:public_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        ```powershell
        Get-GitHubUserMyKey
        ```

        Gets all public SSH keys for the authenticated user.

        .NOTES
        https://docs.github.com/rest/users/keys#list-public-ssh-keys-for-the-authenticated-user

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
            APIEndpoint = '/user/keys'
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
