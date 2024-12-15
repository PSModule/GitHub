filter Add-GitHubUserGpgKey {
    <#
        .SYNOPSIS
        Create a GPG key for the authenticated user

        .DESCRIPTION
        Adds a GPG key to the authenticated user's GitHub account.
        Requires that you are authenticated via Basic Auth, or OAuth with at least `write:gpg_key`
        [scope](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).

        .EXAMPLE
        Add-GitHubUserGpgKey -Name 'GPG key for GitHub' -ArmoredPublicKey @'
        -----BEGIN PGP PUBLIC KEY BLOCK-----
        Version: GnuPG v1

        mQINBFnZ2ZIBEADQ2Z7Z7
        -----END PGP PUBLIC KEY BLOCK-----
        '@

        Adds a GPG key to the authenticated user's GitHub account.

        .NOTES
        [Create a GPG key for the authenticated user](https://docs.github.com/rest/users/gpg-keys#create-a-gpg-key-for-the-authenticated-user)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
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
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                name               = $Name
                armored_public_key = $ArmoredPublicKey
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/user/gpg_keys'
                Method      = 'POST'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
