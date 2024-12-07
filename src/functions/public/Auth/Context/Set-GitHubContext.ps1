#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '4.0.0' }

function Set-GitHubContext {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .EXAMPLE
        An example

        .NOTES
        General notes
    #>
    [OutputType([GitHubContext])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Set the access token type.
        [Parameter(Mandatory)]
        [string] $TokenType,

        # Set the client ID.
        [Parameter()]
        [string] $ClientID,

        # Set the access token.
        [Parameter(Mandatory)]
        [securestring] $Token,

        # Set the expiration date of the contexts token.
        [Parameter()]
        [datetime] $TokenExpirationDate,

        # Set the API Base URI.
        [Parameter(Mandatory)]
        [string] $ApiBaseUri,

        # Set the GitHub API Version.
        [Parameter(Mandatory)]
        [string] $ApiVersion,

        # Set the authentication client ID.
        [Parameter()]
        [string] $AuthClientID,

        # Set the authentication type.
        [Parameter(Mandatory)]
        [string] $AuthType,

        # Set the device flow type.
        [Parameter()]
        [string] $DeviceFlowType,

        # Set the API hostname.
        [Parameter(Mandatory)]
        [string] $HostName,

        # Set the installation ID.
        [Parameter()]
        [int] $InstallationID,

        # Set the enterprise name for the context.
        [Parameter()]
        [string] $Enterprise,

        # Set the default for the Owner parameter.
        [Parameter()]
        [string] $Owner,

        # Set the refresh token.
        [Parameter()]
        [securestring] $RefreshToken,

        # Set the refresh token expiration date.
        [Parameter()]
        [datetime] $RefreshTokenExpirationDate,

        # Set the default for the Repo parameter.
        [Parameter()]
        [string] $Repo,

        # Set the scope.
        [Parameter()]
        [string] $Scope,

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
    }

    process {
        $context = @{
            ApiBaseUri                 = $ApiBaseUri                 # https://api.github.com
            ApiVersion                 = $ApiVersion                 # 2022-11-28
            AuthClientID               = $AuthClientID               # Client ID for UAT
            AuthType                   = $AuthType                   # UAT / PAT / App / IAT
            ClientID                   = $ClientID                   # Client ID for GitHub Apps
            InstallationID             = $InstallationID            # Installation ID
            DeviceFlowType             = $DeviceFlowType             # GitHubApp / OAuthApp
            HostName                   = $HostName                   # github.com / msx.ghe.com / github.local
            Enterprise                 = $Enterprise                 # Enterprise name
            Owner                      = $Owner                      # Owner name
            Repo                       = $Repo                       # Repo name
            Scope                      = $Scope                      # 'gist read:org repo workflow'
            #-----------------------------------------------------------------------------------------
            TokenType                  = $TokenType                  # ghu / gho / ghp / github_pat / PEM / ghs /
            Token                      = $Token                      # Access token
            TokenExpirationDate        = $TokenExpirationDate        # 2024-01-01-00:00:00
            RefreshToken               = $RefreshToken               # Refresh token
            RefreshTokenExpirationDate = $RefreshTokenExpirationDate # 2024-01-01-00:00:00
        }

        $context | Remove-HashtableEntry -NullOrEmptyValues
        $tempContext = [GitHubContext]$context

        # Run functions to get info on the temporary context.
        try {
            Write-Verbose 'Getting info on the context.'
            switch -Regex ($AuthType) {
                'PAT|UAT|IAT' {
                    $viewer = Get-GitHubViewer -Context $tempContext
                    $login = $viewer.login
                    $context['Username'] = $login
                    $context['NodeID'] = $viewer.id
                    $context['DatabaseID'] = ($viewer.databaseId).ToString()
                }
                'PAT|UAT' {
                    $contextName = "$HostName/$login"
                    $context['Name'] = $contextName
                    $context['Type'] = 'User'
                }
                'IAT' {
                    $contextName = "$HostName/$login/$Owner" -Replace '\[bot\]'
                    $context['Name'] = $contextName
                    $context['Type'] = 'Installation'
                }
                'App' {
                    $app = Get-GitHubApp -Context $tempContext
                    $contextName = "$HostName/$($app.slug)"
                    $context['Name'] = $contextName
                    $context['Username'] = $app.slug
                    $context['NodeID'] = $app.node_id
                    $context['DatabaseID'] = $app.id
                    $context['Type'] = 'App'
                }
                default {
                    throw 'Failed to get info on the context. Unknown logon type.'
                }
            }
            Write-Verbose "Found [$($context['Type'])] with login: [$contextName]"

            if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
                Set-Context -ID "$($script:Config.Name)/$contextName" -Context $context
                if ($Default) {
                    Set-GitHubDefaultContext -Context $contextName
                    if ($AuthType -eq 'IAT' -and $script:runEnv -eq 'GHA') {
                        Set-GitHubGitConfig -Context $contextName
                    }
                }
                if ($PassThru) {
                    Get-GitHubContext -Context $contextName
                }
            }
        } catch {
            throw ($_ -join ';')
        }
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
