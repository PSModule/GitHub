filter Add-GitHubUserGpgKey {
    <#
        .SYNOPSIS
        Create a GPG key for the authenticated user

        .DESCRIPTION
        Adds a GPG key to the authenticated user's GitHub account.
        Requires that you are authenticated via Basic Auth, or OAuth with at least `write:gpg_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        ```powershell
        Add-GitHubUserGpgKey -Name 'GPG key for GitHub' -ArmoredPublicKey @'
        -----BEGIN PGP PUBLIC KEY BLOCK-----
        Version: GnuPG v1
        ```

        mQINBFnZ2ZIBEADQ2Z7Z7
        -----END PGP PUBLIC KEY BLOCK-----
        '@

        Adds a GPG key to the authenticated user's GitHub account.

        .NOTES
        [Create a GPG key for the authenticated user](https://docs.github.com/rest/users/gpg-keys#create-a-gpg-key-for-the-authenticated-user)

        .LINK
        https://psmodule.io/GitHub/Functions/Users/GPG-Keys/Add-GitHubUserGpgKey
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # A descriptive name for the new key.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # A GPG key in ASCII-armored format.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('armored_public_key')]
        [string] $ArmoredPublicKey,

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
        $body = @{
            name               = $Name
            armored_public_key = $ArmoredPublicKey
        }

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = '/user/gpg_keys'
            Body        = $body
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

#SkipTest:FunctionTest:Will add a test for this function in a future PR
