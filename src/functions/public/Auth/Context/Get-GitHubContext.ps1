function Get-GitHubContext {
    <#
        .SYNOPSIS
        Get the current GitHub context.

        .DESCRIPTION
        Get the current GitHub context.

        .EXAMPLE
        ```powershell
        Get-GitHubContext
        ```

        Gets the current GitHub context.

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Context/Get-GitHubContext
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'Encapsulated in a function. Never leaves as a plain text.'
    )]
    [OutputType([GitHubContext])]
    [CmdletBinding(DefaultParameterSetName = 'Get default context')]
    param(
        # The name of the context.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Get a named context',
            Position = 0
        )]
        [Alias('Name')]
        [string] $Context,

        # List all available contexts.
        [Parameter(
            Mandatory,
            ParameterSetName = 'List all available contexts'
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
            'Get a named context' {
                Write-Debug "Get a named context: [$Context]"
                $ID = $Context
            }
            'List all available contexts' {
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

            Write-Verbose "Converting to: [GitHub$($contextObj.Type)Context]"
            switch ($contextObj.Type) {
                'User' {
                    [GitHubUserContext]::new([pscustomobject]$contextObj)
                }
                'App' {
                    [GitHubAppContext]::new([pscustomobject]$contextObj)
                }
                'Installation' {
                    [GitHubAppInstallationContext]::new([pscustomobject]$contextObj)
                }
                default {
                    throw "Unknown context type: [$($contextObj.Type)]"
                }
            }
        } | Sort-Object -Property Name
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.3' }
