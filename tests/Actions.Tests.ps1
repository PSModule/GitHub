#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
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
    $testName = 'Actions'
    $os = $env:RUNNER_OS
    $id = $env:GITHUB_RUN_ID
    if (-not $id) {
        throw 'GITHUB_RUN_ID is required for Actions tests because it is used to build repository-scoped names for OIDC operations.'
    }
}

Describe 'Actions' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'GitHubWorkflowRun' {
        It 'Constructor should populate properties from $Object parameter, not from $_' {
            # Build a minimal mock object matching the GitHub REST API workflow-run response shape.
            # The constructor is called outside ForEach-Object so $_ is $null.
            # If the constructor incorrectly references $_ instead of $Object, scalar properties will be empty.
            $mockOwner = [PSCustomObject]@{
                id         = 1
                node_id    = 'MDQ6VXNlcjE='
                login      = 'octocat'
                avatar_url = 'https://github.com/images/error/octocat_happy.gif'
                html_url   = 'https://github.com/octocat'
                type       = 'User'
            }

            $mockRepo = [PSCustomObject]@{
                id        = 100
                node_id   = 'MDEwOlJlcG9zaXRvcnkxMDA='
                name      = 'hello-world'
                full_name = 'octocat/hello-world'
                owner     = $mockOwner
                html_url  = 'https://github.com/octocat/hello-world'
            }

            $mockUser = [PSCustomObject]@{
                id         = 1
                node_id    = 'MDQ6VXNlcjE='
                login      = 'octocat'
                avatar_url = 'https://github.com/images/error/octocat_happy.gif'
                html_url   = 'https://github.com/octocat'
                type       = 'User'
            }

            $mockRun = [PSCustomObject]@{
                id                   = 42
                node_id              = 'MDExOldvcmtmbG93UnVuNDI='
                name                 = 'CI Build'
                check_suite_id       = 99
                check_suite_node_id  = 'MDEwOkNoZWNrU3VpdGU5OQ=='
                head_branch          = 'main'
                head_sha             = '009b8a3a9ccbb128af87f9b1c0f4c62e8a304f6d'
                path                 = '.github/workflows/ci.yml'
                run_number           = 106
                run_attempt          = 1
                event                = 'push'
                status               = 'completed'
                conclusion           = 'success'
                workflow_id          = 5
                html_url             = 'https://github.com/octocat/hello-world/actions/runs/42'
                display_title        = 'CI Build'
                created_at           = '2023-01-01T12:00:00Z'
                updated_at           = '2023-01-01T12:05:00Z'
                run_started_at       = '2023-01-01T12:01:00Z'
                pull_requests        = @()
                referenced_workflows = @()
                repository           = $mockRepo
                head_repository      = $mockRepo
                actor                = $mockUser
                triggering_actor     = $mockUser
                head_commit          = [PSCustomObject]@{ id = 'abc123'; message = 'Test commit' }
            }

            $result = [GitHubWorkflowRun]::new($mockRun)

            $result.ID              | Should -Be 42
            $result.NodeID          | Should -Be 'MDExOldvcmtmbG93UnVuNDI='
            $result.Name            | Should -Be 'CI Build'
            $result.CheckSuiteID    | Should -Be 99
            $result.CheckSuiteNodeID | Should -Be 'MDEwOkNoZWNrU3VpdGU5OQ=='
            $result.HeadBranch      | Should -Be 'main'
            $result.HeadSha         | Should -Be '009b8a3a9ccbb128af87f9b1c0f4c62e8a304f6d'
            $result.Path            | Should -Be '.github/workflows/ci.yml'
            $result.RunNumber       | Should -Be 106
            $result.RunAttempt      | Should -Be 1
            $result.Event           | Should -Be 'push'
            $result.Status          | Should -Be 'completed'
            $result.Conclusion      | Should -Be 'success'
            $result.WorkflowID      | Should -Be 5
            $result.Url             | Should -Be 'https://github.com/octocat/hello-world/actions/runs/42'
            $result.DisplayTitle    | Should -Be 'CI Build'
        }
    }

    Context 'OIDC' {
        Context 'Get-GitHubOidcClaim' {
            It 'Get-GitHubOidcClaim - No context - Returns claim keys for github.com' {
                $result = Get-GitHubOidcClaim
                LogGroup 'Result' {
                    Write-Host ($result | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Contain 'sub'
                $result | Should -Contain 'repository'
                $result | Should -BeOfType [string]
            }
        }
    }

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
            $repoPrefix = "Test-$os-$TokenType"
            $repoName = "$repoPrefix-$id"

            LogGroup "Using Repository - [$repoName]" {
                if ($OwnerType -in ('repository', 'enterprise')) {
                    $repo = $null
                } else {
                    $repoParams = @{
                        Name      = $repoName
                        AddReadme = $true
                        License   = 'mit'
                        Gitignore = 'VisualStudio'
                    }
                    $repo = switch ($OwnerType) {
                        'user' { Set-GitHubRepository @repoParams }
                        'organization' { Set-GitHubRepository @repoParams -Organization $Owner }
                    }
                    Write-Host ($repo | Select-Object * | Out-String)
                }
            }
        }

        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        Context 'OIDC' {
            It 'Get-GitHubOidcClaim - With context - Returns claim keys' {
                $result = Get-GitHubOidcClaim -Context $context
                LogGroup 'Result' {
                    Write-Host ($result | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Contain 'sub'
                $result | Should -BeOfType [string]
            }

            It 'Get-GitHubOidcSubjectClaim - Organization - Returns template' -Skip:($OwnerType -ne 'organization') {
                $result = Get-GitHubOidcSubjectClaim -Owner $Owner -Context $context
                LogGroup 'Result' {
                    Write-Host ($result | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result.include_claim_keys | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubOidcSubjectClaim - Repository - Returns template' -Skip:($OwnerType -in ('repository', 'enterprise')) {
                $result = Get-GitHubOidcSubjectClaim -Owner $Owner -Repository $repoName -Context $context
                LogGroup 'Result' {
                    Write-Host ($result | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
            }

            It 'Set-GitHubOidcSubjectClaim - Organization - Sets template' -Skip:($OwnerType -ne 'organization') {
                {
                    Set-GitHubOidcSubjectClaim -Owner $Owner -IncludeClaimKeys @('repo', 'context') -Context $context
                } | Should -Not -Throw
            }

            It 'Set-GitHubOidcSubjectClaim - Repository - Sets template with custom keys' -Skip:($OwnerType -in ('repository', 'enterprise')) {
                {
                    Set-GitHubOidcSubjectClaim -Owner $Owner -Repository $repoName `
                        -IncludeClaimKeys @('repo', 'ref') -Context $context
                } | Should -Not -Throw
            }

            It 'Set-GitHubOidcSubjectClaim - Repository - Sets template with UseDefault' -Skip:($OwnerType -in ('repository', 'enterprise')) {
                {
                    Set-GitHubOidcSubjectClaim -Owner $Owner -Repository $repoName `
                        -IncludeClaimKeys @('repo') -UseDefault -Context $context
                } | Should -Not -Throw
            }
        }
    }
}
