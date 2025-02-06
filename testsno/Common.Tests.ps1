#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }
#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[CmdletBinding()]
param()

BeforeAll {
    Get-SecretInfo | Remove-Secret
    Get-SecretVault | Unregister-SecretVault
    Get-Module -ListAvailable -Name Context | Sort-Object -Property Version | Select-Object -Last 1 | Import-Module -Force
}

Describe 'Common' {
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
            Write-Verbose ($workflow | Format-Table | Out-String) -Verbose
            $workflow | Should -Not -BeNullOrEmpty
        }
        It 'Get-GitHubRunnerData - Gets data about the runner that is running the workflow' {
            $workflow = Get-GitHubRunnerData
            Write-Verbose ($workflow | Format-Table | Out-String) -Verbose
            $workflow | Should -Not -BeNullOrEmpty
        }
    }
    Context 'Auth' {
        It 'Connect-GitHubAccount - Connects GitHub Actions without parameters' {
            { Connect-GitHubAccount } | Should -Not -Throw
        }
        It 'Disconnect-GitHubAccount - Disconnects GitHub Actions' {
            { Disconnect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Passes the context to the pipeline' {
            $context = Connect-GitHubAccount -PassThru
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
            $context | Should -Not -BeNullOrEmpty
        }
        It 'Connect-GitHubAccount - Connects with default settings' {
            $context = Get-GitHubContext
            Write-Verbose ($context | Select-Object -Property * | Out-String) -Verbose
            $context | Should -Not -BeNullOrEmpty
            $context.ApiBaseUri | Should -Be 'https://api.github.com'
            $context.ApiVersion | Should -Be '2022-11-28'
            $context.AuthType | Should -Be 'IAT'
            $context.HostName | Should -Be 'github.com'
            $context.HttpVersion | Should -Be '2.0'
            $context.TokenType | Should -Be 'ghs'
            $context.Name | Should -Be 'github.com/github-actions/Organization/PSModule'
        }
        It 'Disconnect-GitHubAccount - Disconnects the context from the pipeline' {
            $context = Get-GitHubContext
            { $context | Disconnect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Connects GitHub Actions even if called multiple times' {
            { Connect-GitHubAccount } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw
        }
        It 'Connect-GitHubAccount - Connects multiple contexts, GitHub Actions and a user via classic PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            { Connect-GitHubAccount -Token $env:TEST_USER_PAT } | Should -Not -Throw
            { Connect-GitHubAccount } | Should -Not -Throw
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
            Write-Verbose (Get-GitHubContext | Out-String) -Verbose
        }
        It 'Connect-GitHubAccount - Reconfigures an existing user context to be a fine-grained PAT token' {
            { Connect-GitHubAccount -Token $env:TEST_USER_USER_FG_PAT } | Should -Not -Throw
            (Get-GitHubContext -ListAvailable).Count | Should -Be 2
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
        }
        It 'Connect-GitHubAccount - Connects a GitHub App from an organization' {
            $params = @{
                ClientID   = $env:TEST_APP_ORG_CLIENT_ID
                PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
        }
        It 'Connect-GitHubAccount - Connects all of a (org) GitHub Apps installations' {
            $params = @{
                ClientID   = $env:TEST_APP_ORG_CLIENT_ID
                PrivateKey = $env:TEST_APP_ORG_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 7
        }
        It 'Connect-GitHubAccount - Connects a GitHub App from an enterprise' {
            $params = @{
                ClientID   = $env:TEST_APP_ENT_CLIENT_ID
                PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 8
        }
        It 'Connect-GitHubAccount - Connects all of a (ent) GitHub Apps installations' {
            $params = @{
                ClientID   = $env:TEST_APP_ENT_CLIENT_ID
                PrivateKey = $env:TEST_APP_ENT_PRIVATE_KEY
            }
            { Connect-GitHubAccount @params -AutoloadInstallations } | Should -Not -Throw
            $contexts = Get-GitHubContext -ListAvailable -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 12
        }
        It 'Disconnect-GitHubAccount - Disconnects a specific context' {
            { Disconnect-GitHubAccount -Context 'github.com/psmodule-enterprise-app/Organization/PSModule' -Silent } | Should -Not -Throw
            $contexts = Get-GitHubContext -Context 'github.com/psmodule-enterprise-app/*' -Verbose:$false
            Write-Verbose ($contexts | Out-String) -Verbose
            ($contexts).Count | Should -Be 3
        }
    }
    Context 'DefaultContext' {
        BeforeAll {
            Connect-GitHub
        }
        It 'Set-GitHubDefaultContext - Can swap context to another' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { Set-GitHubDefaultContext -Context 'github.com/github-actions/Organization/PSModule' } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/github-actions/Organization/PSModule'
        }

        It 'Set-GitHubDefaultContext - Can swap context to another using pipeline - String' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { 'github.com/psmodule-user' | Set-GitHubDefaultContext } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/psmodule-user'
        }

        It 'Set-GitHubDefaultContext - Can swap context to another using pipeline - Context object' {
            Write-Verbose (Get-GitHubContext -ListAvailable | Out-String) -Verbose
            { Get-GitHubContext -Context 'github.com/psmodule-org-app' | Set-GitHubDefaultContext } | Should -Not -Throw
            Get-GitHubConfig -Name 'DefaultContext' | Should -Be 'github.com/psmodule-org-app'
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
            (Get-GitHubOutput).result.MyOutput | Should -Be 'MyValue'
        }
        It 'Set-GitHubOutput + Multiline string - Should not throw' {
            {
                Set-GitHubOutput -Name 'MyOutput' -Value @'
This is a multiline
string
'@
            } | Should -Not -Throw
            (Get-GitHubOutput).result.MyOutput | Should -Be @'
This is a multiline
string
'@
        }
        It 'Set-GitHubOutput + SecureString - Should not throw' {
            {
                $secret = 'MyValue' | ConvertTo-SecureString -AsPlainText -Force
                Set-GitHubOutput -Name 'MySecret' -Value $secret
            } | Should -Not -Throw
            (Get-GitHubOutput).result.MySecret | Should -Be 'MyValue'
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
            (Get-GitHubOutput).result.Config | Should -BeLike ''
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
        It 'ConvertFrom-IssueForm - Should return a PSCustomObject' {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm
            Write-Verbose ($data | Format-Table | Out-String) -Verbose
            $data | Should -BeOfType 'PSCustomObject'
        }

        It 'ConvertFrom-IssueForm -AsHashtable - Should return a hashtable' {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm -AsHashtable
            Write-Verbose ($data | Out-String) -Verbose
            $data | Should -BeOfType 'hashtable'
        }

        It "'Type with spaces' should contain 'Action'" {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm -AsHashtable
            Write-Verbose ($data['Type with spaces'] | Out-String) -Verbose
            $data.Keys | Should -Contain 'Type with spaces'
            $data['Type with spaces'] | Should -Be 'Action'
        }

        It "'Multiline' should contain a multiline string with 3 lines" {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm -AsHashtable
            Write-Verbose ($data['Multiline'] | Out-String) -Verbose
            $data.Keys | Should -Contain 'Multiline'
            $data['Multiline'] | Should -Be @'
test
is multi
line
'@
        }

        It "'OS' should contain a hashtable with 3 items" {
            $issueTestFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'IssueForm.md'
            $data = Get-Content -Path $issueTestFilePath -Raw | ConvertFrom-IssueForm -AsHashtable
            Write-Verbose ($data['OS'] | Out-String) -Verbose
            $data.Keys | Should -Contain 'OS'
            $data['OS'].Windows | Should -BeTrue
            $data['OS'].Linux | Should -BeTrue
            $data['OS'].Mac | Should -BeFalse
        }
    }
    Context 'Disconnect' {
        It 'Disconnect-GitHubAccount - Can disconnect all context through the pipeline' {
            { Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount } | Should -Not -Throw
            Get-GitHubContext -ListAvailable | Should -HaveCount 0
        }
    }
}
