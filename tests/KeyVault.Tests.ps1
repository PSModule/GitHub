#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[CmdletBinding()]
param()

Describe 'KeyVault JWT Signing' {
    BeforeAll {
        # Load the specific functions we need for testing
        . "$PSScriptRoot/../src/functions/public/Auth/Connect-GitHubAccount.ps1"
        . "$PSScriptRoot/../src/functions/private/Apps/GitHub Apps/Add-GitHubJWTSignature.ps1"
        . "$PSScriptRoot/../src/functions/private/Apps/GitHub Apps/Invoke-AzureKeyVaultSign.ps1"
        
        # Sample test data
        $testUnsignedJWT = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiIxMjM0NTYiLCJpYXQiOjE1MzA2NDgwNzAsImV4cCI6MTUzMDY0ODY3MH0'
        $testKeyVaultKey = 'https://test-vault.vault.azure.net/keys/test-key/12345'
    }

    Context 'Connect-GitHubAccount KeyVault parameter set' {
        It 'Should have AppKeyVault parameter set' {
            $cmd = Get-Command Connect-GitHubAccount
            $parameterSet = $cmd.ParameterSets | Where-Object { $_.Name -eq 'AppKeyVault' }
            $parameterSet | Should -Not -BeNullOrEmpty
        }

        It 'Should have KeyVaultKey parameter in AppKeyVault set' {
            $cmd = Get-Command Connect-GitHubAccount
            $parameterSet = $cmd.ParameterSets | Where-Object { $_.Name -eq 'AppKeyVault' }
            $keyVaultParam = $parameterSet.Parameters | Where-Object { $_.Name -eq 'KeyVaultKey' }
            $keyVaultParam | Should -Not -BeNullOrEmpty
            $keyVaultParam.IsMandatory | Should -Be $true
        }

        It 'Should have ClientID parameter in AppKeyVault set' {
            $cmd = Get-Command Connect-GitHubAccount
            $parameterSet = $cmd.ParameterSets | Where-Object { $_.Name -eq 'AppKeyVault' }
            $clientIdParam = $parameterSet.Parameters | Where-Object { $_.Name -eq 'ClientID' }
            $clientIdParam | Should -Not -BeNullOrEmpty
            $clientIdParam.IsMandatory | Should -Be $true
        }
    }

    Context 'Add-GitHubJWTSignature KeyVault parameter set' {
        It 'Should have KeyVault parameter set' {
            $cmd = Get-Command Add-GitHubJWTSignature
            $parameterSet = $cmd.ParameterSets | Where-Object { $_.Name -eq 'KeyVault' }
            $parameterSet | Should -Not -BeNullOrEmpty
        }

        It 'Should have PrivateKey parameter set' {
            $cmd = Get-Command Add-GitHubJWTSignature
            $parameterSet = $cmd.ParameterSets | Where-Object { $_.Name -eq 'PrivateKey' }
            $parameterSet | Should -Not -BeNullOrEmpty
        }

        It 'Should have KeyVaultKey parameter in KeyVault set' {
            $cmd = Get-Command Add-GitHubJWTSignature
            $parameterSet = $cmd.ParameterSets | Where-Object { $_.Name -eq 'KeyVault' }
            $keyVaultParam = $parameterSet.Parameters | Where-Object { $_.Name -eq 'KeyVaultKey' }
            $keyVaultParam | Should -Not -BeNullOrEmpty
            $keyVaultParam.IsMandatory | Should -Be $true
        }
    }

    Context 'Invoke-AzureKeyVaultSign URL parsing' {
        It 'Should parse KeyVault URL correctly' {
            $keyUrl = 'https://my-vault.vault.azure.net/keys/my-key/version123'
            
            $keyUrl -match '^https://([^.]+)\.vault\.azure\.net/keys/([^/]+)/?(.*)$' | Should -Be $true
            $Matches[1] | Should -Be 'my-vault'
            $Matches[2] | Should -Be 'my-key'
            $Matches[3] | Should -Be 'version123'
        }

        It 'Should reject invalid KeyVault URLs' {
            $invalidUrls = @(
                'https://invalid-url.com/keys/key/version',
                'not-a-url',
                'https://vault.azure.net/keys/key/version',  # missing vault name
                ''
            )
            
            foreach ($url in $invalidUrls) {
                $url -match '^https://([^.]+)\.vault\.azure\.net/keys/([^/]+)/?(.*)$' | Should -Be $false
            }
        }
    }

    Context 'Function availability' {
        It 'Should have Invoke-AzureKeyVaultSign function' {
            Get-Command Invoke-AzureKeyVaultSign -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It 'Should have helper functions for different Azure auth methods' {
            Get-Command Invoke-KeyVaultSignWithAzCli -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            Get-Command Invoke-KeyVaultSignWithAzPowerShell -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            Get-Command Invoke-KeyVaultSignWithRestApi -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }
}