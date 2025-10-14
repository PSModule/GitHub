filter Get-GitHubUserMySigningKey {
    <#
        .SYNOPSIS
        List SSH signing keys for the authenticated user

        .DESCRIPTION
        Lists the SSH signing keys for the authenticated user's GitHub account. You must authenticate with
        Basic Authentication, or you must authenticate with OAuth with at least `read:ssh_signing_key` scope. For more information, see
        "[Understanding scopes for OAuth apps](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/)."

        .EXAMPLE
        ```powershell
        Get-GitHubUserMySigningKey
        ```

        Lists the SSH signing keys for the authenticated user's GitHub account.

        .NOTES
        https://docs.github.com/rest/users/ssh-signing-keys#list-ssh-signing-keys-for-the-authenticated-user

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
            APIEndpoint = '/user/ssh_signing_keys'
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
