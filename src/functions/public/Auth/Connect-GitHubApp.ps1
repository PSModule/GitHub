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

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    $Context = $Context | Resolve-GitHubContext
    $Context | Assert-GitHubContext -AuthType 'App'

    try {
        $defaultContextData = @{
            ApiBaseUri = $Context.ApiBaseUri
            ApiVersion = $Context.ApiVersion
            HostName   = $Context.HostName
            ClientID   = $Context.ClientID
            AuthType   = 'IAT'
            TokenType  = 'ghs'
        }

        $installations = Get-GitHubAppInstallation
        switch ($PSCmdlet.ParameterSetName) {
            'User' {
                $installations = $installations | Where-Object { $_.target_type -eq 'User' -and $_.account.login -in $User }
            }
            'Organization' {
                $installations = $installations | Where-Object { $_.target_type -eq 'Organization' -and $_.account.login -in $Organization }
            }
            'Enterprise' {
                $installations = $installations | Where-Object { $_.target_type -eq 'Enterprise' -and $_.account.slug -in $Enterprise }
            }
        }

        $installations | ForEach-Object {
            $installation = $_
            $contextParams = @{} + $defaultContextData.Clone()
            $token = New-GitHubAppInstallationAccessToken -InstallationID $installation.id
            $contextParams += @{
                InstallationID      = $installation.id
                Token               = $token.Token
                TokenExpirationDate = $token.ExpiresAt
            }
            switch ($installation.target_type) {
                'User' {
                    $contextParams['Owner'] = $installation.account.login
                }
                'Organization' {
                    $contextParams['Owner'] = $installation.account.login
                }
                'Enterprise' {
                    $contextParams['Enterprise'] = $installation.account.slug
                }
            }
            Write-Verbose 'Logging in using an installation access token...'
            Write-Verbose ($contextParams | Format-Table | Out-String)
            $tmpContext = Set-GitHubContext @contextParams -PassThru
            Write-Verbose ($tmpContext | Format-List | Out-String)
            if (-not $Silent) {
                $name = $tmpContext.name
                Write-Host "Connected $name"
            }
            Remove-Variable -Name tmpContext -ErrorAction SilentlyContinue
            Remove-Variable -Name token -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Error $_
        Write-Error (Get-PSCallStack | Format-Table | Out-String)
        throw 'Failed to connect to GitHub using a GitHub App.'
    } finally {
        [System.GC]::Collect()
    }
    Write-Verbose "[$commandName] - End"
}

Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName User -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubAppInstallation -Verbose:$false | Where-Object { $_.target_type -eq 'User' -and $_.account.login -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.account.login, $_.account.login, 'ParameterValue', $_.account.login)
        }
}
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName Organization -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubAppInstallation -Verbose:$false | Where-Object { $_.target_type -eq 'Organization' -and $_.account.login -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.account.login, $_.account.login, 'ParameterValue', $_.account.login)
        }
}
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName Enterprise -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubAppInstallation -Verbose:$false | Where-Object { $_.target_type -eq 'Enterprise' -and $_.account.slug -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.account.slug, $_.account.slug, 'ParameterValue', $_.account.slug)
        }
}
