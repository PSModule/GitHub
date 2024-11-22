#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '3.0.3' }

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
        [string] $Name,

        # List all available contexts.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ListAvailableContexts'
        )]
        [switch] $ListAvailable
    )

    if ($ListAvailable) {
        $ID = "$($script:Config.Name)/*"
        Write-Verbose "Getting available contexts for [$ID]"
    } elseif ($Name) {
        $ID = "$($script:Config.Name)/$Name"
        Write-Verbose "Getting available contexts for [$ID]"
    } else {
        $defaultContext = Get-GitHubConfig -Name 'DefaultContext'
        $ID = "$($script:Config.Name)/$defaultContext"
        Write-Verbose "Getting the default context: [$ID]"
    }

    Get-Context -ID $ID | ForEach-Object {
        [GitHubContext]$_
    }
}
