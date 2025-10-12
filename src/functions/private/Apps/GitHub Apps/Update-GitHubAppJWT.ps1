function Update-GitHubAppJWT {
    <#
        .SYNOPSIS
        Updates a JSON Web Token (JWT) for a GitHub App context.

        .DESCRIPTION
        Updates a JSON Web Token (JWT) for a GitHub App context. If the JWT has half or less of its remaining duration before expiration,
        it will be refreshed. This function implements mutex-based locking to prevent concurrent refreshes.

        .EXAMPLE
        ```powershell
        Update-GitHubAppJWT -Context $Context
        ```

        Updates the JSON Web Token (JWT) for a GitHub App using the specified context.

        .EXAMPLE
        ```powershell
        Update-GitHubAppJWT -Context $Context -PassThru
        ```

        This will update the GitHub App JWT for the specified context and return the updated context.

        .EXAMPLE
        ```powershell
        Update-GitHubAppJWT -Context $Context -Silent
        ```

        This will update the GitHub App JWT for the specified context without displaying progress messages.

        .OUTPUTS
        object

        .NOTES
        [Generating a JSON Web Token (JWT) for a GitHub App | GitHub Docs](https://docs.github.com/apps/creating-github-apps/authenticating-with-a-github-app/generating-a-json-web-token-jwt-for-a-github-app#example-using-powershell-to-generate-a-jwt)

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Update-GitHubAppJWT
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([object])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Contains a long link.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Generated JWT is a plaintext string.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingWriteHost', '',
        Justification = 'Is the CLI part of the module.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Function creates a JWT without modifying system state'
    )]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context,

        # Return the updated context.
        [Parameter()]
        [switch] $PassThru,

        # Timeout in milliseconds for waiting on mutex. Default is 30 seconds.
        [Parameter()]
        [int] $TimeoutMs = 30000
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if (Test-GitHubJWTRefreshRequired -Context $Context) {
            $lockName = "PSModule.GitHub-$($Context.ID)".Replace('/', '-')
            $lock = $null
            try {
                $lock = [System.Threading.Mutex]::new($false, $lockName)
                $acquiredLock = $lock.WaitOne(0)

                if ($acquiredLock) {
                    try {
                        Write-Debug '⚠ JWT token nearing expiration. Refreshing JWT...'
                        $unsignedJWT = New-GitHubUnsignedJWT -ClientId $Context.ClientID

                        if ($Context.KeyVaultKeyReference) {
                            Write-Debug "Using KeyVault Key Reference: $($Context.KeyVaultKeyReference)"
                            $Context.Token = Add-GitHubKeyVaultJWTSignature -UnsignedJWT $unsignedJWT.Base -KeyVaultKeyReference $Context.KeyVaultKeyReference
                        } elseif ($Context.PrivateKey) {
                            Write-Debug 'Using Private Key from context.'
                            $Context.Token = Add-GitHubLocalJWTSignature -UnsignedJWT $unsignedJWT.Base -PrivateKey $Context.PrivateKey
                        } else {
                            throw 'No Private Key or KeyVault Key Reference provided in the context.'
                        }

                        $expiresAt = $unsignedJWT.ExpiresAt
                        if ($expiresAt.Kind -eq [DateTimeKind]::Utc) {
                            $expiresAt = $expiresAt.ToLocalTime()
                        }
                        $Context.TokenExpiresAt = $expiresAt

                        if ($Context.ID) {
                            if ($PSCmdlet.ShouldProcess('JWT token', 'Update/refresh')) {
                                Set-Context -Context $Context -Vault $script:GitHub.ContextVault
                            }
                        }
                    } finally {
                        $lock.ReleaseMutex()
                    }
                } else {
                    Write-Verbose "JWT token is being updated by another process. Waiting for mutex to be released (timeout: $($TimeoutMs)ms)..."
                    try {
                        if ($lock.WaitOne($TimeoutMs)) {
                            $Context = Resolve-GitHubContext -Context $Context.ID
                            $lock.ReleaseMutex()
                        } else {
                            Write-Warning 'Timeout waiting for JWT token update. Proceeding with current token state.'
                        }
                    } catch [System.Threading.AbandonedMutexException] {
                        Write-Debug 'Mutex was abandoned by another process. Re-checking JWT token state...'
                        $Context = Resolve-GitHubContext -Context $Context.ID
                    }
                }
            } finally {
                if ($lock) {
                    $lock.Dispose()
                }
            }
        } else {
            Write-Debug 'JWT is still valid, no refresh needed'
        }

        if ($PassThru) {
            return $Context
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
