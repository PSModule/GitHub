#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSAvoidUsingConvertToSecureStringWithPlainText', '',
    Justification = 'Used to create a secure string for testing.'
)]
[CmdletBinding()]
param()

Describe 'IssueParser' {
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
