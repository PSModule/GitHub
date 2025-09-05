function New-GitHubUnsignedJWT {
    <#
        .SYNOPSIS
        Creates an unsigned JSON Web Token (JWT) for a GitHub App.

        .DESCRIPTION
        Creates the header and payload portions of a JSON Web Token (JWT) for a GitHub App.
        This function does not sign the JWT - it returns the unsigned token (header.payload)
        that can be passed to a signing function.

        .EXAMPLE
        New-GitHubUnsignedJWT -ClientId 'Iv987654321'

        Creates an unsigned JWT for a GitHub App using the specified client ID.

        .OUTPUTS
        String

        .NOTES
        This function generates a JWT for a GitHub App that can be signed using a private key.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Function creates an unsigned JWT without modifying system state'
    )]
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        # The client ID of the GitHub App.
        # Can use the GitHub App ID or the client ID.
        [Parameter(Mandatory)]
        [string] $ClientID
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $header = [GitHubJWTComponent]::ToBase64UrlString(
            @{
                alg = 'RS256'
                typ = 'JWT'
            }
        )
        $nowUtc = [System.DateTimeOffset]::UtcNow
        $iat = $nowUtc.AddMinutes(-10)
        $exp = $nowUtc.AddMinutes(10)
        $payload = [GitHubJWTComponent]::ToBase64UrlString(
            @{
                iat = $iat.ToUnixTimeSeconds()
                exp = $exp.ToUnixTimeSeconds()
                iss = $ClientID
            }
        )
        [pscustomobject]@{
            Base      = "$header.$payload"
            IssuedAt  = $iat.LocalDateTime
            ExpiresAt = $exp.LocalDateTime
            Issuer    = $ClientID
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
