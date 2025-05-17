#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax - known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '',
    Justification = 'Log outputs to GitHub Actions logs.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidLongLines', '',
    Justification = 'Long test descriptions and skip switches'
)]
[CmdletBinding()]
param()

BeforeAll {
    $testName = 'EnvironmentsTests'
    $os = $env:RUNNER_OS
    $guid = [guid]::NewGuid().ToString()
}

Describe 'Environments' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            if ($AuthType -eq 'APP') {
                LogGroup 'Context - Installation' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    Write-Host ($context | Format-List | Out-String)
                }
            }
            $repoPrefix = "$testName-$os-$TokenType"
            $repoName = "$repoPrefix-$guid"
            $environmentName = "$testName-$os-$TokenType-$guid"

            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    New-GitHubRepository -Name $repoName -Confirm:$false
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                    New-GitHubRepository -Organization $owner -Name $repoName -Confirm:$false
                }
            }
        }

        AfterAll {
            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        It 'Get-GitHubEnvironment - should return an empty list when no environments exist' -Skip:($OwnerType -eq 'repository') {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repoName
            LogGroup 'Environment' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should return null when retrieving a non-existent environment' -Skip:($OwnerType -eq 'repository') {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repoName -Name $environmentName
            LogGroup 'Environment' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -BeNullOrEmpty
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a wait timer of 10' -Skip:($OwnerType -eq 'repository') {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repoName -Name $environmentName -WaitTimer 10
            LogGroup 'Environment' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubEnvironment]
            $result.Name | Should -Be $environmentName
            $result.ProtectionRules.wait_timer | Should -Be 10
        }
        It 'Get-GitHubEnvironment - should retrieve the environment that was created' -Skip:($OwnerType -eq 'repository') {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repoName -Name $environmentName
            LogGroup 'Environment' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a slash in its name' -Skip:($OwnerType -eq 'repository') {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repoName -Name "$environmentName/$os"
            LogGroup 'Environment' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Get-GitHubEnvironment - should retrieve the environment with a slash in its name' -Skip:($OwnerType -eq 'repository') {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repoName -Name "$environmentName/$os"
            LogGroup 'Environment' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Remove-GitHubEnvironment - should delete the environment with a slash in its name without errors' -Skip:($OwnerType -eq 'repository') {
            {
                Get-GitHubEnvironment -Owner $owner -Repository $repoName -Name "$environmentName/$os" | Remove-GitHubEnvironment -Confirm:$false
            } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving the deleted environment with a slash in its name' -Skip:($OwnerType -eq 'repository') {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repoName -Name "$environmentName/$os"
            LogGroup 'Environment' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should list one remaining environment' -Skip:($OwnerType -eq 'repository') {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repoName
            LogGroup 'Environment' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result.Count | Should -Be 1
        }
        It 'Remove-GitHubEnvironment - should delete the remaining environment without errors' -Skip:($OwnerType -eq 'repository') {
            { Remove-GitHubEnvironment -Owner $owner -Repository $repoName -Name $environmentName -Confirm:$false } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving an environment that does not exist' -Skip:($OwnerType -eq 'repository') {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repoName -Name $environmentName
            LogGroup 'Environment' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -BeNullOrEmpty
        }
    }
}
