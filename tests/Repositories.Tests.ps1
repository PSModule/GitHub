#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingWriteHost', '',
    Justification = 'Log outputs to GitHub Actions logs.'
)]
[CmdletBinding()]
param()

BeforeAll {
    $testName = 'RepositoriesTests'
    $os = $env:RUNNER_OS
    $guid = [guid]::NewGuid().ToString()
}

Describe 'Repositories' {
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
        }

        AfterAll {
            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } |
                        Remove-GitHubRepository -Confirm:$false
                }
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        It 'New-GitHubRepository - Creates a new repository' -Skip:($OwnerType -eq 'repository') {
            switch ($OwnerType) {
                'user' {
                    New-GitHubRepository -Name $repoName -AllowSquashMerge
                }
                'organization' {
                    New-GitHubRepository -Organization $owner -Name $repoName -AllowSquashMerge
                }
            }
        }
        It 'New-GitHubRepository - Creates a new repository from a template' -Skip:($OwnerType -eq 'repository') {
            $params = @{
                Name               = "$repoName-tmp"
                TemplateOwner      = 'PSModule'
                TemplateRepository = 'Template-Action'
            }
            switch ($OwnerType) {
                'user' {
                    $repo = New-GitHubRepository @params
                }
                'organization' {
                    $repo = New-GitHubRepository @params -Organization $owner
                }
            }
            LogGroup 'Repository - Template' {
                Write-Host ($repo | Format-List | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It 'New-GitHubRepository - Creates a new repository as a fork' -Skip:($OwnerType -eq 'repository') {
            $params = @{
                Name           = "$repoName-fork"
                ForkOwner      = 'PSModule'
                ForkRepository = 'Template-Action'
            }
            switch ($OwnerType) {
                'user' {
                    $repo = New-GitHubRepository @params
                }
                'organization' {
                    $repo = New-GitHubRepository @params -Organization $owner
                }
            }
            LogGroup 'Repository - Fork' {
                Write-Host ($repo | Format-List | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It "Get-GitHubRepository - Gets the authenticated user's repositories" -Skip:($OwnerType -ne 'user') {
            LogGroup 'Repositories' {
                $repos = Get-GitHubRepository
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos | Should -Not -BeNullOrEmpty
        }
        It "Get-GitHubRepository - Gets the authenticated user's public repositories" -Skip:($OwnerType -ne 'user') {
            LogGroup 'Repositories' {
                $repos = Get-GitHubRepository -Visibility 'Public'
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets the public repos where the authenticated user is owner' -Skip:($OwnerType -ne 'user') {
            LogGroup 'Repositories' {
                $repos = Get-GitHubRepository -Affiliation 'Owner' -Visibility 'Public'
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets a specific repository' -Skip:($OwnerType -eq 'repository') {
            LogGroup 'Repository' {
                switch ($OwnerType) {
                    'user' {
                        $repo = Get-GitHubRepository -Name $repoName
                    }
                    'organization' {
                        $repo = Get-GitHubRepository -Owner $owner -Name $repoName
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets repositories with properties' -Skip:($OwnerType -eq 'repository') {
            LogGroup 'Repository - Property' {
                switch ($OwnerType) {
                    'user' {
                        $repo = Get-GitHubRepository -Property 'Name', 'CreatedAt', 'UpdatedAt' -Debug
                    }
                    'organization' {
                        $repo = Get-GitHubRepository -Owner $owner -Property 'Name', 'CreatedAt', 'UpdatedAt' -Debug
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }
            foreach ($item in $repo) {
                $item | Should -Not -BeNullOrEmpty
                $item.Name | Should -Not -BeNullOrEmpty
                $item.CreatedAt | Should -Not -BeNullOrEmpty
                $item.UpdatedAt | Should -Not -BeNullOrEmpty
                $item.DatabaseID | Should -BeNullOrEmpty
                $item.ID | Should -BeNullOrEmpty
                $item.Owner | Should -BeNullOrEmpty
            }
        }
        It 'Get-GitHubRepository - Gets repositories with additional properties' -Skip:($OwnerType -eq 'repository') {
            LogGroup 'Repository - AdditionalProperty' {
                switch ($OwnerType) {
                    'user' {
                        $repo = Get-GitHubRepository -AdditionalProperty 'CreatedAt', 'UpdatedAt' -Debug
                    }
                    'organization' {
                        $repo = Get-GitHubRepository -Owner $owner -AdditionalProperty 'CreatedAt', 'UpdatedAt' -Debug
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
            $repo.CreatedAt | Should -Not -BeNullOrEmpty
            $repo.UpdatedAt | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets all repositories from a organization' {
            LogGroup 'Repositories' {
                $repos = Get-GitHubRepository -Owner 'PSModule'
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos.Count | Should -BeGreaterThan 0
        }
        It 'Get-GitHubRepository - Gets all repositories from a user' {
            LogGroup 'Repositories' {
                $repos = Get-GitHubRepository -Username 'MariusStorhaug'
                Write-Host ($repos | Format-Table | Out-String)
            }
            $repos.Count | Should -BeGreaterThan 0
        }
        It 'Remove-GitHubRepository - Removes all repositories' -Skip:($OwnerType -eq 'repository') {
            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
                'organization' {
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } |
                        Remove-GitHubRepository -Confirm:$false
                }
            }
        }
        It 'Get-GitHubRepository - Gets none repositories after removal' -Skip:($OwnerType -eq 'repository') {
            if ($OwnerType -eq 'user') {
                $repos = Get-GitHubRepository -Username $Owner | Where-Object { $_.name -like "$repoName*" }
            } else {
                $repos = Get-GitHubRepository -Organization $Owner | Where-Object { $_.name -like "$repoName*" }
            }
            LogGroup 'Repositories' {
                Write-Host ($repos | Format-List | Out-String)
            }
            $repos | Should -BeNullOrEmpty
        }
    }
}
