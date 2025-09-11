#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[CmdletBinding()]
param()

BeforeAll {
    # Import required files for testing
    . "$PSScriptRoot/../src/classes/public/Config/GitHubConfig.ps1"
    . "$PSScriptRoot/../src/functions/private/Config/Get-GitHubCompletionPattern.ps1"
    
    # Mock the Initialize-GitHubConfig function and GitHub config
    function Initialize-GitHubConfig {}
    $script:GitHub = @{
        Config = [GitHubConfig]@{
            CompletionMode = 'StartsWith'
        }
    }
}

Describe 'CompletionMode Configuration' {
    Context 'Get-GitHubCompletionPattern' {
        It 'Returns StartsWith pattern when CompletionMode is StartsWith' {
            $script:GitHub.Config.CompletionMode = 'StartsWith'
            $result = Get-GitHubCompletionPattern -WordToComplete 'test'
            $result | Should -Be 'test*'
        }

        It 'Returns Contains pattern when CompletionMode is Contains' {
            $script:GitHub.Config.CompletionMode = 'Contains'
            $result = Get-GitHubCompletionPattern -WordToComplete 'test'
            $result | Should -Be '*test*'
        }

        It 'Defaults to StartsWith pattern when CompletionMode is invalid' {
            $script:GitHub.Config.CompletionMode = 'InvalidMode'
            $result = Get-GitHubCompletionPattern -WordToComplete 'test'
            $result | Should -Be 'test*'
        }

        It 'Handles empty word to complete' {
            $script:GitHub.Config.CompletionMode = 'StartsWith'
            $result = Get-GitHubCompletionPattern -WordToComplete ''
            $result | Should -Be '*'
        }

        It 'Handles empty word to complete with Contains mode' {
            $script:GitHub.Config.CompletionMode = 'Contains'
            $result = Get-GitHubCompletionPattern -WordToComplete ''
            $result | Should -Be '**'
        }

        It 'Works with special characters in word to complete' {
            $script:GitHub.Config.CompletionMode = 'Contains'
            $result = Get-GitHubCompletionPattern -WordToComplete 'test-word'
            $result | Should -Be '*test-word*'
        }
    }

    Context 'GitHubConfig Class' {
        It 'Can create GitHubConfig with CompletionMode property' {
            $config = [GitHubConfig]@{
                CompletionMode = 'Contains'
            }
            $config.CompletionMode | Should -Be 'Contains'
        }

        It 'Can create GitHubConfig from hashtable' {
            $properties = @{
                CompletionMode = 'StartsWith'
                ApiVersion = '2022-11-28'
            }
            $config = [GitHubConfig]::new($properties)
            $config.CompletionMode | Should -Be 'StartsWith'
            $config.ApiVersion | Should -Be '2022-11-28'
        }
    }
}