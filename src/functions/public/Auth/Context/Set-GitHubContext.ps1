#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '5.0.3' }

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
        $null = Get-GitHubConfig
    }

    process {
        Write-Verbose 'Context:'
        $Context | Out-String -Stream | ForEach-Object { Write-Verbose $_ }

        # Run functions to get info on the temporary context.
        try {
            Write-Verbose "Getting info on the context [$($Context['AuthType'])]."
            switch -Regex ($($Context['AuthType'])) {
                'PAT|UAT|IAT' {
                    $viewer = Get-GitHubViewer -Context $Context
                    $login = $viewer.login
                    $Context += @{
                        DisplayName = $viewer.name
                        Username    = $login
                        NodeID      = $viewer.id
                        DatabaseID  = ($viewer.databaseId).ToString()
                    }
                }
                'PAT|UAT' {
                    $ContextName = "$($Context['HostName'])/$login"
                    $Context += @{
                        Name = $ContextName
                        Type = 'User'
                    }
                }
                'IAT' {
                    $ContextName = "$($Context['HostName'])/$login/$($Context['Owner'])" -Replace '\[bot\]'
                    $Context += @{
                        Name = $ContextName
                        Type = 'Installation'
                    }
                }
                'App' {
                    $app = Get-GitHubApp -Context $Context
                    $ContextName = "$($Context['HostName'])/$($app.slug)"
                    $Context += @{
                        Name        = $ContextName
                        DisplayName = $app.name
                        Username    = $app.slug
                        NodeID      = $app.node_id
                        DatabaseID  = $app.id
                        Permissions = $app.permissions
                        Events      = $app.events
                        Owner       = $app.owner.login
                        OwnerType   = $app.owner.type
                        Type        = 'App'
                    }
                }
                default {
                    throw 'Failed to get info on the context. Unknown logon type.'
                }
            }
            Write-Verbose "Found [$($Context['Type'])] with login: [$($Context['Name'])]"
            $Context | Out-String -Stream | ForEach-Object { Write-Verbose $_ }

            if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
                Set-Context -ID "$($script:GitHub.Config.ID)/$($Context['Name'])" -Context $Context
                if ($Default) {
                    Set-GitHubDefaultContext -Context $Context['Name']
                    if ($Context['AuthType'] -eq 'IAT' -and $script:GitHub.EnvironmentType -eq 'GHA') {
                        Set-GitHubGitConfig -Context $Context['Name']
                    }
                }
                if ($PassThru) {
                    Get-GitHubContext -Context $($Context['Name'])
                }
            }
        } catch {
            Write-Error $_ | Select *
            throw 'Failed to set the GitHub context.'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
