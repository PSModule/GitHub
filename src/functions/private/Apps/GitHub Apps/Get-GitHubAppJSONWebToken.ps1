function Get-GitHubAppJSONWebToken {
    <#
        .SYNOPSIS
        Generates a JSON Web Token (JWT) for a GitHub App.

        .DESCRIPTION
        Generates a JSON Web Token (JWT) for a GitHub App.

        .EXAMPLE
        Get-GitHubAppJWT -ClientId 'Iv987654321' -PrivateKeyFilePath '/path/to/private-key.pem'

        Generates a JSON Web Token (JWT) for a GitHub App using the specified client ID and private key file path.

        .EXAMPLE
        Get-GitHubAppJWT -ClientId 'Iv987654321' -PrivateKey '--- BEGIN RSA PRIVATE KEY --- ... --- END RSA PRIVATE KEY ---'

        Generates a JSON Web Token (JWT) for a GitHub App using the specified client ID and private key.

        .OUTPUTS
        GitHubJsonWebToken

        .NOTES
        [Generating a JSON Web Token (JWT) for a GitHub App | GitHub Docs](https://docs.github.com/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-powershell-to-generate-a-jwt)

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Get-GitHubAppJSONWebToken
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines',
        '',
        Justification = 'Contains a long link.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'Generated JWT is a plaintext string.'
    )]

    [CmdletBinding(DefaultParameterSetName = 'PrivateKey')]
    [OutputType([GitHubJsonWebToken])]
    param(
        # The client ID of the GitHub App.
        # Can use the GitHub App ID or the client ID.
        [Parameter(Mandatory)]
        [string] $ClientId,

        # The path to the private key file of the GitHub App.
        [Parameter(
            Mandatory,
            ParameterSetName = 'FilePath'
        )]
        [string] $PrivateKeyFilePath,

        # The private key of the GitHub App.
        [Parameter(
            Mandatory,
            ParameterSetName = 'PrivateKey'
        )]
        [object] $PrivateKey
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        # Create unsigned JWT (header.payload)
        $unsignedJWT = New-GitHubAppJWT -ClientId $ClientId

        # Add signature to the JWT using local RSA signing
        if ($PrivateKeyFilePath) {
            $jwt = Add-GitHubJWTSignature -UnsignedJWT $unsignedJWT -PrivateKeyFilePath $PrivateKeyFilePath
        } else {
            $jwt = Add-GitHubJWTSignature -UnsignedJWT $unsignedJWT -PrivateKey $PrivateKey
        }

        # Extract timing information for the response object
        $iat = [System.DateTimeOffset]::UtcNow.AddSeconds(-$script:GitHub.Config.JwtTimeTolerance).ToUnixTimeSeconds()
        $exp = [System.DateTimeOffset]::UtcNow.AddSeconds($script:GitHub.Config.JwtTimeTolerance).ToUnixTimeSeconds()

        # Return GitHubJsonWebToken object
        [GitHubJsonWebToken]@{
            Token     = ConvertTo-SecureString -String $jwt -AsPlainText
            IssuedAt  = [DateTime]::UnixEpoch.AddSeconds($iat)
            ExpiresAt = [DateTime]::UnixEpoch.AddSeconds($exp)
            Issuer    = $ClientId
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }

    clean {
        Remove-Variable -Name jwt -ErrorAction SilentlyContinue
        Remove-Variable -Name unsignedJWT -ErrorAction SilentlyContinue
        [System.GC]::Collect()
    }
}
