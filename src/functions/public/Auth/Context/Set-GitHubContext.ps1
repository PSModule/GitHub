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
                    $login = [string]$viewer.login -Replace '\[bot\]'
                    $Context['DisplayName'] = [string]$viewer.name
                    $Context['Username'] = $login
                    $Context['NodeID'] = [string]$viewer.id
                    $Context['DatabaseID'] = [string]$viewer.databaseId
                }
                'PAT|UAT' {
                    $ContextName = "$($Context['HostName'])/$login"
                    $Context['Name'] = $ContextName
                    $Context['Type'] = 'User'
                }
                'IAT' {
                    $gitHubEvent = Get-Content -Path $env:GITHUB_EVENT_PATH -Raw | ConvertFrom-Json
                    $app = Get-GitHubApp -AppSlug $login -Context $Context
                    $targetType = $gitHubEvent.repository.owner.type
                    $targetName = $gitHubEvent.repository.owner.login
                    Write-Verbose ('Enterprise:            ' + $gitHubEvent.enterprise.slug)
                    Write-Verbose ('Organization:          ' + $gitHubEvent.organization.login)
                    Write-Verbose ('Repository:            ' + $gitHubEvent.repository.name)
                    Write-Verbose ('Repository Owner:      ' + $gitHubEvent.repository.owner.login)
                    Write-Verbose ('Repository Owner Type: ' + $gitHubEvent.repository.owner.type)
                    Write-Verbose ('Sender:                ' + $gitHubEvent.sender.login)
                    $ContextName = "$($Context['HostName'])/$login/$targetType/$targetName"
                    $Context['Name'] = $ContextName
                    $Context['DisplayName'] = [string]$app.name
                    $Context['Type'] = 'Installation'
                    $Context['Enterprise'] = [string]$gitHubEvent.enterprise.slug
                    $Context['TargetType'] = [string]$gitHubEvent.repository.owner.type
                    $Context['TargetName'] = [string]$gitHubEvent.repository.owner.login
                    $Context['Owner'] = [string]$gitHubEvent.repository.owner.login
                    $Context['Repo'] = [string]$gitHubEvent.repository.name
                }
                'App' {
                    $app = Get-GitHubApp -Context $Context
                    $ContextName = "$($Context['HostName'])/$($app.slug)"
                    $Context['Name'] = $ContextName
                    $Context['DisplayName'] = [string]$app.name
                    $Context['Username'] = [string]$app.slug
                    $Context['NodeID'] = [string]$app.node_id
                    $Context['DatabaseID'] = [string]$app.id
                    $Context['Permissions'] = [string]$app.permissions
                    $Context['Events'] = [string]$app.events
                    $Context['OwnerName'] = [string]$app.owner.login
                    $Context['OwnerType'] = [string]$app.owner.type
                    $Context['Type'] = 'App'
                }
                default {
                    throw 'Failed to get info on the context. Unknown logon type.'
                }
            }
            Write-Verbose "Found [$($Context['Type'])] with login: [$($Context['Name'])]"
            $Context | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
            Write-Verbose '----------------------------------------------------'
            if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
                Write-Verbose "Saving context: [$($script:GitHub.Config.ID)/$($Context['Name'])]"
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
            Write-Error $_ | Select-Object *
            throw 'Failed to set the GitHub context.'
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
