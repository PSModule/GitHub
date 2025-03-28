﻿#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

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
[CmdletBinding()]
param()

Describe 'GitHub' {
    Context 'Config' {
        It 'Get-GitHubConfig - Gets the module configuration' {
            $config = Get-GitHubConfig
            Write-Verbose ($config | Format-Table | Out-String) -Verbose
            $config | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubConfig - Gets a configuration item by name' {
            $config = Get-GitHubConfig
            $config.AccessTokenGracePeriodInHours | Should -Be 4
            $config.HostName | Should -Be 'github.com'
            $config.HttpVersion | Should -Be '2.0'
            $config.PerPage | Should -Be 100
        }
        It 'Set-GitHubConfig - Sets a configuration item' {
            Set-GitHubConfig -Name 'HostName' -Value 'msx.ghe.com'
            Get-GitHubConfig -Name 'HostName' | Should -Be 'msx.ghe.com'
        }
        It 'Remove-GitHubConfig - Removes a configuration item' {
            Remove-GitHubConfig -Name 'HostName'
            Get-GitHubConfig -Name 'HostName' | Should -BeNullOrEmpty
        }
        It 'Reset-GitHubConfig - Resets the module configuration' {
            Set-GitHubConfig -Name HostName -Value 'msx.ghe.com'
            Get-GitHubConfig -Name HostName | Should -Be 'msx.ghe.com'
            Reset-GitHubConfig
            Get-GitHubConfig -Name HostName | Should -Be 'github.com'
        }
    }
    Context 'Actions' {
        It 'Get-GitHubEventData - Gets data about the event that triggered the workflow' {
            $workflow = Get-GitHubEventData
            Write-Verbose ($workflow | Format-List | Out-String) -Verbose
            $workflow | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRunnerData - Gets data about the runner that is running the workflow' {
            $workflow = Get-GitHubRunnerData
            Write-Verbose ($workflow | Format-List | Out-String) -Verbose
            $workflow | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Status' -ForEach @('public', 'eu') {
        It 'Get-GitHubScheduledMaintenance - Gets scheduled maintenance for <_>' {
            { Get-GitHubScheduledMaintenance -Stamp $_ } | Should -Not -Throw
        }
        It 'Get-GitHubScheduledMaintenance - Gets active maintenance for <_>' {
            { Get-GitHubScheduledMaintenance -Stamp $_ -Active } | Should -Not -Throw
        }
        It 'Get-GitHubScheduledMaintenance - Gets upcoming maintenance for <_>' {
            { Get-GitHubScheduledMaintenance -Stamp $_ -Upcoming } | Should -Not -Throw
        }
        It 'Get-GitHubStatus - Gets all status for <_>' {
            { Get-GitHubStatus -Stamp $_ } | Should -Not -Throw
        }
        It 'Get-GitHubStatus - Gets summary status for <_>' {
            { Get-GitHubStatus -Stamp $_ -Summary } | Should -Not -Throw
        }
        It 'Get-GitHubStatusComponent - Gets the status of GitHub components for <_>' {
            { Get-GitHubStatusComponent -Stamp $_ } | Should -Not -Throw
        }
        It 'Get-GitHubStatusIncident - Gets the status of all GitHub incidents for <_>' {
            { Get-GitHubStatusIncident -Stamp $_ } | Should -Not -Throw
        }
        It 'Get-GitHubStatusIncident - Gets the status of unresolved GitHub incidents for <_>' {
            { Get-GitHubStatusIncident -Stamp $_ -Unresolved } | Should -Not -Throw
        }
    }
    Context 'Commands' {
        It 'Start-GitHubLogGroup - Should not throw' {
            {
                Start-GitHubLogGroup 'MyGroup'
            } | Should -Not -Throw
        }
        It 'Stop-LogGroup - Should not throw' {
            {
                Stop-GitHubLogGroup
            } | Should -Not -Throw
        }
        It 'Set-GitHubLogGroup - Should not throw' {
            {
                Set-GitHubLogGroup -Name 'MyGroup' -ScriptBlock {
                    Get-ChildItem env: | Select-Object Name, Value | Format-Table -AutoSize
                }
            } | Should -Not -Throw
        }
        It 'LogGroup - Should not throw' {
            {
                LogGroup 'MyGroup' {
                    Get-ChildItem env: | Select-Object Name, Value | Format-Table -AutoSize
                }
            } | Should -Not -Throw
        }
        It 'Add-GitHubMask - Should not throw' {
            {
                Add-GitHubMask -Value 'taskmaster'
            } | Should -Not -Throw
        }
        It 'Add-GitHubSystemPath - Should not throw' {
            {
                Add-GitHubSystemPath -Path $pwd.ToString()
            } | Should -Not -Throw
            Get-Content $env:GITHUB_PATH -Raw | Should -BeLike "*$($pwd.ToString())*"
        }
        It 'Disable-GitHubCommand - Should not throw' {
            {
                Disable-GitHubCommand -String 'MyString'
            } | Should -Not -Throw
        }
        It 'Enable-GitHubCommand - Should not throw' {
            {
                Enable-GitHubCommand -String 'MyString'
            } | Should -Not -Throw
        }
        It 'Set-GitHubNoCommandGroup - Should not throw' {
            {
                Set-GitHubNoCommandGroup {
                    Write-Output 'Hello, World!'
                }
            } | Should -Not -Throw
        }
        It 'Set-GitHubOutput + Simple string - Should not throw' {
            {
                Set-GitHubOutput -Name 'MyOutput' -Value 'MyValue'
            } | Should -Not -Throw
            (Get-GitHubOutput).MyOutput | Should -Be 'MyValue'
        }
        It 'Set-GitHubOutput + Multiline string - Should not throw' {
            {
                Set-GitHubOutput -Name 'MyOutput' -Value @'
This is a multiline
string
'@
            } | Should -Not -Throw
            (Get-GitHubOutput).MyOutput | Should -Be @'
This is a multiline
string
'@
        }
        It 'Set-GitHubOutput + SecureString - Should not throw' {
            {
                $secret = 'MyValue' | ConvertTo-SecureString -AsPlainText -Force
                Set-GitHubOutput -Name 'MySecret' -Value $secret
            } | Should -Not -Throw
            (Get-GitHubOutput).MySecret | Should -Be 'MyValue'
        }
        It 'Set-GitHubOutput + Object - Should not throw' {
            {
                $jupiter = [PSCustomObject]@{
                    Name          = 'Jupiter'
                    NumberOfMoons = 79
                    Moons         = @(@{ Name = 'Io'; Radius = 1821 }, @{ Name = 'Europa'; Radius = 1560 })
                    NumberOfRings = 4
                    RockyPlanet   = $false
                    Neighbors     = @('Mars', 'Saturn')
                    SomethingElse = [PSCustomObject]@{
                        Name  = 'Something'
                        Value = 'Else'
                    }
                }
                Set-GitHubOutput -Name 'Jupiter' -Value $jupiter
            } | Should -Not -Throw
            (Get-GitHubOutput).Config | Should -BeLike ''
        }
        It 'Get-GitHubOutput - Should not throw' {
            {
                Get-GitHubOutput
            } | Should -Not -Throw
            Write-Verbose (Get-GitHubOutput | Format-List | Out-String) -Verbose
        }
        It 'Set-GitHubEnvironmentVariable - Should not throw' {
            {
                Set-GitHubEnvironmentVariable -Name 'MyName' -Value 'MyValue'
            } | Should -Not -Throw
            Get-Content $env:GITHUB_ENV -Raw | Should -BeLike '*MyName*MyValue*'
        }
        It 'Set-GitHubStepSummary - Should not throw' {
            {
                Set-GitHubStepSummary -Summary 'MySummary'
            } | Should -Not -Throw
        }
        It 'Write-GitHub* - Should not throw' {
            { Write-GitHubDebug 'Debug' } | Should -Not -Throw
            { Write-GitHubError 'Error' } | Should -Not -Throw
            { Write-GitHubNotice 'Notice' } | Should -Not -Throw
            { Write-GitHubWarning 'Warning' } | Should -Not -Throw
        }
    }
    Context 'IssueParser' {
        BeforeAll {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            Write-Verbose "Reading from $issueTestFilePath" -Verbose
            $content = Get-Content -Path $issueTestFilePath -Raw
            Write-Verbose ($content | Out-String) -Verbose
            $dataObject = $content | ConvertFrom-IssueForm -Verbose
            Write-Verbose "As PSCustomObject" -Verbose
            Write-Verbose ($dataObject | Format-List | Out-String) -Verbose
            $dataHashtable = $content | ConvertFrom-IssueForm -AsHashtable -Verbose
            Write-Verbose "As Hashtable" -Verbose
            Write-Verbose ($dataHashtable | Out-String) -Verbose
        }

        It 'ConvertFrom-IssueForm - Should return a PSCustomObject' {
            $dataObject | Should -BeOfType 'PSCustomObject'
        }

        It 'ConvertFrom-IssueForm -AsHashtable - Should return a hashtable' {
            $dataHashtable | Should -BeOfType 'hashtable'
        }

        It "'Type with spaces' should contain 'Action'" {
            Write-Verbose ($dataHashtable['Type with spaces'] | Out-String) -Verbose
            $dataHashtable.Keys | Should -Contain 'Type with spaces'
            $dataHashtable['Type with spaces'] | Should -Be 'Action'
        }

        It "'Multiline' should contain a multiline string with 3 lines" {
            Write-Verbose ($dataHashtable['Multiline'] | Out-String) -Verbose
            $dataHashtable.Keys | Should -Contain 'Multiline'
            $dataHashtable['Multiline'] | Should -Be @'
test
is multi
line
'@
        }

        It "'OS' should contain a hashtable with 3 items" {
            Write-Verbose ($dataHashtable['OS'] | Out-String) -Verbose
            $dataHashtable.Keys | Should -Contain 'OS'
            $dataHashtable['OS'].Windows | Should -BeTrue
            $dataHashtable['OS'].Linux | Should -BeTrue
            $dataHashtable['OS'].Mac | Should -BeFalse
        }
    }
}
