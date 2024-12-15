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
        Write-Debug "[$commandName] - Start"
        $null = Get-GitHubConfig
        $contextObj = @{} + $Context
    }

    process {
        Write-Debug 'Context:'
        $contextObj | Out-String -Stream | ForEach-Object { Write-Debug $_ }

        # Run functions to get info on the temporary context.
        try {
            Write-Debug "Getting info on the context [$($contextObj['AuthType'])]."
            switch -Regex ($($contextObj['AuthType'])) {
                'PAT|UAT|IAT' {
                    $viewer = Get-GitHubViewer -Context $contextObj
                    $viewer | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                    if ([string]::IsNullOrEmpty($contextObj['DisplayName'])) {
                        $contextObj['DisplayName'] = [string]$viewer.name
                    }
                    if ([string]::IsNullOrEmpty($contextObj['Username'])) {
                        $login = [string]($viewer.login -Replace '\[bot\]')
                        $contextObj['Username'] = $login
                    }
                    if ([string]::IsNullOrEmpty($contextObj['NodeID'])) {
                        $contextObj['NodeID'] = [string]$viewer.id
                    }
                    if ([string]::IsNullOrEmpty($contextObj['DatabaseID'])) {
                        $contextObj['DatabaseID'] = [string]$viewer.databaseId
                    }
                }
                'PAT|UAT' {
                    $contextName = "$($contextObj['HostName'])/$login"
                    $contextObj['Name'] = $contextName
                    $contextObj['Type'] = 'User'
                }
                'IAT' {
                    $contextObj['Type'] = 'Installation'
                    if ([string]::IsNullOrEmpty($contextObj['DisplayName'])) {
                        try {
                            $app = Get-GitHubApp -AppSlug $contextObj['Username'] -Context $contextObj
                            $contextObj['DisplayName'] = [string]$app.name
                        } catch {
                            Write-Warning "Failed to get the GitHub App with the slug: [$($contextObj['Username'])]."
                        }
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
                        Write-Debug "Enterprise:            $enterprise"
                        Write-Debug "Organization:          $organization"
                        Write-Debug "Repository:            $repo"
                        Write-Debug "Repository Owner:      $owner"
                        Write-Debug "Repository Owner Type: $targetType"
                        Write-Debug "Sender:                $gh_sender"
                        if ([string]::IsNullOrEmpty($contextObj['Enterprise'])) {
                            $contextObj['Enterprise'] = [string]$enterprise
                        }
                        if ([string]::IsNullOrEmpty($contextObj['Owner'])) {
                            $contextObj['Owner'] = [string]$owner
                        }
                        if ([string]::IsNullOrEmpty($contextObj['Repo'])) {
                            $contextObj['Repo'] = [string]$repo
                        }
                        if ([string]::IsNullOrEmpty($contextObj['TargetType'])) {
                            $contextObj['TargetType'] = [string]$targetType
                        }
                        if ([string]::IsNullOrEmpty($contextObj['TargetName'])) {
                            $contextObj['TargetName'] = [string]$targetName
                        }
                        $contextObj['Name'] = "$($contextObj['HostName'])/$($contextObj['Username'])/" +
                        "$($contextObj['TargetType'])/$($contextObj['TargetName'])"
                    } else {
                        $contextObj['Name'] = "$($contextObj['HostName'])/$($contextObj['Username'])/" +
                        "$($contextObj['TargetType'])/$($contextObj['TargetName'])"
                    }
                }
                'App' {
                    $app = Get-GitHubApp -Context $contextObj
                    $contextObj['Name'] = "$($contextObj['HostName'])/$($app.slug)"
                    $contextObj['DisplayName'] = [string]$app.name
                    $contextObj['Username'] = [string]$app.slug
                    $contextObj['NodeID'] = [string]$app.node_id
                    $contextObj['DatabaseID'] = [string]$app.id
                    $contextObj['Permissions'] = [PSCustomObject]$app.permissions
                    $contextObj['Events'] = [string[]]$app.events
                    $contextObj['OwnerName'] = [string]$app.owner.login
                    $contextObj['OwnerType'] = [string]$app.owner.type
                    $contextObj['Type'] = 'App'
                }
                default {
                    throw 'Failed to get info on the context. Unknown logon type.'
                }
            }
            Write-Debug "Found [$($contextObj['Type'])] with login: [$($contextObj['Name'])]"
            $contextObj | Out-String -Stream | ForEach-Object { Write-Debug $_ }
            Write-Debug '----------------------------------------------------'
            if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
                Write-Debug "Saving context: [$($script:GitHub.Config.ID)/$($contextObj['Name'])]"
                Set-Context -ID "$($script:GitHub.Config.ID)/$($contextObj['Name'])" -Context $contextObj
                if ($Default) {
                    Set-GitHubDefaultContext -Context $contextObj['Name']
                    if ($contextObj['AuthType'] -eq 'IAT' -and $script:GitHub.EnvironmentType -eq 'GHA') {
                        Set-GitHubGitConfig -Context $contextObj['Name']
                    }
                }
                if ($PassThru) {
                    Get-GitHubContext -Context $($contextObj['Name'])
                }
            }
        } catch {
            Write-Error $_ | Select-Object *
            throw 'Failed to set the GitHub context.'
        } finally {
            $contextObj.Clear()
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
