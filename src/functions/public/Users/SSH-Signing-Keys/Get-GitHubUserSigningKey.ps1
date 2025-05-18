filter Get-GitHubUserSigningKey {
    <#
        .SYNOPSIS
        List SSH signing keys for a given user or the authenticated user.

        .DESCRIPTION
        Lists a given user's or the current user's SSH signing keys.

        .EXAMPLE
        Get-GitHubUserSigningKey

        Gets all SSH signing keys for the authenticated user.

        .EXAMPLE
        Get-GitHubUserSigningKey -ID '1234567'

        Gets the SSH signing key with the ID '1234567' for the authenticated user.

        .EXAMPLE
        Get-GitHubUserSigningKey -Username 'octocat'

        Gets all SSH signing keys for the 'octocat' user.

        .NOTES
        [List SSH signing keys for the authenticated user](https://docs.github.com/rest/users/ssh-signing-keys#list-ssh-signing-keys-for-the-authenticated-user)
        [Get an SSH signing key for the authenticated user](https://docs.github.com/rest/users/ssh-signing-keys#get-an-ssh-signing-key-for-the-authenticated-user)
        [List SSH signing keys for a user](https://docs.github.com/rest/users/ssh-signing-keys#list-ssh-signing-keys-for-a-user)
    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
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

        # The unique identifier of the SSH signing key.
        [Parameter(
            ParameterSetName = 'Me'
        )]
        [Alias('gpg_key_id')]
        [string] $ID,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
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
                Get-GitHubUserSigningKeyForUser -Username $Username -PerPage $PerPage -Context $Context
            }
            'Me' {
                Get-GitHubUserMySigningKeyById -ID $ID -Context $Context
            }
            default {
                Get-GitHubUserMySigningKey -PerPage $PerPage -Context $Context
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
