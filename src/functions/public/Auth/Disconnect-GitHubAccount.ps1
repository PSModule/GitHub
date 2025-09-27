function Disconnect-GitHubAccount {
    <#
        .SYNOPSIS
        Disconnects from GitHub and removes the GitHub context.

        .DESCRIPTION
        Disconnects from GitHub and removes the GitHub context. Optionally revokes the access token
        to ensure it cannot be used after disconnection.

        .EXAMPLE
        Disconnect-GitHubAccount

        Disconnects from GitHub and removes the default GitHub context.

        .EXAMPLE
        Disconnect-GithubAccount -Context 'github.com/Octocat'

        Disconnects from GitHub and removes the context 'github.com/Octocat'.

        .EXAMPLE
        Disconnect-GitHubAccount -RevokeToken

        Disconnects from GitHub, revokes the access token, and removes the default GitHub context.

        .EXAMPLE
        Disconnect-GithubAccount -Context 'github.com/Octocat' -RevokeToken

        Disconnects from GitHub, revokes the access token, and removes the context 'github.com/Octocat'.

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Disconnect-GitHubAccount
    #>
    [Alias('Disconnect-GitHub')]
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [CmdletBinding()]
    param(
        # Suppresses the output of the function.
        [Parameter()]
        [Alias('Quiet')]
        [switch] $Silent,

        # The maximum number of parallel threads to use when disconnecting multiple installations.
        [Parameter()]
        [int] $ThrottleLimit = [System.Environment]::ProcessorCount,

        # One or more contexts (names / IDs) or GitHubContext objects to disconnect.
        # Supports wildcard patterns when passing strings (delegated to Get-GitHubContext).
        [Parameter(ValueFromPipeline)]
        [SupportsWildcards()]
        [object[]] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        # Resolve contexts using new multi-string + wildcard support in Get-GitHubContext
        $resolvedContexts = @()
        if (-not $PSBoundParameters.ContainsKey('Context') -or -not $Context) {
            # No specific context supplied – operate on the default
            $resolvedContexts += Get-GitHubContext
        } else {
            $stringInputs = $Context | Where-Object { $_ -is [string] }
            $objectInputs = $Context | Where-Object { $_ -isnot [string] }
            if ($stringInputs) {
                # Batch resolve all string / wildcard patterns in a single call (or as few as possible)
                $resolvedContexts += Get-GitHubContext -Context $stringInputs -ErrorAction SilentlyContinue
            }
            if ($objectInputs) { $resolvedContexts += $objectInputs }
        }

        $resolvedContexts = $resolvedContexts | Where-Object { $_ } | Select-Object -Unique
        if (-not $resolvedContexts) {
            if (-not $Silent) { Write-Warning 'No GitHub contexts matched.' }
            return
        }

        # Determine if the default context will be removed (handle after parallel block once)
        $defaultContextName = $script:GitHub.Config.DefaultContext
        $removingDefault = $resolvedContexts | Where-Object { $_.Name -eq $defaultContextName }

        $moduleName = $script:Module.Name
        $moduleVersion = $script:PSModuleInfo.ModuleVersion
        $resolvedContexts | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
            Import-Module -Name $using:moduleName -RequiredVersion $using:moduleVersion -Force -ErrorAction Stop
            $contextItem = $_
            $contextItem = Resolve-GitHubContext -Context $contextItem

            $contextToken = Get-GitHubAccessToken -Context $contextItem -AsPlainText
            $gitHubToken = Get-GitHubToken | ConvertFrom-SecureString -AsPlainText
            $isNotGitHubToken = $contextToken -ne $gitHubToken
            $isIATAuthType = $contextItem.AuthType -eq 'IAT'
            $isNotExpired = $contextItem.TokenExpiresIn -gt 0
            Write-Debug "isNotGitHubToken: $isNotGitHubToken"
            Write-Debug "isIATAuthType:    $isIATAuthType"
            Write-Debug "isNotExpired:     $isNotExpired"
            if ($isNotGitHubToken -and $isIATAuthType -and $isNotExpired) {
                try {
                    Revoke-GitHubAppInstallationAccessToken -Context $contextItem
                } catch {
                    Write-Debug '[Disconnect-GitHubAccount] - Failed to revoke token:'
                    Write-Debug $_
                }
            }

            Remove-GitHubContext -Context $contextItem.ID

            if (-not $using:Silent) {
                $green = $PSStyle.Foreground.Green
                $reset = $PSStyle.Reset
                Write-Host "$green✓$reset Logged out of GitHub! [$contextItem]"
            }
        }

        if ($removingDefault) {
            # Double-check that the default still points to a removed context before clearing
            if ($script:GitHub.Config.DefaultContext -eq $defaultContextName) {
                Remove-GitHubConfig -Name 'DefaultContext'
                if (-not $Silent) {
                    Write-Warning 'There is no longer a default context!'
                    Write-Warning "Please set a new default context using 'Switch-GitHubContext -Name <context>'"
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
