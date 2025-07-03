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
    [CmdletBinding(DefaultParameterSetName = '__AllParameterSets')]
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
    }

    process {
        $installations = Get-GitHubAppInstallation -Context $Context
        $selectedInstallations = @()
        Write-Verbose "Found [$($installations.Count)] installations."
        switch ($PSCmdlet.ParameterSetName) {
            'Filtered' {
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
            }
            default {
                Write-Verbose 'No target specified. Connecting to all installations.'
                $selectedInstallations = $installations
            }
        }

        Write-Verbose "Found [$($selectedInstallations.Count)] installations for the target."
        $selectedInstallations | ForEach-Object {
            $installation = $_
            Write-Verbose "Processing installation [$($installation.Target.Name)] [$($installation.id)]"
            $token = New-GitHubAppInstallationAccessToken -Context $Context -InstallationID $installation.id

            $contextParams = @{
                AuthType            = [string]'IAT'
                TokenType           = [string]'ghs'
                DisplayName         = [string]$Context.DisplayName
                ApiBaseUri          = [string]$Context.ApiBaseUri
                ApiVersion          = [string]$Context.ApiVersion
                HostName            = [string]$Context.HostName
                HttpVersion         = [string]$Context.HttpVersion
                PerPage             = [int]$Context.PerPage
                ClientID            = [string]$Context.ClientID
                InstallationID      = [string]$installation.id
                Permissions         = [pscustomobject]$installation.permissions
                Events              = [string[]]$installation.events
                InstallationType    = [string]$installation.Type
                Token               = [securestring]$token.Token
                TokenExpirationDate = [datetime]$token.ExpiresAt
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
            Write-Verbose 'Logging in using a managed installation access token...'
            $contextParams | Format-Table | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
            $contextObj = [InstallationGitHubContext]::new((Set-GitHubContext -Context $contextParams.Clone() -PassThru -Default:$Default))
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
            $contextParams.Clear()
        }

    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
