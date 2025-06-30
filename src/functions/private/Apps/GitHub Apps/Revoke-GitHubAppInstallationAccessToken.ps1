function Revoke-GitHubAppInstallationAccessToken {
    <#
        .SYNOPSIS
        Revoke an installation access token.

        .DESCRIPTION
        Revokes the installation token you're using to authenticate as an installation and access this endpoint.
        Once an installation token is revoked, the token is invalidated and cannot be used. Other endpoints that require the revoked installation
        token must have a new installation token to work. You can create a new token using the `Connect-GitHubApp` function.

        .NOTES
        [Revoke an installation access token](https://docs.github.com/rest/apps/installations#revoke-an-installation-access-token)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT
    }

    process {
        $InputObject = @{
            Method      = 'DELETE'
            APIEndpoint = '/installation/token'
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess('GitHub App installation access token', 'Revoke')) {
            Invoke-GitHubAPI @InputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
