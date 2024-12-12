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
                    if ([string]::IsNullOrEmpty($Context['DisplayName'])) {
                        $Context['DisplayName'] = [string]$viewer.name
                    }
                    if ([string]::IsNullOrEmpty($Context['Username'])) {
                        $login = [string]($viewer.login -Replace '\[bot\]')
                        $Context['Username'] = $login
                    }
                    if ([string]::IsNullOrEmpty($Context['NodeID'])) {
                        $Context['NodeID'] = [string]$viewer.id
                    }
                    if ([string]::IsNullOrEmpty($Context['DatabaseID'])) {
                        $Context['DatabaseID'] = [string]$viewer.databaseId
                    }
                }
                'PAT|UAT' {
                    $contextName = "$($Context['HostName'])/$login"
                    $Context['Name'] = $contextName
                    $Context['Type'] = 'User'
                }
                'IAT' {
                    $Context['Type'] = 'Installation'
                    if ([string]::IsNullOrEmpty($Context['DisplayName'])) {
                        try {
                            $app = Get-GitHubApp -AppSlug $Context['Name'] -Context $Context
                        } catch {
                            Write-Warning "Failed to get the GitHub App with the slug: [$($Context['Name'])]."
                        }
                        $Context['DisplayName'] = [string]$app.name
                    }

                    if ($script:GitHub.EnvironmentType -eq 'GHA') {
                        $gitHubEvent = Get-Content -Path $env:GITHUB_EVENT_PATH -Raw | ConvertFrom-Json
                        $targetType = $gitHubEvent.repository.owner.type
                        $targetName = $gitHubEvent.repository.owner.login
                        $enterprise = $gitHubEvent.enterprise.slug
                        $organization = $gitHubEvent.organization.login
                        $owner = $gitHubEvent.repository.owner.login
                        $repo = $gitHubEvent.repository.name
                        $gh_sender = $gitHubEvent.sender.login # sender is an automatic variable in Powershell
                        Write-Verbose "Enterprise:            $enterprise"
                        Write-Verbose "Organization:          $organization"
                        Write-Verbose "Repository:            $repo"
                        Write-Verbose "Repository Owner:      $owner"
                        Write-Verbose "Repository Owner Type: $targetType"
                        Write-Verbose "Sender:                $gh_sender"
                        $Context['Enterprise'] = [string]$enterprise
                        $Context['TargetType'] = [string]$targetType
                        $Context['TargetName'] = [string]$targetName
                        $Context['Owner'] = [string]$owner
                        $Context['Repo'] = [string]$repo
                        $Context['Name'] = "$($Context['HostName'])/$($Context['Username'])/$($Context['TargetType'])/$($Context['TargetName'])"
                    } else {
                        $Context['Name'] = "$($Context['HostName'])/$($Context['Username'])/$($Context['TargetType'])/$($Context['TargetName'])"
                    }
                }
                'App' {
                    $app = Get-GitHubApp -Context $Context
                    $Context['Name'] = "$($Context['HostName'])/$($app.slug)"
                    $Context['DisplayName'] = [string]$app.name
                    $Context['Username'] = [string]$app.slug
                    $Context['NodeID'] = [string]$app.node_id
                    $Context['DatabaseID'] = [string]$app.id
                    $Context['Permissions'] = [PSCustomObject]$app.permissions
                    $Context['Events'] = [string[]]$app.events
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
