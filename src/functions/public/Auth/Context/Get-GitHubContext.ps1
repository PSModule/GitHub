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
    [OutputType([object])]
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

    $contexts = if ($ListAvailable) {
        Write-Verbose "Listing available contexts. [$($script:Config.Name)/*]"
        Get-Context -ID "$($script:Config.Name)/*"
    } elseif ($Name) {
        Write-Verbose "Listing available contexts. [$($script:Config.Name)/*]"
        Get-Context -ID "$($script:Config.Name)/$Name"
    } else {
        $defaultContext = Get-GitHubConfig -Name 'DefaultContext'
        Write-Verbose "Using the default context: $defaultContext"
        Get-Context -ID "$($script:Config.Name)/$defaultContext"
        Get-SecretInfo | Get-Secret -AsPlainText
    }

    Write-Verbose "Found $($contexts.Count) contexts."
    $contexts | ForEach-Object {
        Write-Verbose "Processing context: $($_.Name)"
        Write-Output $_
    }
}
