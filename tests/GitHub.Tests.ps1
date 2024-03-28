[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Describe 'GitHub' {
    Context 'Module' {
        It 'The module should be available' {
            Get-Module -Name 'GitHub' -ListAvailable | Should -Not -BeNullOrEmpty
            Write-Verbose (Get-Module -Name 'GitHub' -ListAvailable | Out-String) -Verbose
        }
        It 'The module should be imported' {
            { Import-Module -Name 'GitHub' -Verbose -RequiredVersion 999.0.0 -Force } | Should -Not -Throw
        }
    }
}
