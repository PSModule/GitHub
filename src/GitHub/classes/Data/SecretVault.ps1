$script:SecretVault = @{
    Name = 'GitHub'                           # $script:SecretVault.Name
    Type = 'Microsoft.PowerShell.SecretStore' # $script:SecretVault.Type
}
$script:Secret = @{
    Name = 'Config'                           # $script:Secret.Name
}
