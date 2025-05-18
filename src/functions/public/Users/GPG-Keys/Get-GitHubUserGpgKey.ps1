filter Get-GitHubUserGpgKey {
    <#
        .SYNOPSIS
        List GPG keys for a given user or the authenticated user

        .DESCRIPTION
        Lists a given user's or the current user's GPG keys.

        .EXAMPLE
        Get-GitHubUserGpgKey

        Gets all GPG keys for the authenticated user.

        .EXAMPLE
        Get-GitHubUserGpgKey -ID '1234567'

        Gets the GPG key with ID '1234567' for the authenticated user.

        .EXAMPLE
        Get-GitHubUserGpgKey -Username 'octocat'

        Gets all GPG keys for the 'octocat' user.

        .NOTES
        [List GPG keys for the authenticated user](https://docs.github.com/rest/users/gpg-keys#list-gpg-keys-for-the-authenticated-user)
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
        [object] $Context = (Get-GitHubContext)
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
                Get-GitHubUserGpgKeyForUser -Username $Username -PerPage $PerPage -Context $Context
            }
            'Me' {
                Get-GitHubUserMyGpgKeyById -ID $ID -Context $Context
            }
            default {
                Get-GitHubUserMyGpgKey -PerPage $PerPage -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
