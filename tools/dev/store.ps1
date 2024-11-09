Set-Store -Name 'PSModule.Store' -Secret 'qwe' -Metadata @{
    SecretVaultName = 'SecretStore'
    SecretVaultType = 'Microsoft.PowerShell.SecretStore'
}

Set-StoreConfig -Name SecretVaultName -Value $null -Store 'PSModule.Store'

Get-StoreConfig -Name SecretVaultName -Store 'PSModule.Store'

Get-Store -Name 'PSModule.Store'

Set-Secret -Name 'PSModule.GitHub' -Secret 'qwe' -Metadata @{
    defaultContext = 'github.com/MariusStorhaug'
}

Get-Store -Name 'PSModule.GitHub' -AsPlainText

Set-Secret -Name 'GitHubPowerShell/github.com/MariusStorhaug' -Secret 'qwe' -Metadata @{
    Username       = 'MariusStorhaug'
    HostName       = 'github.com'
    ApiVersion     = '2022-11-28'
    AuthClientID   = 'Iv1.f26b61bc99e69405'
    DeviceFlowType = 'GitHubApp'
    AuthType       = 'UAT'
    ApiBaseUri     = 'https://api.github.com'
    Owner          = 'MariusStorhaug'
    Repository     = 'GitHub'
}
Set-Secret -Name 'GitHubPowerShell/github.com/MariusStorhaug/AccessToken' -Secret 'ghp_1234567890' -Metadata @{
    TokenExpiration = '0001-01-01T00:00:00'
}
Set-Secret -Name 'GitHubPowerShell/github.com/MariusStorhaug/RefreshToken' -Secret 'ghp_1234567890' -Metadata @{
    RefreshTokenExpirationDate = '0001-01-01T00:00:00'
}

(Get-SecretInfo -Name 'GitHubPowerShell/github.com/MariusStorhaug').Metadata
Set-SecretInfo -Name 'GitHubPowerShell/github.com/MariusStorhaug' -Metadata @{
    TokenExpiration = '2022-11-28T00:00:00'
}
