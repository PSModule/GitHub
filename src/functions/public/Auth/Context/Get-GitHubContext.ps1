#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.1' }

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
        $ID = "$($script:GitHub.Config.ID)/*"
        Write-Verbose "Getting available contexts for [$ID]"
    } elseif ($Context) {
        $ID = "$($script:GitHub.Config.ID)/$Context"
        Write-Verbose "Getting available contexts for [$ID]"
    } else {
        $defaultContext = Get-GitHubConfig -Name DefaultContext
        $ID = "$($script:GitHub.Config.ID)/$defaultContext"
        if ([string]::IsNullOrEmpty($ID)) {
            throw "No default GitHub context found. Please run 'Set-GitHubDefaultContext' or 'Connect-GitHub' to configure a GitHub context."
        }
        Write-Verbose "Getting the default context: [$ID]"
    }

    Get-Context -ID $ID | ForEach-Object {
        [GitHubContext]$_
    }

    Write-Verbose "[$commandName] - End"
}
