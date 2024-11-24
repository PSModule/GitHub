#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '3.1.0' }

function Get-GitHubContext {
    <#
        .SYNOPSIS
        Get the current GitHub context.

        .DESCRIPTION
        Get the current GitHub context.

        .EXAMPLE
        Get-GitHubContext

        Gets the current GitHub context.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Encapsulated in a function. Never leaves as a plain text.'
    )]
    [OutputType([GitHubContext])]
    [CmdletBinding(DefaultParameterSetName = 'CurrentContext')]
    param(
        # The name of the context.
        [Parameter(
            Mandatory,
            ParameterSetName = 'NamedContext'
        )]
        [Alias('Name')]
        [string] $Context,

        # List all available contexts.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ListAvailableContexts'
        )]
        [switch] $ListAvailable
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    if ($ListAvailable) {
        $ID = "$($script:Config.Name)/*"
        Write-Verbose "Getting available contexts for [$ID]"
    } elseif ($Context) {
        $ID = "$($script:Config.Name)/$Context"
        Write-Verbose "Getting available contexts for [$ID]"
    } else {
        $config = Get-GitHubConfig
        $Context = $config.DefaultContext
        if ([string]::IsNullOrEmpty($Context)) {
            throw "No default GitHub context found. Please run 'Set-GitHubDefaultContext' or 'Connect-GitHub' to configure a GitHub context."
        }
        $ID = "$($script:Config.Name)/$Context"
        Write-Verbose "Getting the default context: [$ID]"
    }

    Get-Context -ID $ID | ForEach-Object {
        [GitHubContext]$_
    }

    Write-Verbose "[$commandName] - End"
}

Register-ArgumentCompleter -CommandName Get-GitHubContext -ParameterName Context -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubContext -ListAvailable | Where-Object { $_.ID -like "$wordToComplete*" } -Verbose:$false |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.ID, $_.ID, 'ParameterValue', $_.ID)
        }
}
