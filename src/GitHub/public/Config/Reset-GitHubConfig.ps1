function Reset-GitHubConfig {
    <#
        .SYNOPSIS
        Reset the GitHub configuration.

        .DESCRIPTION
        Reset the GitHub configuration. Specific scopes can be reset by using the Scope parameter.

        .EXAMPLE
        Reset-GitHubConfig

        Resets the entire GitHub configuration.

        .EXAMPLE
        Reset-GitHubConfig -Scope 'App.API'

        Resets the App.API scope of the GitHub configuration.
    #>
    [Alias('Reset-GHConfig')]
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # Reset the GitHub configuration for a specific scope.
        [Parameter()]
        [ValidateSet('App', 'App.API', 'App.Defaults', 'User', 'User.Auth', 'User.Defaults', 'All')]
        [string] $Scope = 'All'
    )

    Write-Verbose "Resetting GitHub configuration for scope '$Scope'..."
    switch ($Scope) {
        'App' {
            $script:Config.App = [App]::new()
        }
        'App.API' {
            $script:Config.App.API = [API]::new()
        }
        'App.Defaults' {
            $script:Config.App.Defaults = [AppDefaults]::new()
        }
        'User' {
            $script:Config.User = [User]::new()
        }
        'User.Auth' {
            $script:Config.User.Auth = [Auth]::new()
        }
        'User.Defaults' {
            $script:Config.User.Defaults = [UserDefaults]::new()
        }
        'All' {
            $script:Config = [Config]::new()
        }
    }

    Save-GitHubConfig
}
