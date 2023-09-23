@{
    Name   = 'GitHub'                           # $script:SecretVault.Name
    Type   = 'Microsoft.PowerShell.SecretStore' # $script:SecretVault.Type
    Secret = @{
        Name = 'Config'                           # $script:SecretVault.Secret.Name
    }
}
