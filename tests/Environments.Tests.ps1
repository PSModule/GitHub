#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax - known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[CmdletBinding()]
param()

BeforeAll {
    $repoSuffix = 'EnvironmentTest'
    $environmentName = 'production'
    $os = $env:RUNNER_OS
}

Describe 'Environments' {

    Context 'As a user - Fine-grained PAT token - user account access (USER_FG_PAT)' {
        BeforeAll {
            Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT
            $owner = 'psmodule-user'
            $guid = [guid]::NewGuid().ToString()
            $repo = "$repoSuffix-$guid"
            New-GitHubRepository -Name $repo -AllowSquashMerge
        }
        AfterAll {
            Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEnvironment - should return an empty list when no environments exist' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should return null when retrieving a non-existent environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a wait timer of 10' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.ProtectionRules.wait_timer | Should -Be 10
        }
        It 'Get-GitHubEnvironment - should retrieve the environment that was created' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a slash in its name' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Get-GitHubEnvironment - should retrieve the environment with a slash in its name' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Remove-GitHubEnvironment - should delete the environment with a slash in its name without errors' {
            {
                Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os" | Remove-GitHubEnvironment -Confirm:$false
            } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving the deleted environment with a slash in its name' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should list one remaining environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result.Count | Should -Be 1
        }
        It 'Remove-GitHubEnvironment - should delete the remaining environment without errors' {
            { Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving an environment that does not exist' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'As a user - Fine-grained PAT token - organization account access (ORG_FG_PAT)' {
        BeforeAll {
            Connect-GitHubAccount -Token $env:TEST_USER_ORG_FG_PAT
            $owner = 'psmodule-test-org2'
            $guid = [guid]::NewGuid().ToString()
            $repo = "$repoSuffix-$guid"
            New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        }
        AfterAll {
            Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEnvironment - should return an empty list when no environments exist' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should return null when retrieving a non-existent environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a wait timer of 10' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.ProtectionRules.wait_timer | Should -Be 10
        }
        It 'Get-GitHubEnvironment - should retrieve the environment that was created' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a slash in its name' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Get-GitHubEnvironment - should retrieve the environment with a slash in its name' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Remove-GitHubEnvironment - should delete the environment with a slash in its name without errors' {
            {
                Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os" | Remove-GitHubEnvironment -Confirm:$false
            } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving the deleted environment with a slash in its name' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should list one remaining environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result.Count | Should -Be 1
        }
        It 'Remove-GitHubEnvironment - should delete the remaining environment without errors' {
            { Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving an environment that does not exist' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'As a user - Classic PAT token (PAT)' -Skip {}

    Context 'As GitHub Actions (GHA)' -Skip {}

    Context 'As a GitHub App - Enterprise (APP_ENT)' {
        BeforeAll {
            Connect-GitHubAccount -ClientID $env:TEST_APP_ENT_CLIENT_ID -PrivateKey $env:TEST_APP_ENT_PRIVATE_KEY
            $owner = 'psmodule-test-org3'
            $guid = [guid]::NewGuid().ToString()
            $repo = "$repoSuffix-$guid"
            Connect-GitHubApp -Organization $owner -Default
            New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        }
        AfterAll {
            Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEnvironment - should return an empty list when no environments exist' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should return null when retrieving a non-existent environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a wait timer of 10' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.ProtectionRules.wait_timer | Should -Be 10
        }
        It 'Get-GitHubEnvironment - should retrieve the environment that was created' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a slash in its name' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Get-GitHubEnvironment - should retrieve the environment with a slash in its name' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Remove-GitHubEnvironment - should delete the environment with a slash in its name without errors' {
            {
                Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os" | Remove-GitHubEnvironment -Confirm:$false
            } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving the deleted environment with a slash in its name' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should list one remaining environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result.Count | Should -Be 1
        }
        It 'Remove-GitHubEnvironment - should delete the remaining environment without errors' {
            { Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving an environment that does not exist' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }
    }

    Context 'As a GitHub App - Organization (APP_ORG)' {
        BeforeAll {
            Connect-GitHubAccount -ClientID $env:TEST_APP_ORG_CLIENT_ID -PrivateKey $env:TEST_APP_ORG_PRIVATE_KEY
            $owner = 'psmodule-test-org'
            $guid = [guid]::NewGuid().ToString()
            $repo = "$repoSuffix-$guid"
            Connect-GitHubApp -Organization $owner -Default
            New-GitHubRepository -Owner $owner -Name $repo -AllowSquashMerge
        }
        AfterAll {
            Remove-GitHubRepository -Owner $owner -Name $repo -Confirm:$false
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount
        }
        It 'Get-GitHubEnvironment - should return an empty list when no environments exist' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should return null when retrieving a non-existent environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a wait timer of 10' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -WaitTimer 10
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
            $result.ProtectionRules.wait_timer | Should -Be 10
        }
        It 'Get-GitHubEnvironment - should retrieve the environment that was created' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be $environmentName
        }
        It 'Set-GitHubEnvironment - should successfully create an environment with a slash in its name' {
            $result = Set-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Get-GitHubEnvironment - should retrieve the environment with a slash in its name' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "$environmentName/$os"
        }
        It 'Remove-GitHubEnvironment - should delete the environment with a slash in its name without errors' {
            {
                Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os" | Remove-GitHubEnvironment -Confirm:$false
            } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving the deleted environment with a slash in its name' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name "$environmentName/$os"
            $result | Should -BeNullOrEmpty
        }
        It 'Get-GitHubEnvironment - should list one remaining environment' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo
            $result.Count | Should -Be 1
        }
        It 'Remove-GitHubEnvironment - should delete the remaining environment without errors' {
            { Remove-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName -Confirm:$false } | Should -Not -Throw
        }
        It 'Get-GitHubEnvironment - should return null when retrieving an environment that does not exist' {
            $result = Get-GitHubEnvironment -Owner $owner -Repository $repo -Name $environmentName
            $result | Should -BeNullOrEmpty
        }
    }
}
