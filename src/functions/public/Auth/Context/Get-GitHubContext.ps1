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
    [CmdletBinding(DefaultParameterSetName = 'Get default context')]
    param(
        # The name of the context.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Get named contexts',
            Position = 0
        )]
        [Alias('Name')]
        [SupportsWildcards()]
        [string[]] $Context,

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
        $rawContexts = @()
        switch ($PSCmdlet.ParameterSetName) {
            'Get named contexts' {
                $patterns = $Context
                Write-Debug ('Requested context patterns: [{0}]' -f ($patterns -join ', '))
                $hasWildcard = $patterns | Where-Object { [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($_) } |
                    Select-Object -First 1
                $all = $null
                if ($hasWildcard) {
                    Write-Debug 'Wildcard detected - loading all contexts once.'
                    $all = Get-Context -ID '*' -Vault $script:GitHub.ContextVault
                    if ($all) { Write-Debug ('Loaded contexts (count): {0}' -f ($all.Count)) } else { Write-Debug 'Loaded contexts: 0' }
                }

                $collected = foreach ($pattern in $patterns) {
                    $initialPatternCount = if ($all) { $all.Count } else { 0 }
                    if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($pattern)) {
                        Write-Debug "Wildcard match for pattern: [$pattern]"
                        $patternMatches = ($all | Where-Object { $_.ID -like $pattern -or $_.Name -like $pattern })
                        Write-Debug ("Pattern [$pattern] matched {0} context(s)." -f ($patternMatches | Measure-Object | Select-Object -ExpandProperty Count))
                        $patternMatches
                    } else {
                        if ($all) {
                            Write-Debug "Exact match search (cached all) for: [$pattern]"
                            $patternMatches = ($all | Where-Object { $_.ID -eq $pattern -or $_.Name -eq $pattern })
                            Write-Debug ("Exact pattern [$pattern] resolved to {0} context(s)." -f ($patternMatches | Measure-Object | Select-Object -ExpandProperty Count))
                            $patternMatches
                        } else {
                            Write-Debug "Exact match direct lookup for: [$pattern]"
                            $match = (Get-Context -ID $pattern -Vault $script:GitHub.ContextVault)
                            Write-Debug ("Direct lookup for [$pattern] returned: {0}" -f ($(if ($match) { 1 } else { 0 })))
                            $match
                        }
                    }
                }
                $rawContexts = $collected | Where-Object { $_ } | Select-Object -Unique
                Write-Debug ('Total contexts after de-duplication: {0}' -f ($rawContexts | Measure-Object | Select-Object -ExpandProperty Count))
            }
            'List all available contexts' {
                Write-Debug "ListAvailable: [$ListAvailable]"
                $rawContexts = Get-Context -ID '*' -Vault $script:GitHub.ContextVault
            }
            default {
                Write-Debug 'Getting default context.'
                $defaultID = $script:GitHub.Config.DefaultContext
                if ([string]::IsNullOrEmpty($defaultID)) {
                    $msg = "No default GitHub context found. Please run 'Switch-GitHubContext' or 'Connect-GitHub' to configure a GitHub context."
                    Write-Warning $msg
                    return
                }
                $rawContexts = Get-Context -ID $defaultID -Vault $script:GitHub.ContextVault
            }
        }

        if (-not $rawContexts) {
            Write-Verbose 'No contexts matched.'
            return
        }

        $rawContexts |
            Where-Object { $_.ID -ne $script:GitHub.DefaultConfig.ID } |
            ForEach-Object {
                $contextObj = $_
                Write-Verbose 'Context:'
                $contextObj | Select-Object * | Out-String -Stream | ForEach-Object { Write-Verbose $_ }

                Write-Verbose "Converting to: [GitHub$($contextObj.Type)Context]"
                switch ($contextObj.Type) {
                    'User' { [GitHubUserContext]::new([pscustomobject]$contextObj) }
                    'App' { [GitHubAppContext]::new([pscustomobject]$contextObj) }
                    'Installation' { [GitHubAppInstallationContext]::new([pscustomobject]$contextObj) }
                    default { throw "Unknown context type: [$($contextObj.Type)]" }
                }
            } | Sort-Object -Property Name
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.3' }
