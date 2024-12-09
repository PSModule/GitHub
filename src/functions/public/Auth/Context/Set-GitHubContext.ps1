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
        [hashtable] $Context,

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
            Write-Verbose "Getting info on the context [$($Context['AuthType'])]."
            switch -Regex ($($Context['AuthType'])) {
                'PAT|UAT|IAT' {
                    $viewer = Get-GitHubViewer -Context $Context
                    $login = $viewer.login
                    $context += @{
                        Username   = $login
                        NodeID     = $viewer.id
                        DatabaseID = ($viewer.databaseId).ToString()
                    }
                }
                'PAT|UAT' {
                    $contextName = "$HostName/$login"
                    $context += @{
                        Name = $contextName
                        Type = 'User'
                    }
                }
                'IAT' {
                    $contextName = "$HostName/$login/$Owner" -Replace '\[bot\]'
                    $context += @{
                        Name = $contextName
                        Type = 'Installation'
                    }
                }
                'App' {
                    $app = Get-GitHubApp -Context $Context
                    $contextName = "$HostName/$($app.slug)"
                    $context += @{
                        Name       = $contextName
                        Username   = $app.slug
                        NodeID     = $app.node_id
                        DatabaseID = $app.id
                        Type       = 'App'
                    }
                }
                default {
                    throw 'Failed to get info on the context. Unknown logon type.'
                }
            }
            Write-Verbose "Found [$($context['Type'])] with login: [$($context['Name'])]"
            $Context | Format-List | Out-String -Stream | ForEach-Object { Write-Verbose $_ }

            if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
                Set-Context -ID "$($script:GitHub.Config.ID)/$($context['Name'])" -Context $context
                if ($Default) {
                    Set-GitHubDefaultContext -Context $context['Name']
                    if ($Context['AuthType'] -eq 'IAT' -and $script:GitHub.EnvironmentType -eq 'GHA') {
                        Set-GitHubGitConfig -Context $context['Name']
                    }
                }
                if ($PassThru) {
                    Get-GitHubContext -Context $($context['Name'])
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
