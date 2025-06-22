function Get-GitHubContext {
    <#
        .SYNOPSIS
        Get the current GitHub context.

        .DESCRIPTION
        Get the current GitHub context.

        .EXAMPLE
        Get-GitHubContext

        Gets the current GitHub context.

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Context/Get-GitHubContext
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
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $null = Get-GitHubConfig
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'NamedContext' {
                Write-Debug "NamedContext: [$Context]"
                $ID = $Context
            }
            'ListAvailableContexts' {
                Write-Debug "ListAvailable: [$ListAvailable]"
                $ID = '*'
            }
            default {
                Write-Debug 'Getting default context.'
                $ID = $script:GitHub.Config.DefaultContext
                if ([string]::IsNullOrEmpty($ID)) {
                    $msg = "No default GitHub context found. Please run 'Switch-GitHubContext' or 'Connect-GitHub' to configure a GitHub context."
                    Write-Warning $msg
                    return
                }
            }
        }
        Write-Verbose "Getting the context: [$ID]"

        Get-Context -ID $ID -Vault $script:GitHub.ContextVault | Where-Object { $_.ID -ne $script:GitHub.DefaultConfig.ID } | ForEach-Object {
            $contextObj = $_
            Write-Verbose 'Context:'
            $contextObj | Select-Object * | Out-String -Stream | ForEach-Object { Write-Verbose $_ }

            Write-Verbose "Converting to: [$($contextObj.Type)GitHubContext]"
            switch ($contextObj.Type) {
                'User' {
                    [UserGitHubContext]::new($contextObj)
                }
                'App' {
                    [AppGitHubContext]::new($contextObj)
                }
                'Installation' {
                    [InstallationGitHubContext]::new($contextObj)
                }
                default {
                    throw "Unknown context type: [$($contextObj.Type)]"
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.0' }
