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
        Connect-GitHubApp -User '*', -Organization 'psmodule', 'github' -ThrottleLimit 8

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
        [Parameter(Mandatory, ParameterSetName = 'Installation', ValueFromPipeline)]
        [GitHubAppInstallation[]] $Installation,

        # The maximum number of parallel operations to run at once.
        [Parameter(ParameterSetName = 'Filtered')]
        [Parameter(ParameterSetName = 'Installation')]
        [uint] $ThrottleLimit = ([Environment]::ProcessorCount * 2),

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
    }

    process {
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
                    Write-Verbose 'Logging in using a managed installation access token...'
                    $contextParams | Format-Table | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
                    while ($true) {
                        try {
                            $contextObj = [GitHubAppInstallationContext]::new((Set-GitHubContext -Context $contextParams.Clone() -PassThru -Default:$Default))
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
                    $contextObj | Format-List | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
                    if (-not $Silent) {
                        $name = $contextObj.Name
                        if ($script:IsGitHubActions) {
                            $green = $PSStyle.Foreground.Green
                            $reset = $PSStyle.Reset
                            Write-Host "$green✓$reset Connected $name!"
                        } else {
                            Write-Host '✓ ' -ForegroundColor Green -NoNewline
                            Write-Host "Connected $name!"
                        }
                    }
                    if ($PassThru) {
                        Write-Debug "Passing context [$contextObj] to the pipeline."
                        Write-Output $contextObj
                    }
                    return
                }

                $Installation | ForEach-Object -ThrottleLimit $ThrottleLimit -UseNewRunspace -Parallel {
                    Write-Host "Using GitHub $($script:PSModuleInfo.ModuleVersion)"
                    Import-Module -Name 'GitHub' -RequiredVersion $script:PSModuleInfo.ModuleVersion
                    $params = @{
                        Installation = $_
                        Context      = $using:Context
                        PassThru     = $using:PassThru
                        Silent       = $using:Silent
                        Default      = $using:Default
                    }
                    Connect-GitHubApp @params
                }
                return
            }
            'Filtered' {
                $installations = Get-GitHubAppInstallation -Context $Context
                Write-Verbose "Found [$($installations.Count)] installations."

                $User | ForEach-Object {
                    $userItem = $_
                    Write-Verbose "User filter:         [$userItem]."
                    $selectedInstallations += $installations | Where-Object {
                        $_.Type -eq 'User' -and $_.Target.Name -like $userItem
                    }
                }
                $Organization | ForEach-Object {
                    $organizationItem = $_
                    Write-Verbose "Organization filter: [$organizationItem]."
                    $selectedInstallations += $installations | Where-Object {
                        $_.Type -eq 'Organization' -and $_.Target.Name -like $organizationItem
                    }
                }
                $Enterprise | ForEach-Object {
                    $enterpriseItem = $_
                    Write-Verbose "Enterprise filter:   [$enterpriseItem]."
                    $selectedInstallations += $installations | Where-Object {
                        $_.Type -eq 'Enterprise' -and $_.Target.Name -like $enterpriseItem
                    }
                }
                $selectedInstallations | ForEach-Object -ThrottleLimit $ThrottleLimit -UseNewRunspace -Parallel {
                    Import-Module -Name 'GitHub' -RequiredVersion $script:PSModuleInfo.ModuleVersion -Force
                    $params = @{
                        Installation = $_
                        Context      = $using:Context
                        PassThru     = $using:PassThru
                        Silent       = $using:Silent
                        Default      = $using:Default
                    }
                    Connect-GitHubApp @params
                }
                return
            }
            'All Installations' {
                Write-Verbose 'No target specified. Connecting to all installations.'
                $selectedInstallations = Get-GitHubAppInstallation -Context $Context
                $selectedInstallations | ForEach-Object -ThrottleLimit $ThrottleLimit -UseNewRunspace -Parallel {
                    Import-Module -Name 'GitHub' -RequiredVersion $script:PSModuleInfo.ModuleVersion -Force
                    $params = @{
                        Installation = $_
                        Context      = $using:Context
                        PassThru     = $using:PassThru
                        Silent       = $using:Silent
                        Default      = $using:Default
                    }
                    Connect-GitHubApp @params
                }
                return
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
