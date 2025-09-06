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

Describe 'Artifacts' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-Table | Out-String)
            }
            if ($AuthType -eq 'APP') {
                LogGroup 'Context - Installation' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    Write-Host ($context | Format-Table | Out-String)
                }
            }
            $Owner = $env:GITHUB_REPOSITORY_OWNER
            $Repository = $env:GITHUB_REPOSITORY_NAME
            $WorkflowRunId = $env:GITHUB_RUN_ID
            $ArtifactName = 'module'
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        Context 'Repository' {
            It 'Get-GitHubArtifact - Repository - All artifacts - Latest version' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                }
                $result = Get-GitHubArtifact @params
                LogGroup 'Result' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubArtifact]
            }

            It 'Get-GitHubArtifact - Repository - All artifacts - All versions' {
                $params = @{
                    Owner       = $Owner
                    Repository  = $Repository
                    AllVersions = $true
                }
                $result = Get-GitHubArtifact @params
                LogGroup 'Result' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubArtifact]
            }

            It 'Get-GitHubArtifact - Repository - Named artifact - Latest version' {
                $params = @{
                    Owner      = $Owner
                    Repository = $Repository
                    Name       = $ArtifactName
                }
                $result = Get-GitHubArtifact @params
                LogGroup 'Result' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -HaveCount 1
                $result | Should -BeOfType [GitHubArtifact]
            }

            It 'Get-GitHubArtifact - Repository - Named artifact - All versions' {
                $params = @{
                    Owner       = $Owner
                    Repository  = $Repository
                    Name        = $ArtifactName
                    AllVersions = $true
                }
                $result = Get-GitHubArtifact @params
                LogGroup 'Result' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubArtifact]
            }
        }

        Context 'WorkflowRun' {
            It 'Get-GitHubArtifact - WorkflowRun - All artifacts - Latest version' {
                $params = @{
                    Owner         = $Owner
                    Repository    = $Repository
                    WorkflowRunId = $WorkflowRunId
                }
                $result = Get-GitHubArtifact @params
                LogGroup 'Result' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubArtifact]
            }

            It 'Get-GitHubArtifact - WorkflowRun - All artifacts - All versions' {
                $params = @{
                    Owner         = $Owner
                    Repository    = $Repository
                    WorkflowRunId = $WorkflowRunId
                    AllVersions   = $true
                }
                $result = Get-GitHubArtifact @params
                LogGroup 'Result' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubArtifact]
            }

            It 'Get-GitHubArtifact - WorkflowRun - Named artifact - Latest version' {
                $params = @{
                    Owner         = $Owner
                    Repository    = $Repository
                    WorkflowRunId = $WorkflowRunId
                    Name          = $ArtifactName
                }
                $result = Get-GitHubArtifact @params
                LogGroup 'Result' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -HaveCount 1
                $result | Should -BeOfType [GitHubArtifact]
            }

            It 'Get-GitHubArtifact - WorkflowRun - Named artifact - All versions' {
                $params = @{
                    Owner         = $Owner
                    Repository    = $Repository
                    WorkflowRunId = $WorkflowRunId
                    Name          = $ArtifactName
                    AllVersions   = $true
                }
                $result = Get-GitHubArtifact @params
                LogGroup 'Result' {
                    Write-Host ($result | Format-Table | Out-String)
                }
                $result | Should -Not -BeNullOrEmpty
                $result | Should -BeOfType [GitHubArtifact]
            }
        }

        It 'Get-GitHubArtifact - Gets a specific artifact' {
            $params = @{
                Owner         = $Owner
                Repository    = $Repository
                WorkflowRunId = $WorkflowRunId
                Name          = $ArtifactName
            }
            $artifact = Get-GitHubArtifact @params
            LogGroup 'Artifact' {
                Write-Host ($artifact | Format-Table | Out-String)
            }
            $result = Get-GitHubArtifact -Owner $Owner -Repository $Repository -ID $artifact.ID
            LogGroup 'Result' {
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [GitHubArtifact]
        }

        It 'GitHubArtifact.Size - Stores size in bytes (nullable UInt64)' {
            $params = @{
                Owner         = $Owner
                Repository    = $Repository
                WorkflowRunId = $WorkflowRunId
                Name          = $ArtifactName
            }
            $artifact = Get-GitHubArtifact @params
            LogGroup 'Artifact Size Test' {
                Write-Host "$($artifact | Format-Table -AutoSize | Out-String)"
            }
            if ($null -ne $artifact.Size) {
                $artifact.Size | Should -BeOfType [System.UInt64]
            } else {
                $artifact.Size | Should -BeNullOrEmpty
            }
        }

        It 'Save-GitHubArtifact - Saves the artifact to disk' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            LogGroup 'Artifact' {
                $artifact = Get-GitHubArtifact @params
                Write-Host ($artifact | Format-Table | Out-String)
            }
            LogGroup 'Result' {
                $result = $artifact | Save-GitHubArtifact -PassThru -Force
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [System.IO.FileSystemInfo]
        }

        It 'Save-GitHubArtifact - Saves the artifact to disk, extract and cleanup' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            LogGroup 'Artifact' {
                $artifact = Get-GitHubArtifact @params
                Write-Host ($artifact | Format-Table | Out-String)
            }
            LogGroup 'Result' {
                $result = $artifact | Save-GitHubArtifact -Expand -PassThru -Force
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [System.IO.FileSystemInfo]
        }

        It 'Save-GitHubArtifact - Saves the artifact to disk, extract and cleanup to a specific path - using wildcard' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = 'm*ule'
            }
            LogGroup 'Artifact' {
                $artifact = Get-GitHubArtifact @params
                Write-Host ($artifact | Format-Table | Out-String)
            }
            LogGroup 'Result' {
                $result = $artifact | Save-GitHubArtifact -Path .\testfolder -Expand -PassThru -Force
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [System.IO.FileSystemInfo]
        }

        It 'Save-GitHubArtifact - Saves the artifact to disk, extract and cleanup to a specific path' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            LogGroup 'Artifact' {
                $artifact = Get-GitHubArtifact @params
                Write-Host ($artifact | Format-Table | Out-String)
            }
            LogGroup 'Result' {
                $result = $artifact | Save-GitHubArtifact -Path .\testfolder -Expand -PassThru -Force
                Write-Host ($result | Format-Table | Out-String)
            }
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [System.IO.FileSystemInfo]
        }

        It 'Remove-GitHubArtifact - Removes the artifact from the repository' {
            $params = @{
                Owner      = $Owner
                Repository = $Repository
                Name       = $ArtifactName
            }
            LogGroup 'Artifact' {
                $artifact = Get-GitHubArtifact @params
                Write-Host ($artifact | Format-Table | Out-String)
            }
            { $artifact | Remove-GitHubArtifact -WhatIf } | Should -Not -Throw
        }
    }
}
