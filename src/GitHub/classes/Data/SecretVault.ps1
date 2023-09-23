$script:SecretVault = [pscustomobject]@{
    Name = 'GitHub'                           # $script:SecretVault.Name
    Type = 'Microsoft.PowerShell.SecretStore' # $script:SecretVault.Type
}
$script:Secret = [pscustomobject]@{
    Name = 'Config'                           # $script:Secret.Name
}
