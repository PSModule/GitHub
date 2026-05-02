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
    . "$PSScriptRoot/Data/SharedTestRepositories.ps1"
}

Describe 'Actions' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

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
                    # Declarative get-or-create so partial reruns (issue #590) can rebuild
                    # the shared repository if AfterAll already tore it down.
                    $repo = Initialize-SharedTestRepository -Owner $Owner -OwnerType $OwnerType -Name $repoName
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
