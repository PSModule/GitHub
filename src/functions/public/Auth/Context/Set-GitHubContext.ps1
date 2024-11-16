﻿#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '2.0.4' }

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
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The Node ID of the context.
        [Parameter()]
        [string] $NodeID,

        # The Database ID of the context.
        [Parameter()]
        [string] $DatabaseID,

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
        [string] $Scope
    )

    $tempContextName = 'tempContext'
    $Name = "$($script:Config.Name)/$tempContextName"

    # Set a temporary context.
    $context = @{
        ApiBaseUri                 = $ApiBaseUri                 # https://api.github.com
        ApiVersion                 = $ApiVersion                 # 2022-11-28
        AuthClientID               = $AuthClientID               # Client ID for UAT
        AuthType                   = $AuthType                   # UAT / PAT / App / IAT
        ClientID                   = $ClientID                   # Client ID for GitHub Apps
        DeviceFlowType             = $DeviceFlowType             # GitHubApp / OAuthApp
        HostName                   = $HostName                   # github.com / msx.ghe.com / github.local
        NodeID                     = $NodeID                     # User ID / app ID (GraphQL Node ID)
        DatabaseID                 = $DatabaseID                 # Database ID
        Name                       = $Name                       # HostName/Username or HostName/AppSlug
        UserName                   = $UserName                   # User name
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

    Set-Context $context # Not splatting, but actually passing the hashtable.

    # Run functions to get info on the temporary context.
    try {
        Write-Verbose 'Getting info on the context.'
        switch -Regex ($context['AuthType']) {
            'PAT|UAT|IAT' {
                $viewer = Get-GitHubViewer -Context $tempContextName
                $newName = "$($Script:Config.Name)/$HostName/$($viewer.login)"
                $context['Name'] = $newName
                $context['Username'] = $viewer.login
                $context['NodeID'] = $viewer.id
                $context['DatabaseID'] = ($viewer.databaseId).ToString()
            }
            'App' {
                $app = Get-GitHubApp -Context $tempContextName
                $newName = "$($Script:Config.Name)/$HostName/$($app.slug)"
                $context['Name'] = $newName
                $context['Username'] = $app.slug
                $context['NodeID'] = $app.node_id
                $context['DatabaseID'] = $app.id
            }
            default {
                throw 'Failed to get info on the context. Unknown logon type.'
            }
        }
        Write-Verbose $($context['Username'])
    } catch {
        Write-Error $_
        throw 'Failed to get info on the context.'
    }

    if ($PSCmdlet.ShouldProcess('Context', 'Set')) {
        Set-Context $context
        Remove-Context -Name $Name
    }
    Write-Verbose (Get-SecretInfo | Out-String)
    Get-Context -Name $newName -AsPlainText
}