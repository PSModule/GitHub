﻿#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.1' }

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
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
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

    switch ($PSCmdlet.ParameterSetName) {
        'NamedContext' {
            $ID = "$($script:GitHub.Config.ID)/$Context"
            Write-Verbose "Getting available contexts for [$ID]"
        }
        'ListAvailableContexts' {
            Write-Debug "ListAvailable: [$ListAvailable]"
            $ID = "$($script:GitHub.Config.ID)/*"
            Write-Verbose "Getting available contexts for [$ID]"
        }
        '__AllParameterSets' {
            $ID = "$($script:GitHub.Config.ID)/$($script:GitHub.Config.DefaultContext)"
            if ([string]::IsNullOrEmpty($ID)) {
                throw "No default GitHub context found. Please run 'Set-GitHubDefaultContext' or 'Connect-GitHub' to configure a GitHub context."
            }
            Write-Verbose "Getting the default context: [$ID]"
        }
    }

    Get-Context -ID $ID | ForEach-Object {
        switch ($_.Type) {
            'User' {
                [UserGitHubContext]$_
            }
            'App' {
                [AppGitHubContext]$_
            }
            'Installation' {
                [InstallationGitHubContext]$_
            }
        }
    }

    Write-Verbose "[$commandName] - End"
}
