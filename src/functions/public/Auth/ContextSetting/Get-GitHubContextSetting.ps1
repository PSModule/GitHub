#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '3.0.4' }

function Get-GitHubContextSetting {
    <#
        .SYNOPSIS
        Get a module configuration value.

        .DESCRIPTION
        Get a named configuration value from the GitHub config.

        .EXAMPLE
        Get-GitHubContextSetting -Name DefaultUser

        Get the current GitHub configuration for the DefaultUser.
    #>
    [OutputType([object])]
    [CmdletBinding()]
    param(
        # Choose a configuration name to get.
        [Parameter()]
        [string] $Name,

        # The name of the context.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    $contextID = "$($script:Config.Name)/$Context"

    if (-not $Name) {
        Get-Context -ID $contextID
    }

    Get-ContextSetting -Name $Name -ID $contextID

    Write-Verbose "[$commandName] - End"
}

Register-ArgumentCompleter -CommandName Get-GitHubContext -ParameterName Context -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubContext -ListAvailable | Where-Object { $_.ContextID -like "$wordToComplete*" } -Verbose:$false |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.ContextID, $_.ContextID, 'ParameterValue', $_.ContextID)
        }
}
