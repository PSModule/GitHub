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
    $testName = 'Template'
    $os = $env:RUNNER_OS
    $id = $env:GITHUB_RUN_ID
}

Describe 'Template' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
            if ($AuthType -eq 'APP') {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                LogGroup 'Context - Installation' {
                    Write-Host ($context | Format-List | Out-String)
                }
            }

            # Ensure the shared test repository exists. Set-GitHubRepository is idempotent.
            $repoPrefix = "Test-$os-$TokenType"
            $repoName = "$repoPrefix-$id"
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
            }
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        It 'Should do something' -Skip:($OwnerType -in ('repository', 'enterprise')) {
            # Test logic using $repo, $Owner, $repoName
        }
    }
}
