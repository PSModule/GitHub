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

        # Revoke the access token when disconnecting.
        [Parameter()]
        [switch] $RevokeToken,

        # The context to run the command with.
        # Can be either a string or a GitHubContext object.
        [Parameter(ValueFromPipeline)]
        [object[]] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        if (-not $Context) {
            $Context = Get-GitHubContext
        }
        foreach ($contextItem in $Context) {
            $contextItem = Resolve-GitHubContext -Context $contextItem
            if ($RevokeToken) {
                try {
                    if ($contextItem.Type -eq 'User' -and $contextItem.AuthType -eq 'UAT' -and $contextItem.AuthClientID) {
                        # OAuth token revocation
                        $apiCall = Remove-GitHubOAuthToken -ClientID $contextItem.AuthClientID -Token (Get-GitHubAccessToken -Context $contextItem -AsPlainText) -Context $contextItem
                        if (-not $Silent) {
                            Write-Host "Revoking OAuth token for [$($contextItem.Name)]..." -NoNewline
                        }
                        Invoke-GitHubAPI @($apiCall.InputObject)
                        if (-not $Silent) {
                            Write-Host " ✓" -ForegroundColor Green
                        }
                    } elseif ($contextItem.Type -eq 'Installation' -and $contextItem.AuthType -eq 'IAT') {
                        # Installation token revocation
                        $apiCall = Remove-GitHubInstallationToken -Context $contextItem
                        if (-not $Silent) {
                            Write-Host "Revoking installation token for [$($contextItem.Name)]..." -NoNewline
                        }
                        Invoke-GitHubAPI @($apiCall.InputObject)
                        if (-not $Silent) {
                            Write-Host " ✓" -ForegroundColor Green
                        }
                    } elseif (-not $Silent) {
                        Write-Warning "Token revocation not supported for context type '$($contextItem.Type)' with auth type '$($contextItem.AuthType)'"
                    }
                } catch {
                    if (-not $Silent) {
                        Write-Warning "Failed to revoke token for [$($contextItem.Name)]: $($_.Exception.Message)"
                    }
                }
            }

            Remove-GitHubContext -Context $contextItem
            $isDefaultContext = $contextItem.Name -eq $script:GitHub.Config.DefaultContext
            if ($isDefaultContext) {
                Remove-GitHubConfig -Name 'DefaultContext'
                if (-not $Silent) {
                    Write-Warning 'There is no longer a default context!'
                    Write-Warning "Please set a new default context using 'Switch-GitHubContext -Name <context>'"
                }
            }

            if (-not $Silent) {
                if ($script:IsGitHubActions) {
                    $green = $PSStyle.Foreground.Green
                    $reset = $PSStyle.Reset
                    Write-Host "$green✓$reset Logged out of GitHub! [$contextItem]"
                } else {
                    Write-Host '✓ ' -ForegroundColor Green -NoNewline
                    Write-Host "Logged out of GitHub! [$contextItem]"
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
