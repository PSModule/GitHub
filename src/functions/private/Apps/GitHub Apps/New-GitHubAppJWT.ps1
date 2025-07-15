function New-GitHubAppJWT {
    <#
        .SYNOPSIS
        Creates an unsigned JSON Web Token (JWT) for a GitHub App.

        .DESCRIPTION
        Creates the header and payload portions of a JSON Web Token (JWT) for a GitHub App.
        This function does not sign the JWT - it returns the unsigned token (header.payload)
        that can be passed to a signing function.

        .EXAMPLE
        New-GitHubAppJWT -ClientId 'Iv987654321'

        Creates an unsigned JWT for a GitHub App using the specified client ID.

        .OUTPUTS
        String

        .NOTES
        This function separates JWT creation from signing to support multiple signing methods.

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/New-GitHubAppJWT
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # The client ID of the GitHub App.
        # Can use the GitHub App ID or the client ID.
        [Parameter(Mandatory)]
        [string] $ClientId
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        # Create JWT header
        $header = [Convert]::ToBase64String(
            [System.Text.Encoding]::UTF8.GetBytes(
                (
                    ConvertTo-Json -InputObject @{
                        alg = 'RS256'
                        typ = 'JWT'
                    }
                )
            )
        ).TrimEnd('=').Replace('+', '-').Replace('/', '_')

        # Create JWT payload with timestamps
        $iat = [System.DateTimeOffset]::UtcNow.AddSeconds(-$script:GitHub.Config.JwtTimeTolerance).ToUnixTimeSeconds()
        $exp = [System.DateTimeOffset]::UtcNow.AddSeconds($script:GitHub.Config.JwtTimeTolerance).ToUnixTimeSeconds()
        $payload = [Convert]::ToBase64String(
            [System.Text.Encoding]::UTF8.GetBytes(
                (
                    ConvertTo-Json -InputObject @{
                        iat = $iat
                        exp = $exp
                        iss = $ClientId
                    }
                )
            )
        ).TrimEnd('=').Replace('+', '-').Replace('/', '_')

        # Return unsigned JWT (header.payload)
        return "$header.$payload"
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}