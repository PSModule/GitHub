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
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidLongLines', '',
    Justification = 'Long test descriptions and skip switches'
)]
[CmdletBinding()]
param()

BeforeAll {
    # DEFAULTS ACCROSS ALL TESTS
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
                It 'Connect-GitHubApp - Connects as a GitHub App to <Owner>' {
                    $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
                    LogGroup 'Context - Installation' {
                        Write-Host ($context | Format-List | Out-String)
                    }
                }
            }
        }
        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        It 'Get-GitHubEnterprise - Can get info about an enterprise' -Skip:($OwnerType -notlike 'enterprise') {
            $enterprise = Get-GitHubEnterprise -Name $Owner
            LogGroup 'Enterprise' {
                Write-Host ($enterprise | Select-Object * | Out-String)
            }
            $enterprise | Should -Not -BeNullOrEmpty
            $enterprise | Should -BeOfType 'GitHubEnterprise'
            $enterprise.Name | Should -Be 'msx'
            $enterprise.DisplayName | Should -Be 'MSX'
            $enterprise.ID | Should -Be 15567
            $enterprise.NodeID | Should -Be 'E_kgDNPM8'
            $enterprise.AvatarUrl | Should -Be 'https://avatars.githubusercontent.com/b/15567?v=4'
            $enterprise.BillingEmail | Should -Be 'marstor@hotmail.com'
            $enterprise.Url | Should -Be 'https://github.com/enterprises/msx'
            $enterprise.Type | Should -Be 'Enterprise'
            $enterprise.BillingInfo | Should -BeOfType 'GitHubBillingInfo'
            $enterprise.BillingInfo.AllLicensableUsersCount | Should -Be 1
            $enterprise.BillingInfo.AssetPacks | Should -Be 0
            $enterprise.BillingInfo.BandwidthQuota | Should -Be 5
            $enterprise.BillingInfo.BandwidthUsage | Should -Be 0
            $enterprise.BillingInfo.BandwidthUsagePercentage | Should -Be 0
            $enterprise.BillingInfo.StorageQuota | Should -Be 5
            $enterprise.BillingInfo.StorageUsage | Should -Be 0
            $enterprise.BillingInfo.StorageUsagePercentage | Should -Be 0
            $enterprise.BillingInfo.TotalAvailableLicenses | Should -Be 0
            $enterprise.BillingInfo.TotalLicenses | Should -Be 1
            $enterprise.Readme | Should -Be 'This is a test'
            $enterprise.ReadmeHTML | Should -Be '<p>This is a test</p>'
            $enterprise.CreatedAt | Should -BeOfType 'DateTime'
            $enterprise.CreatedAt | Should -Be (Get-Date '18.09.2022 19:53:09')
            $enterprise.UpdatedAt | Should -BeOfType 'DateTime'
            $enterprise.Description | Should -Be 'This is the description'
            $enterprise.DescriptionHTML | Should -Be '<div>This is the description</div>'
            $enterprise.Location | Should -Be 'Oslo, Norway'
            $enterprise.Blog | Should -Be 'https://msx.no'
        }
    }
}
