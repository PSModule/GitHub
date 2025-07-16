function Update-GitHubAppJWT {
    <#
        .SYNOPSIS
        Updates a JSON Web Token (JWT) for a GitHub App context.

        .DESCRIPTION
        Updates a JSON Web Token (JWT) for a GitHub App context.

        .EXAMPLE
        Update-GitHubAppJWT -Context $Context

        Updates the JSON Web Token (JWT) for a GitHub App using the specified context.

        .OUTPUTS
        securestring

        .NOTES
        [Generating a JSON Web Token (JWT) for a GitHub App | GitHub Docs](https://docs.github.com/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-powershell-to-generate-a-jwt)

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Update-GitHubAppJWT
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
    [OutputType([object])]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context,

        # Return the updated context.
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        $unsignedJWT = New-GitHubUnsignedJWT -ClientId $Context.ClientID
        $jwt = Add-GitHubJWTSignature -UnsignedJWT $unsignedJWT.Base -PrivateKey $Context.PrivateKey
        $Context.Token = ConvertTo-SecureString -String $jwt -AsPlainText
        $Context.TokenExpiresAt = $unsignedJWT.ExpiresAt
        if ($Context.ID) {
            $Context = Set-Context -Context $Context -Vault $script:GitHub.ContextVault
        }
        if ($PassThru) {
            $Context
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
