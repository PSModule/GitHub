function Connect-GitHubApp {
    <#
        .SYNOPSIS
        Connects to GitHub as a installation using a GitHub App.

        .DESCRIPTION
        Connects to GitHub using a GitHub App to generate installation access tokens and create contexts for targets.

        Available target types:
        - User
        - Organization
        - Enterprise

        .EXAMPLE
        Connect-GitHubApp

        Connects to GitHub as all available targets using the logged in GitHub App.

        .EXAMPLE
        Connect-GitHubApp -User 'octocat'

        Connects to GitHub as the user 'octocat' using the logged in GitHub App.

        .EXAMPLE
        Connect-GitHubApp -Organization 'psmodule' -Default

        Connects to GitHub as the organization 'psmodule' using the logged in GitHub App and sets it as the default context.

        .EXAMPLE
        Connect-GitHubApp -Enterprise 'msx'

        Connects to GitHub as the enterprise 'msx' using the logged in GitHub App.

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
        [Parameter(ParameterSetName = 'Filtered')]
        [SupportsWildcards()]
        [string[]] $User,

        # The organization to connect to.
        [Parameter(ParameterSetName = 'Filtered')]
        [SupportsWildcards()]
        [string[]] $Organization,

        # The enterprise to connect to.
        [Parameter(ParameterSetName = 'Filtered')]
        [SupportsWildcards()]
        [string[]] $Enterprise,

        # Installation objects from pipeline for parallel processing.
        [Parameter(Mandatory, ParameterSetName = 'Installation object', ValueFromPipeline)]
        [GitHubAppInstallation[]] $Installation,

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

        # The maximum number of parallel threads to use when connecting to multiple installations.
        [Parameter()]
        [int] $ThrottleLimit = [System.Environment]::ProcessorCount,

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
    }

    process {
        $selectedInstallations = [System.Collections.ArrayList]::new()
        switch ($PSCmdlet.ParameterSetName) {
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
            default {
                Write-Verbose 'No target specified. Connecting to all installations.'
                $selectedInstallations.AddRange((Get-GitHubAppInstallation -Context $Context))
                Write-Verbose "Found [$($selectedInstallations.Count)] installations."
            }
        }

        Write-Verbose "Found [$($selectedInstallations.Count)] installations for the target."
        $moduleName = $script:Module.Name
        $moduleVersion = $script:PSModuleInfo.ModuleVersion
        $contextParamList = @()
        $contextParamList += $selectedInstallations | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
            Import-Module -Name $using:moduleName -RequiredVersion $using:moduleVersion -Force -ErrorAction Stop
            $installation = $_
            Write-Verbose "Processing installation [$($installation.Target.Name)] [$($installation.id)]"
            $token = New-GitHubAppInstallationAccessToken -Context $using:Context -ID $installation.id

            $contextParams = @{
                AuthType         = [string]'IAT'
                TokenType        = [string]'ghs'
                DisplayName      = [string]$using:Context.DisplayName
                ApiBaseUri       = [string]$using:Context.ApiBaseUri
                ApiVersion       = [string]$using:Context.ApiVersion
                HostName         = [string]$using:Context.HostName
                HttpVersion      = [string]$using:Context.HttpVersion
                PerPage          = [int]$using:Context.PerPage
                ClientID         = [string]$using:Context.ClientID
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
            $contextParams
        }
    }

    end {
        foreach ($contextParams in ($contextParamList | Where-Object { $_ -is [hashtable] })) {
            Write-Verbose 'Logging in using a managed installation access token...'
            $contextParams | Format-Table | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
            $contextObj = [GitHubAppInstallationContext]::new((Set-GitHubContext -Context $contextParams.Clone() -PassThru -Default:$Default))
            $contextObj | Format-List | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
            if (-not $Silent) {
                $name = $contextObj.Name
                $green = $PSStyle.Foreground.Green
                $reset = $PSStyle.Reset
                Write-Host "$green✓$reset Connected $name!"
            }
            if ($PassThru) {
                Write-Debug "Passing context [$contextObj] to the pipeline."
                Write-Output $contextObj
            }
            $contextParams.Clear()
        }
        Write-Debug "[$stackPath] - End"
    }
}
