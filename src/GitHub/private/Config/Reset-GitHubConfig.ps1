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
        Reset-GitHubConfig -Scope 'Auth'

        Resets the Auth related variables of the GitHub configuration.
    #>
    [Alias('Reset-GHConfig')]
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # Reset the GitHub configuration for a specific scope.
        [Parameter()]
        [ValidateSet('Auth', 'All')]
        [string] $Scope = 'All'
    )

    Write-Verbose "Resetting GitHub configuration for scope '$Scope'..."
    switch ($Scope) {
        'Auth' {
            $script:Config.AccessTokenType = ''
            $script:Config.AccessToken = [securestring]::new()
            $script:Config.AccessTokenExpirationDate = [datetime]::MinValue
            $script:Config.DeviceFlowType = ''
            $script:Config.RefreshToken = [securestring]::new()
            $script:Config.RefreshTokenExpirationDate = [datetime]::MinValue
            $script:Config.Scope = ''
            $script:Config.AuthType = ''
        }
        'All' {
            $script:Config = $script:ConfigTemplate | ConvertTo-Json -Depth 100 | ConvertFrom-Json -AsHashtable
        }
    }
    Save-GitHubConfig
}
