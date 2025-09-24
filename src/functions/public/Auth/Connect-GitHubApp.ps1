function Connect-GitHubApp {
    <#
        .SYNOPSIS
        Connects to GitHub as a installation using a GitHub App.

        .DESCRIPTION
        Connects to GitHub using a GitHub App to generate installation access tokens and create contexts for targets.
        This function supports recursive processing and parallel connections to multiple installations.

        Available target types:
        - User
        - Organization
        - Enterprise

        .EXAMPLE
        Connect-GitHubApp

        Connects to GitHub as all available targets using the logged in GitHub App in parallel.

        .EXAMPLE
        Connect-GitHubApp -User 'octocat'

        Connects to GitHub as the user 'octocat' using the logged in GitHub App.

        .EXAMPLE
        Connect-GitHubApp -Organization 'psmodule' -Default

        Connects to GitHub as the organization 'psmodule' using the logged in GitHub App and sets it as the default context.

        .EXAMPLE
        Connect-GitHubApp -Enterprise 'msx'

        Connects to GitHub as the enterprise 'msx' using the logged in GitHub App.

        .EXAMPLE
        Get-GitHubAppInstallation | Connect-GitHubApp -ThrottleLimit 4

        Gets all app installations and connects to them in parallel with a maximum of 4 concurrent connections.

        .EXAMPLE
        Connect-GitHubApp -User '*' -Organization 'psmodule', 'github' -ThrottleLimit 8

        Connects to all users and the specified organizations in parallel with a maximum of 8 concurrent connections.

        .NOTES
        [Authenticating to the REST API](https://docs.github.com/rest/overview/other-authentication-methods#authenticating-for-saml-sso)

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Connect-GitHubApp
    #>
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'The tokens are received as clear text. Mitigating exposure by removing variables and performing garbage collection.')]
    [CmdletBinding(DefaultParameterSetName = 'All Installations')]
    param(
        # The user account to connect to.
        [Parameter(ParameterSetName = 'Filtered', ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [string[]] $User,

        # The organization to connect to.
        [Parameter(ParameterSetName = 'Filtered', ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [string[]] $Organization,

        # The enterprise to connect to.
        [Parameter(ParameterSetName = 'Filtered', ValueFromPipelineByPropertyName)]
        [SupportsWildcards()]
        [string[]] $Enterprise,

        # Installation objects from pipeline for parallel processing.
        [Parameter(Mandatory, ParameterSetName = 'Installation object', ValueFromPipeline)]
        [GitHubAppInstallation[]] $Installation,

        # The maximum number of parallel operations to run at once.
        [Parameter(ParameterSetName = 'Filtered')]
        [Parameter(ParameterSetName = 'Installation')]
        [uint] $ThrottleLimit = ([Environment]::ProcessorCount),

        # The installation ID(s) to connect to directly.
        # Accepts input from the pipeline by property name (e.g. objects with an ID property)
        [Parameter(Mandatory, ParameterSetName = 'Installation ID', ValueFromPipelineByPropertyName)]
        [Alias('InstallationID')]
        [int[]] $ID,

        # Passes the context object to the pipeline.
        [Parameter()]
        [switch] $PassThru,

        # Suppresses the output of the function.
        [Parameter()]
        [Alias('Quiet')]
        [switch] $Silent,

        # Set as the default context.
        [Parameter()]
        [switch] $Default,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType App
        $selectedInstallations = @()
        $moduleVersion = $script:PSModuleInfo.ModuleVersion
    }

    process {
        $selectedInstallations = [System.Collections.ArrayList]::new()
        switch ($PSCmdlet.ParameterSetName) {
            'Installation' {
                if ($Installation.Count -eq 1) {
                    Write-Verbose "Processing installation [$($Installation.Target.Name)] [$($Installation.ID)]"
                    $token = New-GitHubAppInstallationAccessToken -Context $Context -ID $Installation.ID

                    $contextParams = @{
                        AuthType         = [string]'IAT'
                        TokenType        = [string]'ghs'
                        DisplayName      = [string]$Context.DisplayName
                        ApiBaseUri       = [string]$Context.ApiBaseUri
                        ApiVersion       = [string]$Context.ApiVersion
                        HostName         = [string]$Context.HostName
                        HttpVersion      = [string]$Context.HttpVersion
                        PerPage          = [int]$Context.PerPage
                        ClientID         = [string]$Context.ClientID
                        InstallationID   = [string]$Installation.ID
                        Permissions      = [GitHubPermission[]]$Installation.Permissions
                        Events           = [string[]]$Installation.Events
                        InstallationType = [string]$Installation.Type
                        Token            = [securestring]$token.Token
                        TokenExpiresAt   = [datetime]$token.ExpiresAt
                    }

                    switch ($Installation.Type) {
                        'User' {
                            $contextParams['InstallationName'] = [string]$Installation.Target.Name
                            $contextParams['Owner'] = [string]$Installation.Target.Name
                        }
                        'Organization' {
                            $contextParams['InstallationName'] = [string]$Installation.Target.Name
                            $contextParams['Owner'] = [string]$Installation.Target.Name
                        }
                        'Enterprise' {
                            $contextParams['InstallationName'] = [string]$Installation.Target.Name
                            $contextParams['Enterprise'] = [string]$Installation.Target.Name
                        }
                    }
                    Write-Verbose 'Logging in using a managed installation access token...'
                    $contextParams | Format-Table | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
                    $attempts = 0
                    while ($true) {
                        try {
                            $contextObj = [GitHubAppInstallationContext]::new(
                                (Set-GitHubContext -Context $contextParams.Clone() -PassThru -Default:$Default)
                            )
                            break
                        } catch {
                            if ($attempts -lt 3) {
                                $attempts++
                                Write-Warning "Failed to create context. Retrying... [$attempts]"
                                Start-Sleep -Seconds (1 * $attempts)
                            } else {
                                throw $_
                            }
                        }
                    }
                    if ($VerbosePreference -eq 'Continue') {
                        $contextObj | Format-List | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
                    }
                    if (-not $Silent) {
                        $name = $contextObj.Name
                        $green = $PSStyle.Foreground.BrightGreen
                        $reset = $PSStyle.Reset
                        Write-Host "$green✓$reset Connected $name!"
                    }
                    if ($PassThru) {
                        Write-Debug "Passing context [$contextObj] to the pipeline."
                        Write-Output $contextObj
                    }
                    return
                }

                $Installation | ForEach-Object -ThrottleLimit $ThrottleLimit -UseNewRunspace -Parallel {
                    $attempts = 0
                    while ($true) {
                        try {
                            Import-Module -Name 'GitHub' -RequiredVersion $using:moduleVersion
                            $params = @{
                                Installation = $_
                                Context      = $using:Context
                                PassThru     = $using:PassThru
                                Silent       = $using:Silent
                                Default      = $using:Default
                            }
                            Connect-GitHubApp @params
                            break
                        } catch {
                            if ($attempts -lt 3) {
                                $attempts++
                                Start-Sleep -Seconds (1 * $attempts)
                            } else {
                                throw $_
                            }
                        }
                    }
                }
                return
            }
            'Filtered' {
                $installations = Get-GitHubAppInstallation -Context $Context
                Write-Verbose "Found [$($installations.Count)] installations."

                $User | ForEach-Object {
                    $userItem = $_
                    Write-Verbose "User filter:         [$userItem]."
                    $installations | Where-Object { $_.Type -eq 'User' -and $_.Target.Name -like $userItem } | ForEach-Object {
                        $null = $selectedInstallations.Add($_)
                    }
                }
                $Organization | ForEach-Object {
                    $organizationItem = $_
                    Write-Verbose "Organization filter: [$organizationItem]."
                    $installations | Where-Object { $_.Type -eq 'Organization' -and $_.Target.Name -like $organizationItem } | ForEach-Object {
                        $null = $selectedInstallations.Add($_)
                    }
                }
                $Enterprise | ForEach-Object {
                    $enterpriseItem = $_
                    Write-Verbose "Enterprise filter:   [$enterpriseItem]."
                    $installations | Where-Object { $_.Type -eq 'Enterprise' -and $_.Target.Name -like $enterpriseItem } | ForEach-Object {
                        $null = $selectedInstallations.Add($_)
                    }
                }
                $selectedInstallations | ForEach-Object -ThrottleLimit $ThrottleLimit -UseNewRunspace -Parallel {
                    $attempts = 0
                    while ($true) {
                        try {
                            Import-Module -Name 'GitHub' -RequiredVersion $using:moduleVersion
                            $params = @{
                                Installation = $_
                                Context      = $using:Context
                                PassThru     = $using:PassThru
                                Silent       = $using:Silent
                                Default      = $using:Default
                            }
                            Connect-GitHubApp @params
                            break
                        } catch {
                            if ($attempts -lt 3) {
                                $attempts++
                                Start-Sleep -Seconds (1 * $attempts)
                            } else {
                                throw $_
                            }
                        }
                    }
                }
                return
                break
            }
            'Installation ID' {
                Write-Verbose 'Selecting installations by explicit ID.'
                foreach ($installationId in $ID) {
                    Write-Verbose "Looking up installation ID [$installationId]"
                    $found = Get-GitHubAppInstallation -ID $installationId -Context $Context
                    if (-not $found) {
                        Write-Warning "No installation found for ID [$installationId]."
                        continue
                    }
                    $null = $selectedInstallations.Add($found)
                }
                break
            }
            'Installation object' {
                Write-Verbose 'Selecting installations from the pipeline.'
                foreach ($installationObject in $Installation) {
                    $null = $selectedInstallations.Add($installationObject)
                }
                break
            }
            'All Installations' {
                Write-Verbose 'No target specified. Connecting to all installations.'
                $selectedInstallations = Get-GitHubAppInstallation -Context $Context
                $selectedInstallations | ForEach-Object -ThrottleLimit $ThrottleLimit -UseNewRunspace -Parallel {
                    $attempts = 0
                    while ($true) {
                        try {
                            Import-Module -Name 'GitHub' -RequiredVersion $using:moduleVersion
                            $params = @{
                                Installation = $_
                                Context      = $using:Context
                                PassThru     = $using:PassThru
                                Silent       = $using:Silent
                                Default      = $using:Default
                            }
                            Connect-GitHubApp @params
                            break
                        } catch {
                            if ($attempts -lt 3) {
                                $attempts++
                                Start-Sleep -Seconds (1 * $attempts)
                            } else {
                                throw $_
                            }
                        }
                    }
                    $selectedInstallations.AddRange((Get-GitHubAppInstallation -Context $Context))
                    Write-Verbose "Found [$($selectedInstallations.Count)] installations."
                }
            }
        }

        Write-Verbose "Found [$($selectedInstallations.Count)] installations for the target."
        $selectedInstallations | ForEach-Object {
            $installation = $_
            Write-Verbose "Processing installation [$($installation.Target.Name)] [$($installation.id)]"
            $token = New-GitHubAppInstallationAccessToken -Context $Context -ID $installation.id

            $contextParams = @{
                AuthType         = [string]'IAT'
                TokenType        = [string]'ghs'
                DisplayName      = [string]$Context.DisplayName
                ApiBaseUri       = [string]$Context.ApiBaseUri
                ApiVersion       = [string]$Context.ApiVersion
                HostName         = [string]$Context.HostName
                HttpVersion      = [string]$Context.HttpVersion
                PerPage          = [int]$Context.PerPage
                ClientID         = [string]$Context.ClientID
                InstallationID   = [string]$installation.ID
                Permissions      = [GitHubPermission[]]$installation.Permissions
                Events           = [string[]]$installation.Events
                InstallationType = [string]$installation.Type
                Token            = [securestring]$token.Token
                TokenExpiresAt   = [datetime]$token.ExpiresAt
            }

            switch ($installation.Type) {
                'User' {
                    $contextParams['InstallationName'] = [string]$installation.Target.Name
                    $contextParams['Owner'] = [string]$installation.Target.Name
                }
                'Organization' {
                    $contextParams['InstallationName'] = [string]$installation.Target.Name
                    $contextParams['Owner'] = [string]$installation.Target.Name
                }
                'Enterprise' {
                    $contextParams['InstallationName'] = [string]$installation.Target.Name
                    $contextParams['Enterprise'] = [string]$installation.Target.Name
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
