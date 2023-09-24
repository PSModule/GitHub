@{
    Name   = 'SecretStore'                      # $script:SecretVault.Name
    Type   = 'Microsoft.PowerShell.SecretStore' # $script:SecretVault.Type
    Secret = @{
        Name = 'GitHub_Config'                  # $script:SecretVault.Secret.Name
    }
}
