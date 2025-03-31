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
    $Owner = $env:GITHUB_REPOSITORY_OWNER
    $Repository = $env:GITHUB_REPOSITORY_NAME
    $ID = $env:GITHUB_RUN_ID
    $ArtifactName = 'module'
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
                LogGroup 'Context - Installation' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    Write-Host ($context | Format-List | Out-String)
                }
            }
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        It 'Get-GitHubArtifact - Gets the artifacts for a repository' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            $result = Get-GitHubArtifact @params
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -HaveCount 1
        }

        It 'Get-GitHubArtifact - Gets the artifact for the workflow run' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                ID         = $ID
                Name       = $ArtifactName
            }
            $result = Get-GitHubArtifact @params
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -HaveCount 1
        }

        It 'Get-GitHubArtifact - Gets a specific artifact' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                ID         = $ID
                Name       = $ArtifactName
            }
            $artifact = Get-GitHubArtifact @params
            LogGroup 'Artifact' {
                Write-Host ($artifact | Format-List | Out-String)
            }
            $result = Get-GitHubArtifact -Owner $Owner -Repository $Repository -ArtifactID $artifact.DatabaseID
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Save-GitHubArtifact - Saves the artifact to disk' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            $result = Get-GitHubArtifact @params | Save-GitHubArtifact
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Save-GitHubArtifact - Saves the artifact to disk, extract and cleanup' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            $result = Get-GitHubArtifact @params | Save-GitHubArtifact -Expand -Cleanup
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Save-GitHubArtifact - Saves the artifact to disk, extract and cleanup to a specific path' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            $result = Get-GitHubArtifact @params | Save-GitHubArtifact -Path $env:TEMP -Expand -Cleanup
            LogGroup 'Result' {
                Write-Host ($result | Format-List | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [System.IO.FileInfo]
        }

        It 'Remove-GitHubArtifact - Removes the artifact from the repository' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            { Get-GitHubArtifact @params | Remove-GitHubArtifact -WhatIf } | Should -Not -Throw
        }
    }
}
