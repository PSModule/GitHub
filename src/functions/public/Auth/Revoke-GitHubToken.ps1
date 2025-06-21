function Revoke-GitHubToken {
    <#
        .SYNOPSIS
        Revoke a GitHub access token

        .DESCRIPTION
        Revokes a GitHub access token. This function supports revoking OAuth application tokens
        and installation access tokens.

        For OAuth applications, you need to provide the ClientID and access token.
        For installation tokens, the token will be revoked for the current installation.

        .EXAMPLE
        Revoke-GitHubToken -ClientID 'your-client-id' -Token 'your-access-token'

        Revokes an OAuth application access token.

        .EXAMPLE
        Revoke-GitHubToken -InstallationToken

        Revokes the current installation access token.

        .EXAMPLE
        Revoke-GitHubToken -Context $myContext

        Revokes the token from the specified context.

        .NOTES
        [Revoke an authorization for an application](https://docs.github.com/rest/apps/oauth-applications#revoke-an-authorization-for-an-application)
        [Revoke an installation access token](https://docs.github.com/rest/apps/installations#revoke-an-installation-access-token)

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Revoke-GitHubToken
    #>
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = 'OAuth'
    )]
    param(
        # The Client ID of the OAuth application for OAuth token revocation.
        [Parameter(
            Mandatory,
            ParameterSetName = 'OAuth'
        )]
        [string] $ClientID,

        # The access token to revoke. If not specified, uses the token from the current context.
        [Parameter(ParameterSetName = 'OAuth')]
        [Parameter(ParameterSetName = 'Installation')]
        [string] $Token,

        # Revoke an installation access token instead of an OAuth token.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Installation'
        )]
        [switch] $InstallationToken,

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
        if (-not $Token) {
            $Token = Get-GitHubAccessToken -Context $Context -AsPlainText
        }

        if ($PSCmdlet.ParameterSetName -eq 'OAuth') {
            $inputObject = @{
                Method      = 'DELETE'
                APIEndpoint = "/applications/$ClientID/token"
                Body        = @{
                    access_token = $Token
                }
                Context     = $Context
            }
            $targetDescription = "OAuth token for application [$ClientID]"
        } elseif ($InstallationToken) {
            $inputObject = @{
                Method      = 'DELETE'
                APIEndpoint = '/installation/token'
                Context     = $Context
            }
            $targetDescription = 'Installation access token'
        }

        if ($PSCmdlet.ShouldProcess($targetDescription, 'REVOKE')) {
            try {
                Invoke-GitHubAPI @inputObject
                Write-Verbose "Successfully revoked $targetDescription"
            } catch {
                Write-Error "Failed to revoke $targetDescription`: $($_.Exception.Message)"
                throw
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}