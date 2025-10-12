function Set-GitHubContext {
    <#
        .SYNOPSIS
        Sets the GitHub context and stores it in the context vault.

        .DESCRIPTION
        This function sets the GitHub context and stores it in the context vault.
        The context is used to authenticate with the GitHub API.

        .EXAMPLE
        ```pwsh
        $context = @{
            ApiBaseUri = 'https://api.github.com'
            ApiVersion = '2022-11-28'
            HostName   = 'github.com'
            AuthType   = 'PAT'
            Enterprise = 'msx'
            Owner      = 'octocat'
            Repository = 'Hello-World'
        }
        Set-GitHubContext -Context $context
        ```

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
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $null = Get-GitHubConfig
        $contextObj = @{} + $Context
    }

    process {
        if ($DebugPreference -eq 'Continue') {
            Write-Debug 'Context:'
            $contextObj | Out-String -Stream | ForEach-Object { Write-Debug $_ }
            Write-Debug "Getting info on the context [$($contextObj['AuthType'])]."
        }

        # Run functions to get info on the temporary context.
        try {
            switch -Regex (($contextObj['AuthType'])) {
                'PAT|UAT|IAT' {
                    $viewer = Get-GitHubViewer -Context $contextObj
                    $viewer | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                    if ([string]::IsNullOrEmpty($contextObj['DisplayName'])) {
                        $contextObj['DisplayName'] = [string]$viewer.name
                    }
                    if ([string]::IsNullOrEmpty($contextObj['Username'])) {
                        $login = [string]($viewer.login -replace '\[bot\]')
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
                            $app = Get-GitHubApp -Slug $contextObj['Username'] -Context $contextObj
                            $contextObj['DisplayName'] = [string]$app.Name
                            $contextObj['App'] = [GitHubApp]$app
                        } catch {
                            Write-Warning "Unable to get the GitHub App: [$($contextObj['Username'])]."
                        }
                    }
                    if ($script:IsGitHubActions) {
                        $gitHubEvent = Get-Content -Path $env:GITHUB_EVENT_PATH -Raw | ConvertFrom-Json
                        $installationType = $gitHubEvent.repository.owner.type
                        $installationName = $gitHubEvent.repository.owner.login
                        $enterprise = $gitHubEvent.enterprise.slug
                        $organization = $gitHubEvent.organization.login
                        $owner = $gitHubEvent.repository.owner.login
                        $Repository = $gitHubEvent.repository.name
                        $gh_sender = $gitHubEvent.sender.login # sender is an automatic variable in Powershell
                        Write-Debug "Enterprise:            $enterprise"
                        Write-Debug "Organization:          $organization"
                        Write-Debug "Repository:            $Repository"
                        Write-Debug "Repository Owner:      $owner"
                        Write-Debug "Repository Owner Type: $installationType"
                        Write-Debug "Sender:                $gh_sender"
                        if ([string]::IsNullOrEmpty($contextObj['Enterprise'])) {
                            $contextObj['Enterprise'] = [string]$enterprise
                        }
                        if ([string]::IsNullOrEmpty($contextObj['Owner'])) {
                            $contextObj['Owner'] = [string]$owner
                        }
                        if ([string]::IsNullOrEmpty($contextObj['Repository'])) {
                            $contextObj['Repository'] = [string]$Repository
                        }
                        if ([string]::IsNullOrEmpty($contextObj['InstallationType'])) {
                            $contextObj['InstallationType'] = [string]$installationType
                        }
                        if ([string]::IsNullOrEmpty($contextObj['InstallationName'])) {
                            $contextObj['InstallationName'] = [string]$installationName
                        }
                    }
                    $contextObj['Name'] = "$($contextObj['HostName'])/$($contextObj['Username'])/" +
                    "$($contextObj['InstallationType'])/$($contextObj['InstallationName'])"
                }
                'App' {
                    $app = Get-GitHubApp -Context $contextObj
                    $contextObj['Name'] = "$($contextObj['HostName'])/$($app.Slug)"
                    $contextObj['DisplayName'] = [string]$app.Name
                    $contextObj['Username'] = [string]$app.Slug
                    $contextObj['NodeID'] = [string]$app.NodeID
                    $contextObj['DatabaseID'] = [string]$app.ID
                    $contextObj['Permissions'] = [GitHubPermission[]]$app.Permissions
                    $contextObj['Events'] = [string[]]$app.Events
                    $contextObj['OwnerName'] = [string]$app.Owner.Name
                    $contextObj['OwnerType'] = [string]$app.Owner.Type
                    $contextObj['App'] = [GitHubApp]$app
                    $contextObj['Type'] = 'App'
                }
                default {
                    throw 'Failed to get info on the context. Unknown logon type.'
                }
            }
            if ($DebugPreference -eq 'Continue') {
                Write-Debug "Found [$($contextObj['Type'])] with login: [$($contextObj['Name'])]"
                $contextObj | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                Write-Debug '----------------------------------------------------'
                Write-Debug "Saving context: [$($contextObj['Name'])]"
            }
            if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
                Set-Context -ID $($contextObj['Name']) -Context $contextObj -Vault $script:GitHub.ContextVault
                if ($Default) {
                    Switch-GitHubContext -Context $contextObj['Name']
                }
                if ($script:IsGitHubActions) {
                    if ($contextObj['AuthType'] -ne 'APP') {
                        Set-GitHubGitConfig -Context $contextObj['Name']
                        Connect-GitHubCli -Context $contextObj
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
        Write-Debug "[$stackPath] - End"
    }
}
#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '8.1.3' }

