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
    # DEFAULTS ACCROSS ALL TESTS
}

Describe 'Actions' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            if ($AuthType -eq 'APP') {
                It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    LogGroup 'Context' {
                        Write-Host ($context | Format-List | Out-String)
                    }
                }
            }
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        It 'Get-GitHubArtifact - Gets the artifacts for a repository' {
            $params = @{
                Owner      = $env:GITHUB_REPOSITORY_OWNER
                Repository = $env:GITHUB_REPOSITORY_NAME
                Name       = 'module'
            }
            $result = Get-GitHubArtifact @params
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -HaveCount 1
        }

        It 'Get-GitHubArtifact - Gets the artifact for the workflow run' {
            $params = @{
                Owner      = $env:GITHUB_REPOSITORY_OWNER
                Repository = $env:GITHUB_REPOSITORY_NAME
                ID         = $env:GITHUB_RUN_ID
                Name       = 'module'
            }
            $result = Get-GitHubArtifact @params
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -HaveCount 1
        }

        It 'Get-GitHubArtifact - Gets a specific artifact' {
            $params = @{
                Owner      = $env:GITHUB_REPOSITORY_OWNER
                Repository = $env:GITHUB_REPOSITORY_NAME
                ArtifactID = $env:GITHUB_RUN_ID
                Name       = 'module'
            }
            $result = Get-GitHubArtifact @params -Name 'module'
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
