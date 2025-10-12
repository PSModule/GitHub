filter Get-GitHubUserKey {
    <#
        .SYNOPSIS
        List public SSH keys for a given user or the authenticated user.

        .DESCRIPTION
        Lists a given user's or the current user's public SSH keys.
        For the authenticated users keys, it requires that you are authenticated via Basic Auth or via OAuth with
        at least `read:public_key` [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
        Keys from a given user are accessible by anyone.

        .EXAMPLE
        ```powershell
        Get-GitHubUserKey
        ```

        Gets all GPG keys for the authenticated user.

        .EXAMPLE
        ```powershell
        Get-GitHubUserKey -ID '1234567'
        ```

        Gets the public SSH key with the ID '1234567' for the authenticated user.

        .EXAMPLE
        ```powershell
        Get-GitHubUserKey -Username 'octocat'
        ```

        Gets all GPG keys for the 'octocat' user.

        .NOTES
        [List GPG keys for the authenticated user](https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/Keys/Get-GitHubUserKey
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
    param(
        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Username'
        )]
        [string] $Username,

        # The ID of the GPG key.
        [Parameter(
            ParameterSetName = 'Me'
        )]
        [Alias('gpg_key_id')]
        [string] $ID,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Username' {
                Get-GitHubUserKeyForUser -Username $Username -PerPage $PerPage -Context $Context
            }
            'Me' {
                Get-GitHubUserMyKeyById -ID $ID -Context $Context
            }
            default {
                Get-GitHubUserMyKey -PerPage $PerPage -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
