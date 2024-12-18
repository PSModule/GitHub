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
        Connect-GitHubApp -Organization 'psmodule'

        Connects to GitHub as the organization 'psmodule' using the logged in GitHub App.

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
        [Parameter(
            Mandatory,
            ParameterSetName = 'User'
        )]
        [string] $User,

        # The organization to connect to.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Organization'
        )]
        [string] $Organization,

        # The enterprise to connect to.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Enterprise'
        )]
        [string] $Enterprise,

        # Passes the context object to the pipeline.
        [Parameter()]
        [switch] $PassThru,

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
            Write-Verbose "Found [$($installations.Count)] installations."
            switch ($PSCmdlet.ParameterSetName) {
                'User' {
                    Write-Verbose "Filtering installations for user [$User]."
                    $installations = $installations | Where-Object { $_.target_type -eq 'User' -and $_.account.login -in $User }
                }
                'Organization' {
                    Write-Verbose "Filtering installations for organization [$Organization]."
                    $installations = $installations | Where-Object { $_.target_type -eq 'Organization' -and $_.account.login -in $Organization }
                }
                'Enterprise' {
                    Write-Verbose "Filtering installations for enterprise [$Enterprise]."
                    $installations = $installations | Where-Object { $_.target_type -eq 'Enterprise' -and $_.account.slug -in $Enterprise }
                }
            }

            Write-Verbose "Found [$($installations.Count)] installations for the target."
            $installations | ForEach-Object {
                $installation = $_
                Write-Verbose "Processing installation [$($installation.account.login)] [$($installation.id)]"
                $token = New-GitHubAppInstallationAccessToken -Context $Context -InstallationID $installation.id

                $contextParams = @{
                    AuthType            = [string]'IAT'
                    TokenType           = [string]'ghs'
                    DisplayName         = [string]$Context.DisplayName
                    ApiBaseUri          = [uri]$Context.ApiBaseUri
                    ApiVersion          = [string]$Context.ApiVersion
                    HostName            = [string]$Context.HostName
                    ClientID            = [string]$Context.ClientID
                    InstallationID      = [string]$installation.id
                    Permissions         = [pscustomobject]$installation.permissions
                    Events              = [string[]]$installation.events
                    TargetType          = [string]$installation.target_type
                    Token               = [securestring]$token.Token
                    TokenExpirationDate = [datetime]$token.ExpiresAt
                }

                switch ($installation.target_type) {
                    'User' {
                        $contextParams['TargetName'] = [string]$installation.account.login
                    }
                    'Organization' {
                        $contextParams['TargetName'] = [string]$installation.account.login
                    }
                    'Enterprise' {
                        $contextParams['TargetName'] = [string]$installation.account.slug
                    }
                }
                Write-Verbose 'Logging in using a managed installation access token...'
                Write-Verbose ($contextParams | Format-Table | Out-String)
                $tmpContext = [InstallationGitHubContext]::new((Set-GitHubContext -Context $contextParams.Clone() -PassThru))
                Write-Verbose ($tmpContext | Format-List | Out-String)
                if (-not $Silent) {
                    $name = $tmpContext.name
                    Write-Host '✓ ' -ForegroundColor Green -NoNewline
                    Write-Host "Connected $name!"
                }
                if ($PassThru) {
                    $tmpContext
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
