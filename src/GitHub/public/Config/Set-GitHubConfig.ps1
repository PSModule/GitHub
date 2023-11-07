function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set the GitHub configuration.

        .DESCRIPTION
        Set the GitHub configuration. Specific scopes can be set by using the parameters.

        .EXAMPLE
        Set-GitHubConfig -APIBaseURI 'https://api.github.com" -APIVersion '2022-11-28'

        Sets the App.API scope of the GitHub configuration.

        .EXAMPLE
        Set-GitHubConfig -Name "MyFavouriteRepo" -Value 'https://github.com/PSModule/GitHub'

        Sets a item called 'MyFavouriteRepo' in the GitHub configuration.
    #>
    [Alias('Set-GHConfig')]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Set the access token type.
        [Parameter()]
        [string] $AccessTokenType,

        # Set the access token.
        [Parameter()]
        [securestring] $AccessToken,

        # Set the access token expiration date.
        [Parameter()]
        [datetime] $AccessTokenExpirationDate,

        # Set the API Base URI.
        [Parameter()]
        [string] $ApiBaseUri,

        # Set the GitHub API Version.
        [Parameter()]
        [string] $ApiVersion,

        # Set the authentication type.
        [Parameter()]
        [string] $AuthType,

        # Set the device flow type.
        [Parameter()]
        [string] $DeviceFlowType,

        # Set the default for the Owner parameter.
        [Parameter()]
        [string] $Owner,

        # Set the refresh token.
        [Parameter()]
        [securestring] $RefreshToken,

        # Set the refresh token expiration date.
        [Parameter()]
        [datetime] $RefreshTokenExpirationDate,

        # Set the default for the Repo parameter.
        [Parameter()]
        [string] $Repo,

        # Set the scope.
        [Parameter()]
        [string] $Scope,

        # Set the GitHub username.
        [Parameter()]
        [string] $UserName
    )

    $prefix = $script:SecretVault.Prefix

    #region AccessToken
    $secretName = "$prefix`AccessToken"
    $removeKeys = 'AccessToken', 'RefreshToken', 'RefreshTokenExpirationDate'
    $keepTypes = 'String', 'Int', 'DateTime'

    # Get existing metadata if it exists
    $newSecretMetadata = @{}
    if (Get-SecretInfo -Name $secretName) {
        $secretGetInfoParam = @{
            Name  = $secretName
            Vault = $script:SecretVault.Name
        }
        $secretInfo = Get-SecretInfo @secretGetInfoParam
        Write-Verbose "$secretName - secretInfo : $($secretInfo | Out-String)"
        $secretMetadata = $secretInfo.Metadata | ConvertFrom-HashTable | ConvertTo-HashTable
        $newSecretMetadata = Join-Object -Main $newSecretMetadata -Overrides $secretMetadata -AsHashtable
    }

    # Get metadata updates from parameters and clean up unwanted data
    $updateSecretMetadata = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable
    Write-Verbose "updateSecretMetadata : $($updateSecretMetadata | Out-String)"
    Write-Verbose "updateSecretMetadataType : $($updateSecretMetadata.GetType())"
    Remove-HashtableEntry -Hashtable $updateSecretMetadata -KeepTypes $keepTypes -RemoveNames $removeKeys
    Write-Verbose "updateSecretMetadata : $($updateSecretMetadata | Out-String)"

    $newSecretMetadata = Join-Object -Main $newSecretMetadata -Overrides $updateSecretMetadata -AsHashtable
    Write-Verbose "newSecretMetadata : $($newSecretMetadata | Out-String)"
    Write-Verbose "newSecretMetadataType : $($newSecretMetadata.GetType())"

    if ($AccessToken) {
        $accessTokenSetParam = @{
            Name               = $secretName
            Vault              = $script:SecretVault.Name
            SecureStringSecret = $AccessToken
        }
        if ($PSCmdlet.ShouldProcess("secret [$secretName] in secret vault [$($script:SecretVault.Name)]", 'Set')) {
            Set-Secret @accessTokenSetParam
        }
    }

    if (Get-SecretInfo -Name $secretName) {
        $secretSetInfoParam = @{
            Name     = $secretName
            Vault    = $script:SecretVault.Name
            Metadata = $newSecretMetadata
        }
        if ($PSCmdlet.ShouldProcess("secret [$secretName] in secret vault [$($script:SecretVault.Name)]", 'Set')) {
            Set-SecretInfo @secretSetInfoParam
        }
    }
    #endregion AccessToken

    #region RefreshToken
    $secretName = "$prefix`RefreshToken"
    $removeKeys = 'AccessToken', 'RefreshToken', 'AccessTokenExpirationDate'

    # Get existing metadata if it exists
    $newSecretMetadata = @{}
    if (Get-SecretInfo -Name $secretName) {
        $secretGetInfoParam = @{
            Name  = $secretName
            Vault = $script:SecretVault.Name
        }
        $secretInfo = Get-SecretInfo @secretGetInfoParam
        Write-Verbose "$secretName - secretInfo : $($secretInfo | Out-String)"
        $secretMetadata = $secretInfo.Metadata | ConvertFrom-HashTable | ConvertTo-HashTable
        $newSecretMetadata = Join-Object -Main $newSecretMetadata -Overrides $secretMetadata -AsHashtable
    }

    # Get metadata updates from parameters and clean up unwanted data
    $updateSecretMetadata = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable
    Write-Verbose "updateSecretMetadata : $($updateSecretMetadata | Out-String)"
    Write-Verbose "updateSecretMetadataType : $($updateSecretMetadata.GetType())"
    Remove-HashtableEntry -Hashtable $updateSecretMetadata -KeepTypes $keepTypes -RemoveNames $removeKeys
    Write-Verbose "updateSecretMetadata : $($updateSecretMetadata | Out-String)"

    $newSecretMetadata = Join-Object -Main $newSecretMetadata -Overrides $updateSecretMetadata -AsHashtable
    Write-Verbose "newSecretMetadata : $($newSecretMetadata | Out-String)"
    Write-Verbose "newSecretMetadataType : $($newSecretMetadata.GetType())"

    if ($RefreshToken) {
        $refreshTokenSetParam = @{
            Name               = $secretName
            Vault              = $script:SecretVault.Name
            SecureStringSecret = $RefreshToken
        }
        if ($PSCmdlet.ShouldProcess("secret [$secretName] in secret vault [$($script:SecretVault.Name)]", 'Set')) {
            Set-Secret @refreshTokenSetParam
        }
    }

    if (Get-SecretInfo -Name $secretName) {
        $secretSetInfoParam = @{
            Name     = $secretName
            Vault    = $script:SecretVault.Name
            Metadata = $newSecretMetadata
        }
        if ($PSCmdlet.ShouldProcess("secret [$secretName] in secret vault [$($script:SecretVault.Name)]", 'Set')) {
            Set-SecretInfo @secretSetInfoParam
        }
    }
    #endregion AccessToken
}
