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
            $Owner = $env:GITHUB_REPOSITORY_OWNER
            $Repository = $env:GITHUB_REPOSITORY_NAME
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

            It 'Get-GitHubOidcSubjectClaim - Organization - Returns template' {
                $result = Get-GitHubOidcSubjectClaim -Owner $Owner -Context $context
                LogGroup 'Result' {
                    Write-Host ($result | Format-List | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result.include_claim_keys | Should -Not -BeNullOrEmpty
            }

            It 'Get-GitHubOidcSubjectClaim - Repository - Returns template' {
                $result = Get-GitHubOidcSubjectClaim -Owner $Owner -Repository $Repository -Context $context
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

            It 'Set-GitHubOidcSubjectClaim - Repository - Sets template with custom keys' {
                {
                    Set-GitHubOidcSubjectClaim -Owner $Owner -Repository $Repository `
                        -IncludeClaimKeys @('repo', 'ref') -Context $context
                } | Should -Not -Throw
            }

            It 'Set-GitHubOidcSubjectClaim - Repository - Sets template with UseDefault' {
                {
                    Set-GitHubOidcSubjectClaim -Owner $Owner -Repository $Repository `
                        -IncludeClaimKeys @('repo') -UseDefault -Context $context
                } | Should -Not -Throw
            }
        }
    }
}
