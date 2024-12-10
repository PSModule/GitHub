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
                    $viewer | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
                    $login = [string]$viewer.login
                    $Context += @{
                        DisplayName = [string]$viewer.name
                        Username    = [string]$login
                        NodeID      = [string]$viewer.id
                        DatabaseID  = [string]$viewer.databaseId
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
                        DisplayName = [string]$app.name
                        Username    = [string]$app.slug
                        NodeID      = [string]$app.node_id
                        DatabaseID  = [string]$app.id
                        Permissions = [string]$app.permissions
                        Events      = [string]$app.events
                        OwnerName   = [string]$app.owner.login
                        OwnerType   = [string]$app.owner.type
                        Type        = 'App'
                    }
                }
                default {
                    throw 'Failed to get info on the context. Unknown logon type.'
                }
            }
            Write-Verbose "Found [$($contextObj.Type)] with login: [$($contextObj.Name)]"
            $contextObj | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
            Write-Verbose "----------------------------------------------------"
            if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
                Write-Verbose "Saving context: [$($script:GitHub.Config.ID)/$($contextObj.Name)]"
                Set-Context -ID "$($script:GitHub.Config.ID)/$($contextObj.Name)" -Context $contextObj -Debug -Verbose
                if ($Default) {
                    Set-GitHubDefaultContext -Context $contextObj.Name
                    if ($contextObj.AuthType -eq 'IAT' -and $script:GitHub.EnvironmentType -eq 'GHA') {
                        Set-GitHubGitConfig -Context $contextObj.Name
                    }
                }
                if ($PassThru) {
                    Get-GitHubContext -Context $($contextObj.Name)
                }
            }
        } catch {
            Write-Error $_ | Select-Object *
            throw 'Failed to set the GitHub context.'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
