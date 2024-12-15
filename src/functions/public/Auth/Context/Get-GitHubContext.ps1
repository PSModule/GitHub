#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.4' }

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
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $null = Get-GitHubConfig
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
