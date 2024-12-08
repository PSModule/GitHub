#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.1' }

function Set-GitHubContext {
    <#
        .SYNOPSIS
        Sets the GitHub context and stores it in the context vault.

        .DESCRIPTION
        This function sets the GitHub context and stores it in the context vault.
        The context is used to authenticate with the GitHub API.

        .EXAMPLE
        $context = @{
            ApiBaseUri = 'https://api.github.com'
            ApiVersion = '2022-11-28'
            HostName   = 'github.com'
            AuthType   = 'PAT'
            Enterprise = 'msx'
            Owner      = 'octocat'
            Repo       = 'Hello-World'
        }
        Set-GitHubContext -Context $context

        Sets the GitHub context with the specified settings as a hashtable.
    #>
    [OutputType([GitHubContext])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The GitHub context to save in the vault.
        [GitHubContext] $Context,

        # Set as the default context.
        [Parameter()]
        [switch] $Default,

        # Pass the context through the pipeline.
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
    }

    process {
        Write-Verbose 'Context:'
        $Context | Format-List | Out-String -Stream | ForEach-Object { Write-Verbose $_ }

        # Run functions to get info on the temporary context.
        try {
            Write-Verbose "Getting info on the context [$AuthType]."
            switch -Regex ($AuthType) {
                'PAT|UAT|IAT' {
                    $viewer = Get-GitHubViewer -Context $tempContext
                    $login = $viewer.login
                    $context.Username = $login
                    $context.NodeID = $viewer.id
                    $context.DatabaseID = ($viewer.databaseId).ToString()
                }
                'PAT|UAT' {
                    $contextName = "$HostName/$login"
                    $context.Name = $contextName
                    $context.Type = 'User'
                    $context = [UserGitHubContext]$context
                }
                'IAT' {
                    $contextName = "$HostName/$login/$Owner" -Replace '\[bot\]'
                    $context.Name = $contextName
                    $context.Type = 'Installation'
                    $context = [InstallationGitHubContext]$context
                }
                'App' {
                    $app = Get-GitHubApp -Context $tempContext
                    $contextName = "$HostName/$($app.slug)"
                    $context.Name = $contextName
                    $context.Username = $app.slug
                    $context.NodeID = $app.node_id
                    $context.DatabaseID = $app.id
                    $context.Type = 'App'
                    $context = [AppGitHubContext]$context
                }
                default {
                    throw 'Failed to get info on the context. Unknown logon type.'
                }
            }
            Write-Verbose "Found [$($context.Type)] with login: [$contextName]"

            if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
                Set-Context -ID "$($script:GitHub.Config.ID)/$contextName" -Context $context
                if ($Default) {
                    Set-GitHubDefaultContext -Context $contextName
                    if ($AuthType -eq 'IAT' -and $script:GitHub.EnvironmentType -eq 'GHA') {
                        Set-GitHubGitConfig -Context $contextName
                    }
                }
                if ($PassThru) {
                    Get-GitHubContext -Context $contextName
                }
            }
        } catch {
            throw ($_ -join ';')
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
