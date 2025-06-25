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
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidLongLines', '',
    Justification = 'Long test descriptions and skip switches'
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

            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
                'organization' {
                    Get-GitHubTeam -Organization $owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubTeam -Confirm:$false
                    $teamAdmin = New-GitHubTeam -Organization $owner -Name "$repoName-admin"
                    $teamMaintain = New-GitHubTeam -Organization $owner -Name "$repoName-maintain"
                    $teamPush = New-GitHubTeam -Organization $owner -Name "$repoName-push"
                    $teamTriage = New-GitHubTeam -Organization $owner -Name "$repoName-triage"
                    $teamPull = New-GitHubTeam -Organization $owner -Name "$repoName-pull"
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
            }
        }

        AfterAll {
            switch ($OwnerType) {
                'user' {
                    Get-GitHubRepository | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
                'organization' {
                    Get-GitHubTeam -Organization $owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubTeam -Confirm:$false
                    Get-GitHubRepository -Organization $Owner | Where-Object { $_.Name -like "$repoPrefix*" } | Remove-GitHubRepository -Confirm:$false
                }
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        It 'New-GitHubRepository - Creates a new repository' -Skip:($OwnerType -eq 'repository') {
            LogGroup 'Repository - Creation' {
                $params = @{
                    Name      = $repoName
                    HasWiki   = $false
                    HasIssues = $false
                }
                $repo = switch ($OwnerType) {
                    'user' {
                        New-GitHubRepository @params
                    }
                    'organization' {
                        New-GitHubRepository -Organization $owner @params
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
                $repo | Should -BeOfType 'GitHubRepository'
                $repo | Should -Not -BeNullOrEmpty
                $repo.Name | Should -Be $repoName
                $repo.FullName | Should -Be "$owner/$repoName"
                $repo.Owner | Should -Be $owner
                $repo.DatabaseID | Should -Not -BeNullOrEmpty
                $repo.ID | Should -Not -BeNullOrEmpty
                $repo.Url | Should -Not -BeNullOrEmpty
                $repo.CloneUrl | Should -Not -BeNullOrEmpty
                $repo.SshUrl | Should -Not -BeNullOrEmpty
                $repo.GitUrl | Should -Not -BeNullOrEmpty
                $repo.CreatedAt | Should -Not -BeNullOrEmpty
                $repo.UpdatedAt | Should -Not -BeNullOrEmpty
                $repo.IsTemplate | Should -Be $false
                $repo.IsFork | Should -Be $false
                $repo.TemplateRepository | Should -BeNullOrEmpty
                $repo.Forks | Should -Be 0
                $repo.Stargazers | Should -Be 0
                $repo.Watchers | Should -Be 0
                $repo.Language | Should -BeNullOrEmpty
                $repo.ForkRepository | Should -BeNullOrEmpty
                $repo.Visibility | Should -Be 'Public'
                $repo.DefaultBranch | Should -Be 'main'
                $repo.HasIssues | Should -Be $false
                $repo.HasProjects | Should -Be $true
                $repo.HasWiki | Should -Be $false
                $repo.IsArchived | Should -Be $false
            }
        }
        It 'New-GitHubRepository - Creates a new repository with settings' -Skip:($OwnerType -eq 'repository') {
            $name = "$repoName-settings"
            LogGroup 'Repository - Creation + Settings' {
                $params = @{
                    Name                   = $name
                    Description            = 'Test repository with settings'
                    HasIssues              = $false
                    HasProjects            = $false
                    HasWiki                = $false
                    HasDiscussions         = $true
                    HasSponsorships        = $true
                    AllowSquashMergingWith = 'Pull request title and description'
                    SuggestUpdateBranch    = $true
                    DeleteBranchOnMerge    = $true
                    AllowAutoMerge         = $true
                    IsTemplate             = $true
                    AddReadme              = $true
                    License                = 'mit'
                    Visibility             = 'Private'
                    Gitignore              = 'VisualStudio'
                    Homepage               = 'https://example.com'
                }
                $repo = switch ($OwnerType) {
                    'user' {
                        New-GitHubRepository @params
                    }
                    'organization' {
                        New-GitHubRepository -Organization $owner @params
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
                $repo | Should -BeOfType 'GitHubRepository'
                $repo | Should -Not -BeNullOrEmpty
                $repo.Name | Should -Be $name
                $repo.FullName | Should -Be "$owner/$name"
                $repo.Owner | Should -Be $owner
                $repo.DatabaseID | Should -Not -BeNullOrEmpty
                $repo.ID | Should -Not -BeNullOrEmpty
                $repo.Description | Should -Be 'Test repository with settings'
                $repo.Url | Should -Not -BeNullOrEmpty
                $repo.CloneUrl | Should -Not -BeNullOrEmpty
                $repo.SshUrl | Should -Not -BeNullOrEmpty
                $repo.GitUrl | Should -Not -BeNullOrEmpty
                $repo.CreatedAt | Should -Not -BeNullOrEmpty
                $repo.UpdatedAt | Should -Not -BeNullOrEmpty
                $repo.IsTemplate | Should -Be $true
                $repo.IsFork | Should -Be $false
                $repo.TemplateRepository | Should -BeNullOrEmpty
                $repo.Forks | Should -Be 0
                $repo.Stargazers | Should -Be 0
                $repo.Watchers | Should -Be 0
                $repo.Language | Should -BeNullOrEmpty
                $repo.ForkRepository | Should -BeNullOrEmpty
                $repo.Visibility | Should -Be 'Private'
                $repo.DefaultBranch | Should -Be 'main'
                $repo.HasIssues | Should -Be $false
                $repo.HasWiki | Should -Be $false
                $repo.HasProjects | Should -Be $false
                $repo.HasDiscussions | Should -Be $true
                $repo.HasSponsorships | Should -Be $true
                $repo.IsArchived | Should -Be $false
                $repo.SuggestUpdateBranch | Should -Be $true
                $repo.DeleteBranchOnMerge | Should -Be $true
                # $repo.AllowAutoMerge | Should -Be $true
                $repo.License | Should -Be 'MIT License'
                $repo.Homepage | Should -Be 'https://example.com'
            }
        }
        It 'New-GitHubRepository - Creates a new repository from a template' -Skip:($OwnerType -eq 'repository') {
            $name = "$repoName-template"
            LogGroup 'Repository - Template' {
                $params = @{
                    Name               = $name
                    TemplateOwner      = 'PSModule'
                    TemplateRepository = 'Template-Action'
                    HasWiki            = $false
                    HasIssues          = $false
                }
                $repo = switch ($OwnerType) {
                    'user' {
                        New-GitHubRepository @params
                    }
                    'organization' {
                        New-GitHubRepository @params -Organization $owner
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
                $repo | Should -BeOfType 'GitHubRepository'
                $repo | Should -Not -BeNullOrEmpty
                $repo.Name | Should -Be $name
                $repo.FullName | Should -Be "$owner/$name"
                $repo.Owner | Should -Be $owner
                $repo.DatabaseID | Should -Not -BeNullOrEmpty
                $repo.ID | Should -Not -BeNullOrEmpty
                $repo.Url | Should -Not -BeNullOrEmpty
                $repo.CloneUrl | Should -Not -BeNullOrEmpty
                $repo.SshUrl | Should -Not -BeNullOrEmpty
                $repo.GitUrl | Should -Not -BeNullOrEmpty
                $repo.CreatedAt | Should -Not -BeNullOrEmpty
                $repo.UpdatedAt | Should -Not -BeNullOrEmpty
                $repo.IsTemplate | Should -Be $false
                $repo.IsFork | Should -Be $false
                $repo.Forks | Should -Be 0
                $repo.Stargazers | Should -Be 0
                $repo.Watchers | Should -Be 0
                # $repo.Language | Should -Be 'PowerShell' - Not always available on the object.
                $repo.TemplateRepository | Should -Be 'Template-Action'
                $repo.TemplateRepository.Owner | Should -Be 'PSModule'
                $repo.ForkRepository | Should -BeNullOrEmpty
                $repo.Visibility | Should -Be 'Public'
                $repo.DefaultBranch | Should -Be 'main'
                $repo.HasIssues | Should -Be $false
                $repo.HasProjects | Should -Be $true
                $repo.HasWiki | Should -Be $false
                $repo.IsArchived | Should -Be $false
            }
        }
        It 'New-GitHubRepository - Creates a new repository as a fork' -Skip:($OwnerType -eq 'repository') {
            $name = "$repoName-fork"
            LogGroup 'Repository - Fork' {
                $params = @{
                    Name           = $name
                    ForkOwner      = 'psmodule-test'
                    ForkRepository = "fork-$os"
                    HasWiki        = $false
                    HasIssues      = $false
                }
                $repo = switch ($OwnerType) {
                    'user' {
                        New-GitHubRepository @params
                    }
                    'organization' {
                        New-GitHubRepository @params -Organization $owner
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
                $repo | Should -BeOfType 'GitHubRepository'
                $repo | Should -Not -BeNullOrEmpty
                $repo.Name | Should -Be $name
                $repo.FullName | Should -Be "$owner/$name"
                $repo.Owner | Should -Be $owner
                $repo.DatabaseID | Should -Not -BeNullOrEmpty
                $repo.ID | Should -Not -BeNullOrEmpty
                $repo.Url | Should -Not -BeNullOrEmpty
                $repo.CloneUrl | Should -Not -BeNullOrEmpty
                $repo.SshUrl | Should -Not -BeNullOrEmpty
                $repo.GitUrl | Should -Not -BeNullOrEmpty
                $repo.CreatedAt | Should -Not -BeNullOrEmpty
                $repo.UpdatedAt | Should -Not -BeNullOrEmpty
                $repo.IsTemplate | Should -Be $false
                $repo.IsFork | Should -Be $true
                $repo.Forks | Should -Be 0
                $repo.Stargazers | Should -Be 0
                $repo.Watchers | Should -Be 0
                $repo.Language | Should -BeNullOrEmpty
                $repo.TemplateRepository | Should -BeNullOrEmpty
                $repo.ForkRepository | Should -Be "fork-$os"
                $repo.Visibility | Should -Be 'Public'
                $repo.DefaultBranch | Should -Be 'main'
                $repo.HasIssues | Should -Be $false
                $repo.HasProjects | Should -Be $true
                $repo.HasWiki | Should -Be $false
                $repo.IsArchived | Should -Be $false
            }
        }
        Context 'Permissions' -Skip:($OwnerType -ne 'Organization') {
            It 'Set-GitHubRepositoryPermission - Sets the repository permissions - Admin' {
                $permission = 'admin'
                $repo = Get-GitHubRepository -Organization $owner -Name $repoName
                LogGroup 'Set repository permission - Admin' {
                    Set-GitHubRepositoryPermission -Organization $owner -Name $repoName -Permission $permission -Team "$repoName-$permission" -Debug -Verbose
                    $prm = Get-GitHubRepositoryPermission -Organization $owner -Name $repoName -Team "$repoName-$permission"
                    Write-Host ($prm | Format-List | Out-String)
                }
                $prm | Should -Be $permission
            }
            It 'Set-GitHubRepositoryPermission - Sets the repository permissions - Maintain' {
                $permission = 'maintain'
                $repo = Get-GitHubRepository -Organization $owner -Name $repoName
                LogGroup 'Set repository permission - Maintain' {
                    Set-GitHubRepositoryPermission -Organization $owner -Name $repoName -Permission $permission -Team "$repoName-$permission" -Debug -Verbose
                    $prm = Get-GitHubRepositoryPermission -Organization $owner -Name $repoName -Team "$repoName-$permission"
                    Write-Host ($prm | Format-List | Out-String)
                }
                $prm | Should -Be $permission
            }
            It 'Set-GitHubRepositoryPermission - Sets the repository permissions - Push' {
                $permission = 'push'
                $repo = Get-GitHubRepository -Organization $owner -Name $repoName
                LogGroup 'Set repository permission - Push' {
                    Set-GitHubRepositoryPermission -Organization $owner -Name $repoName -Permission $permission -Team "$repoName-$permission" -Debug -Verbose
                    $prm = Get-GitHubRepositoryPermission -Organization $owner -Name $repoName -Team "$repoName-$permission"
                    Write-Host ($prm | Format-List | Out-String)
                }
                $prm | Should -Be $permission
            }
            It 'Set-GitHubRepositoryPermission - Sets the repository permissions - Write' {
                $permission = 'write'
                $repo = Get-GitHubRepository -Organization $owner -Name $repoName
                LogGroup 'Set repository permission - Write' {
                    Set-GitHubRepositoryPermission -Organization $owner -Name $repoName -Permission $permission -Team "$repoName-$permission" -Debug -Verbose
                    $prm = Get-GitHubRepositoryPermission -Organization $owner -Name $repoName -Team "$repoName-$permission"
                    Write-Host ($prm | Format-List | Out-String)
                }
                $prm | Should -Be $permission
            }
            It 'Set-GitHubRepositoryPermission - Sets the repository permissions - Triage' {
                $permission = 'triage'
                $repo = Get-GitHubRepository -Organization $owner -Name $repoName
                LogGroup 'Set repository permission - Triage' {
                    Set-GitHubRepositoryPermission -Organization $owner -Name $repoName -Permission $permission -Team "$repoName-$permission" -Debug -Verbose
                    $prm = Get-GitHubRepositoryPermission -Organization $owner -Name $repoName -Team "$repoName-$permission"
                    Write-Host ($prm | Format-List | Out-String)
                }
                $prm | Should -Be $permission
            }
            It 'Set-GitHubRepositoryPermission - Sets the repository permissions - Pull' {
                $permission = 'pull'
                $repo = Get-GitHubRepository -Organization $owner -Name $repoName
                LogGroup 'Set repository permission - Pull' {
                    Set-GitHubRepositoryPermission -Organization $owner -Name $repoName -Permission $permission -Team "$repoName-$permission" -Debug -Verbose
                    $prm = Get-GitHubRepositoryPermission -Organization $owner -Name $repoName -Team "$repoName-$permission"
                    Write-Host ($prm | Format-List | Out-String)
                }
                $prm | Should -Be $permission
            }
            It 'Set-GitHubRepositoryPermission - Sets the repository permissions - Read' {
                $permission = 'Read'
                $repo = Get-GitHubRepository -Organization $owner -Name $repoName
                LogGroup 'Set repository permission - Read' {
                    Set-GitHubRepositoryPermission -Organization $owner -Name $repoName -Permission $permission -Team "$repoName-$permission" -Debug -Verbose
                    $prm = Get-GitHubRepositoryPermission -Organization $owner -Name $repoName -Team "$repoName-$permission"
                    Write-Host ($prm | Format-List | Out-String)
                }
                $prm | Should -Be $permission
            }
            # It 'Get-GitHubTeam - Gets a team with permissions to a repository' {
            #     $permission = 'admin'
            #     LogGroup 'Get repository team' {
            #         $team = Get-GitHubTeam -Organization $owner -Slug "$repoName-$permission"
            #         Write-Host ($team | Format-List | Out-String)
            #     }
            #     $team | Should -Not -BeNullOrEmpty
            #     $team.Permission | Should -Be $permission
            # }
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
                        $repo = Get-GitHubRepository -Property 'Name', 'CreatedAt', 'UpdatedAt'
                    }
                    'organization' {
                        $repo = Get-GitHubRepository -Owner $owner -Property 'Name', 'CreatedAt', 'UpdatedAt'
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
                        $repo = Get-GitHubRepository -AdditionalProperty 'CreatedAt', 'UpdatedAt'
                    }
                    'organization' {
                        $repo = Get-GitHubRepository -Owner $owner -AdditionalProperty 'CreatedAt', 'UpdatedAt'
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }
            $repo | Should -Not -BeNullOrEmpty
            $repo.CreatedAt | Should -Not -BeNullOrEmpty
            $repo.UpdatedAt | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRepository - Gets repositories with properties - only name' -Skip:($OwnerType -eq 'repository') {
            LogGroup 'Repository - Property' {
                switch ($OwnerType) {
                    'user' {
                        $repo = Get-GitHubRepository -Property 'Name'
                    }
                    'organization' {
                        $repo = Get-GitHubRepository -Owner $owner -Property 'Name'
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }
            foreach ($item in $repo) {
                $item | Should -Not -BeNullOrEmpty
                $item.Name | Should -Not -BeNullOrEmpty
                $item.CreatedAt | Should -BeNullOrEmpty
                $item.UpdatedAt | Should -BeNullOrEmpty
                $item.DatabaseID | Should -BeNullOrEmpty
                $item.ID | Should -BeNullOrEmpty
                $item.Owner | Should -BeNullOrEmpty
                $item.FullName | Should -BeNullOrEmpty
            }
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
        It 'Set-GitHubRepository - Updates an existing repository' -Skip:($OwnerType -eq 'repository') {
            $description = 'Updated description'
            LogGroup 'Repository - Set update' {
                switch ($OwnerType) {
                    'user' {
                        $repoBefore = Get-GitHubRepository -Name $repoName
                        $repo = Set-GitHubRepository -Name $repoName -Description $description
                    }
                    'organization' {
                        $repoBefore = Get-GitHubRepository -Owner $owner -Name $repoName
                        $repo = Set-GitHubRepository -Owner $owner -Name $repoName -Description $description
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }
            LogGroup 'Changed properties:' {
                $changes = Compare-PSCustomObject -Left $repoBefore -Right $repo -OnlyChanged
                Write-Host "$($changes | Format-Table | Out-String)"
                $repo | Should -Not -BeNullOrEmpty
                $repo.Description | Should -Be $description
                $changedProps = $changes.Property
                $changedProps | Should -Contain 'UpdatedAt'
                $changedProps | Should -Contain 'Description'
                $changedProps.Count | Should -Be 2
            }
        }
        It 'Set-GitHubRepository - Creates a new repository when missing' -Skip:($OwnerType -eq 'repository') {
            $newRepoName = "$repoName-new"
            LogGroup 'Repository - Set create' {
                switch ($OwnerType) {
                    'user' {
                        $repoBefore = Get-GitHubRepository -Name $newRepoName
                        $repo = Set-GitHubRepository -Name $newRepoName
                    }
                    'organization' {
                        $repoBefore = Get-GitHubRepository -Owner $owner -Name $newRepoName
                        $repo = Set-GitHubRepository -Organization $owner -Name $newRepoName
                    }
                }
                Write-Host 'Repo before creation'
                Write-Host ($repoBefore | Format-List | Out-String)
                Write-Host 'Repo after creation'
                Write-Host ($repo | Format-List | Out-String)
                $repoBefore | Should -BeNullOrEmpty
                $repo | Should -Not -BeNullOrEmpty
            }
        }
        It 'Update-GitHubRepository - Renames a repository' -Skip:($OwnerType -eq 'repository') {
            $newName = "$repoName-newname"
            LogGroup 'Repository - Renamed' {
                switch ($OwnerType) {
                    'user' {
                        $repoBefore = Get-GitHubRepository -Name $repoName
                        $repo = Update-GitHubRepository -Name $repoName -NewName $newName
                    }
                    'organization' {
                        $repoBefore = Get-GitHubRepository -Owner $owner -Name $repoName
                        $repo = Update-GitHubRepository -Owner $owner -Name $repoName -NewName $newName
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }
            LogGroup 'Changed properties: ' {
                $changes = Compare-PSCustomObject -Left $repoBefore -Right $repo -OnlyChanged
                Write-Host "$($changes | Format-Table | Out-String)"
                $repo | Should -Not -BeNullOrEmpty
                $repo.Name | Should -Be $newName
                $changedProps = $changes.Property
                $changedProps | Should -Contain 'UpdatedAt'
                $changedProps | Should -Contain 'Name'
                $changedProps | Should -Contain 'FullName'
                $changedProps | Should -Contain 'Url'
                $changedProps | Should -Contain 'UpdatedAt'
                $changedProps | Should -Contain 'CloneUrl'
                $changedProps | Should -Contain 'SshUrl'
                $changedProps | Should -Contain 'GitUrl'
                $changedProps.Count | Should -Be 8
            }
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
            switch ($OwnerType) {
                'user' {
                    $repos = Get-GitHubRepository -Username $Owner | Where-Object { $_.name -like "$repoName*" }
                }
                default {
                    $repos = Get-GitHubRepository -Organization $Owner | Where-Object { $_.name -like "$repoName*" }
                }
            }
            LogGroup 'Repositories' {
                Write-Host ($repos | Format-List | Out-String)
                $repos | Should -BeNullOrEmpty
            }
        }
        It 'Set-GitHubRepository - Creates and updates a repository from a template' -Skip:($OwnerType -eq 'repository') {
            $templateRepoName = "$repoName-template"
            $templateParams = @{
                Name               = $templateRepoName
                TemplateOwner      = 'PSModule'
                TemplateRepository = 'Template-Docs'
            }
            LogGroup 'Repository - Set create from template' {
                switch ($OwnerType) {
                    'user' {
                        $repo = Set-GitHubRepository @templateParams
                    }
                    'organization' {
                        $repo = Set-GitHubRepository @templateParams -Organization $owner
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }

            $newDescription = 'Updated description for template repo'
            LogGroup 'Repository - Set update from template' {
                $changeParams = @{
                    Description = $newDescription
                    HasIssues   = $false
                    HasWiki     = $false
                }
                switch ($OwnerType) {
                    'user' {
                        $repoBefore = Get-GitHubRepository -Name $templateRepoName
                        $updatedRepo = Set-GitHubRepository -Name $templateRepoName @changeParams
                    }
                    'organization' {
                        $repoBefore = Get-GitHubRepository -Owner $owner -Name $templateRepoName
                        $updatedRepo = Set-GitHubRepository -Organization $owner -Name $templateRepoName @changeParams
                    }
                }
                Write-Host ($updatedRepo | Format-List | Out-String)
            }
            LogGroup 'Changed properties:' {
                $changes = Compare-PSCustomObject -Left $repoBefore -Right $updatedRepo -OnlyChanged
                Write-Host "$($changes | Format-Table | Out-String)"
                $updatedRepo | Should -Not -BeNullOrEmpty
                $updatedRepo.Description | Should -Be $newDescription
                $changedProps = $changes.Property
                $changedProps | Should -Contain 'UpdatedAt'
                $changedProps | Should -Contain 'Description'
                $changedProps | Should -Contain 'HasIssues'
                $changedProps | Should -Contain 'HasWiki'
                $changedProps.Count | Should -Be 4
            }
        }
        It 'Set-GitHubRepository - Creates and updates a repository as a fork' -Skip:($OwnerType -eq 'repository') {
            $name = "$repoName-fork3"
            $forkParams = @{
                Name           = $name
                ForkOwner      = 'psmodule-test'
                ForkRepository = "fork-$os"
            }
            LogGroup 'Repository - Set create as fork' {
                switch ($OwnerType) {
                    'user' {
                        $repo = Set-GitHubRepository @forkParams
                    }
                    'organization' {
                        $repo = Set-GitHubRepository @forkParams -Organization $owner
                    }
                }
                Write-Host ($repo | Format-List | Out-String)
            }

            $newDescription = 'Updated description for forked repo'
            LogGroup 'Repository - Set update as fork' {
                $setParams = @{
                    Name            = $name
                    Description     = $newDescription
                    HasSponsorships = $true
                    HasIssues       = $true
                }
                switch ($OwnerType) {
                    'user' {
                        $updatedRepo = Set-GitHubRepository @setParams
                    }
                    'organization' {
                        $updatedRepo = Set-GitHubRepository -Organization $owner @setParams
                    }
                }
                Write-Host ($updatedRepo | Format-List | Out-String)
            }
            LogGroup 'Changed properties:' {
                $changes = Compare-PSCustomObject -Left $repo -Right $updatedRepo -OnlyChanged
                Write-Host "$($changes | Format-Table | Out-String)"
                $updatedRepo | Should -Not -BeNullOrEmpty
                $updatedRepo.Description | Should -Be $newDescription
                $changedProps = $changes.Property
                $changedProps | Should -Contain 'UpdatedAt'
                $changedProps | Should -Contain 'Description'
                $changedProps | Should -Contain 'HasSponsorships'
                $changedProps | Should -Contain 'HasIssues'
                $changedProps.Count | Should -Be 4
            }
        }
    }
}
