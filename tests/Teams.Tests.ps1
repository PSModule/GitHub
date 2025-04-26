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
    $testName = 'TeamsTests'
    $os = $env:RUNNER_OS
    $guid = [guid]::NewGuid().ToString()
}

Describe 'Teams' {
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
            $teamPrefix = ("$testName`_$os`_$TokenType`_$guid" -replace '-', '_').ToUpper()
        }

        AfterAll {
            switch ($OwnerType) {
                'organization' {
                    $teamsToRemove = Get-GitHubTeam -Organization $owner | Where-Object { $_.Name -like "$teamPrefix*" }
                    LogGroup 'Teams to remove' {
                        Write-Host "$($teamsToRemove | Format-List | Out-String)"
                    }
                    $teamsToRemove | Remove-GitHubTeam -Confirm:$false
                }
            }
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        Context 'Organization' -Skip:($OwnerType -ne 'organization') {
            BeforeAll {
                $scope = @{
                    Organization = $owner
                }
            }

            It 'New-GitHubTeam - Creates a new team' {
                $teamName = "$teamPrefix`_NewTeam"
                $teamDescription = 'This is a test team.'
                $team = New-GitHubTeam @scope -Name $teamName -Description $teamDescription
                LogGroup 'New Team' {
                    Write-Host ($team | Format-List | Out-String)
                }
                $team | Should -Not -BeNullOrEmpty
                $team.Name | Should -Be $teamName
                $team.Description | Should -Be $teamDescription
            }

            It 'Get-GitHubTeam - Gets a team' {
                $teamName = "$teamPrefix`_NewTeam"
                $team = Get-GitHubTeam -Organization $owner -Slug $teamName
                LogGroup 'Get Team' {
                    Write-Host ($team | Format-List | Out-String)
                }
                $team | Should -Not -BeNullOrEmpty
                $team.Name | Should -Be $teamName
            }

            It 'New-GitHubTeam - Creates 5 new teams' {
                1..5 | ForEach-Object {
                    $teamName = "$teamPrefix`_NewTeam_$_"
                    $teamDescription = 'This is a test team.'
                    $team = New-GitHubTeam @scope -Name $teamName -Description $teamDescription
                    LogGroup 'New Team' {
                        Write-Host ($team | Format-List | Out-String)
                    }
                    $team | Should -Not -BeNullOrEmpty
                    $team.Name | Should -Be $teamName
                    $team.Description | Should -Be $teamDescription
                }
            }

            It 'Get-GitHubTeam - Gets all teams' {
                $teams = Get-GitHubTeam -Organization $owner
                LogGroup 'Get All Teams' {
                    Write-Host ($teams | Format-List | Out-String)
                }
                $teams | Should -Not -BeNullOrEmpty
                $teams.Count | Should -BeGreaterThan 0
            }

            It 'Update-GitHubTeam - Updates a team' {
                $teamName = "$teamPrefix`_NewTeam"
                $newTeamName = "$teamPrefix`_UpdatedTeam"
                $teamDescription = 'This is an updated test team.'
                $team = Update-GitHubTeam @scope -Slug $teamName -NewName $newTeamName -Description $teamDescription
                LogGroup 'Update Team' {
                    Write-Host ($team | Format-List | Out-String)
                }
                $team | Should -Not -BeNullOrEmpty
                $team.Name | Should -Be $newTeamName
                $team.Description | Should -Be $teamDescription
            }

            It 'Remove-GitHubTeam - Removes a team' {
                $teamName = "$teamPrefix`_UpdatedTeam"
                $team = Get-GitHubTeam -Organization $owner -Slug $teamName
                LogGroup 'Remove Team' {
                    Write-Host ($team | Format-List | Out-String)
                }
                $team | Should -Not -BeNullOrEmpty
                $team.Name | Should -Be $teamName
                Remove-GitHubTeam @scope -Slug $teamName -Confirm:$false
            }
        }
    }
}
