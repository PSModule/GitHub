function New-GitHubJWT {
    <#
        .SYNOPSIS
        Generates a JSON Web Token (JWT) for a GitHub App.

        .DESCRIPTION
        Generates a JSON Web Token (JWT) for a GitHub App.

        .EXAMPLE
        Get-GitHubAppJWT -Context $Context

        Generates a JSON Web Token (JWT) for a GitHub App using the specified context containing the client ID and private key.

        .OUTPUTS
        GitHubJsonWebToken

        .NOTES
        [Generating a JSON Web Token (JWT) for a GitHub App | GitHub Docs](https://docs.github.com/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-powershell-to-generate-a-jwt)

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/New-GitHubJWT
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Contains a long link.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Generated JWT is a plaintext string.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Function creates a JWT without modifying system state'
    )]
    [CmdletBinding()]
    [OutputType([GitHubJsonWebToken])]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [AppGitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $unsignedJWT = New-GitHubUnsignedJWT -ClientId $Context.ClientID
        $jwt = Add-GitHubJWTSignature -UnsignedJWT $unsignedJWT -PrivateKey $Context.PrivateKey
        $iat = [System.DateTimeOffset]::UtcNow.AddSeconds(-$script:GitHub.Config.JwtTimeTolerance).ToUnixTimeSeconds()
        $exp = [System.DateTimeOffset]::UtcNow.AddSeconds($script:GitHub.Config.JwtTimeTolerance).ToUnixTimeSeconds()
        [GitHubJsonWebToken]@{
            Token     = ConvertTo-SecureString -String $jwt -AsPlainText
            IssuedAt  = [DateTime]::UnixEpoch.AddSeconds($iat)
            ExpiresAt = [DateTime]::UnixEpoch.AddSeconds($exp)
            Issuer    = $Context.ClientID
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
