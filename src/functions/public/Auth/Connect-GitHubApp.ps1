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
    #>
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'The tokens are recieved as clear text. Mitigating exposure by removing variables and performing garbage collection.')]
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
        [Alias('q')]
        [Alias('s')]
        [switch] $Silent,

        # Set as the default context.
        [Parameter()]
        [switch] $Default,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            $Context = $Context | Resolve-GitHubContext
            $Context | Assert-GitHubContext -AuthType 'App'

            $installations = Get-GitHubAppInstallation -Context $Context
            $selectedInstallations = @()
            Write-Verbose "Found [$($installations.Count)] installations."
            switch ($PSCmdlet.ParameterSetName) {
                'Filtered' {
                    $User | ForEach-Object {
                        $userItem = $_
                        Write-Verbose "User filter:         [$userItem]."
                        $selectedInstallations += $installations | Where-Object {
                            $_.target_type -eq 'User' -and $_.account.login -like $userItem
                        }
                    }
                    $Organization | ForEach-Object {
                        $organizationItem = $_
                        Write-Verbose "Organization filter: [$organizationItem]."
                        $selectedInstallations += $installations | Where-Object {
                            $_.target_type -eq 'Organization' -and $_.account.login -like $organizationItem
                        }
                    }
                    $Enterprise | ForEach-Object {
                        $enterpriseItem = $_
                        Write-Verbose "Enterprise filter:   [$enterpriseItem]."
                        $selectedInstallations += $installations | Where-Object {
                            $_.target_type -eq 'Enterprise' -and $_.account.slug -like $enterpriseItem
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
                Write-Verbose "Processing installation [$($installation.account.login)] [$($installation.id)]"
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
                    InstallationType    = [string]$installation.target_type
                    Token               = [securestring]$token.Token
                    TokenExpirationDate = [datetime]$token.ExpiresAt
                }

                switch ($installation.target_type) {
                    'User' {
                        $contextParams['InstallationName'] = [string]$installation.account.login
                        $contextParams['Owner'] = [string]$installation.account.login
                    }
                    'Organization' {
                        $contextParams['InstallationName'] = [string]$installation.account.login
                        $contextParams['Owner'] = [string]$installation.account.login
                    }
                    'Enterprise' {
                        $contextParams['InstallationName'] = [string]$installation.account.slug
                        $contextParams['Enterprise'] = [string]$installation.account.slug
                    }
                }
                Write-Verbose 'Logging in using a managed installation access token...'
                Write-Verbose ($contextParams | Format-Table | Out-String)
                $contextObj = [InstallationGitHubContext]::new((Set-GitHubContext -Context $contextParams.Clone() -PassThru -Default:$Default))
                Write-Verbose ($contextObj | Format-List | Out-String)
                if (-not $Silent) {
                    $name = $contextObj.name
                    Write-Host '✓ ' -ForegroundColor Green -NoNewline
                    Write-Host "Connected $name!"
                }
                if ($PassThru) {
                    Write-Debug "Passing context [$contextObj] to the pipeline."
                    Write-Output $contextObj
                }
                $contextParams.Clear()
            }
        } catch {
            Write-Error $_
            throw 'Failed to connect to GitHub using a GitHub App.'
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
