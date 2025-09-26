#Requires -Modules @{ ModuleName = 'TimeSpan'; RequiredVersion = '3.0.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains long links.')]
[CmdletBinding()]
param()

function Get-LocalModule {
    $MyInvocation.MyCommand.Module
}
$script:Module = Get-LocalModule
