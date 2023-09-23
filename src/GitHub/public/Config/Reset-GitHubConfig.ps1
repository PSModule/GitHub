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

    switch ($Scope) {
        'App' {
            $script:Config.App = $script:ConfigTemplate.App
        }
        'App.API' {
            $script:Config.App.API = $script:ConfigTemplate.App.API
        }
        'App.Defaults' {
            $script:Config.App.Defaults = $script:ConfigTemplate.App.Defaults
        }
        'User' {
            $script:Config.User = $script:ConfigTemplate.User
        }
        'User.Auth' {
            $script:Config.User.Auth = $script:ConfigTemplate.User.Auth
        }
        'User.Defaults' {
            $script:Config.User.Defaults = $script:ConfigTemplate.User.Defaults
        }
        'All' {
            $script:Config = $script:ConfigTemplateDefaults
        }
    }
    Save-GitHubConfig
}
