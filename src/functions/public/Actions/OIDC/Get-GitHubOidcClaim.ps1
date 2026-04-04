function Get-GitHubOidcClaim {
    <#
        .SYNOPSIS
        Get the supported OIDC claim keys for a GitHub instance

        .DESCRIPTION
        Retrieves the list of supported OpenID Connect (OIDC) claim keys from the OIDC discovery endpoint
        of a GitHub instance. This endpoint is public and requires no authentication.

        The claim keys returned can be used with Set-GitHubOidcSubjectClaim to customize the OIDC
        subject claim template for organizations and repositories.

        .EXAMPLE
        ```powershell
        Get-GitHubOidcClaim
        ```

        Gets the supported OIDC claim keys for github.com.

        .EXAMPLE
        ```powershell
        Get-GitHubOidcClaim -Context $GitHubContext
        ```

        Gets the supported OIDC claim keys for the GitHub instance associated with the given context.

        .NOTES
        [OpenID Connect Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html)

        .LINK
        https://psmodule.io/GitHub/Functions/Actions/OIDC/Get-GitHubOidcClaim
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to determine the GitHub instance hostname.
        # When not provided, defaults to github.com.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $hostName = 'github.com'
        if ($Context) {
            if ($Context -is [string]) {
                $resolved = Get-GitHubContext -Context $Context -ErrorAction SilentlyContinue
                if ($resolved) {
                    $hostName = $resolved.HostName
                }
            } elseif ($Context.HostName) {
                $hostName = $Context.HostName
            }
        }

        $issuerHost = if ($hostName -eq 'github.com') {
            'token.actions.githubusercontent.com'
        } else {
            "token.actions.$hostName"
        }

        $discoveryUri = "https://$issuerHost/.well-known/openid-configuration"
        Write-Debug "[$stackPath] - Discovery URI: [$discoveryUri]"

        $response = Invoke-RestMethod -Uri $discoveryUri -Method Get
        $response.claims_supported
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
