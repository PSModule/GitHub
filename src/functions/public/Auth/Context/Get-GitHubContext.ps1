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

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
    }

    process {

        switch ($PSCmdlet.ParameterSetName) {
            'NamedContext' {
                Write-Verbose "NamedContext: [$Context]"
                $ID = "$($script:GitHub.Config.ID)/$Context"
                Write-Verbose "Getting available contexts for [$ID]"
            }
            'ListAvailableContexts' {
                Write-Verbose "ListAvailable: [$ListAvailable]"
                $ID = "$($script:GitHub.Config.ID)/*"
                Write-Verbose "Getting available contexts for [$ID]"
            }
            '__AllParameterSets' {
                Write-Verbose 'Getting default context.'
                $ID = "$($script:GitHub.Config.ID)/$($script:GitHub.Config.DefaultContext)"
                if ([string]::IsNullOrEmpty($ID)) {
                    throw "No default GitHub context found. Please run 'Set-GitHubDefaultContext' or 'Connect-GitHub' to configure a GitHub context."
                }
                Write-Verbose "Getting the default context: [$ID]"
            }
        }

        Get-Context -ID $ID | ForEach-Object {
            $contextObj = $_
            switch ($contextObj.Type) {
                'User' {
                    [UserGitHubContext]$contextObj
                }
                'App' {
                    [AppGitHubContext]$contextObj
                }
                'Installation' {
                    [InstallationGitHubContext]$contextObj
                }
            }
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
