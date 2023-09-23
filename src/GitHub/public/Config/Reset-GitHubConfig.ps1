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
            $script:Config.App = $script:ConfigTemplate.App | Copy-Object
        }
        'App.API' {
            $script:Config.App.API = $script:ConfigTemplate.App.API | Copy-Object
        }
        'App.Defaults' {
            $script:Config.App.Defaults = $script:ConfigTemplate.App.Defaults | Copy-Object
        }
        'User' {
            $script:Config.User = $script:ConfigTemplate.User | Copy-Object
        }
        'User.Auth' {
            $script:Config.User.Auth = $script:ConfigTemplate.User.Auth | Copy-Object
        }
        'User.Defaults' {
            $script:Config.User.Defaults = $script:ConfigTemplate.User.Defaults | Copy-Object
        }
        'All' {
            $script:Config = $script:ConfigTemplate | Copy-Object
        }
    }

    Save-GitHubConfig
}
