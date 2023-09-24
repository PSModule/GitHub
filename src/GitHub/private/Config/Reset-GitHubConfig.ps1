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
            $Settings = @{
                AccessTokenType = ''
                AccessToken = ''
                AccessTokenExpirationDate = [datetime]::MinValue
                DeviceFlowType = ''
                RefreshToken = ''
                RefreshTokenExpirationDate = [datetime]::MinValue
                Scope = ''
                AuthType = ''
            }
        }
        'All' {
            $Settings = @{
                AccessToken = ''
                AccessTokenExpirationDate = [datetime]::MinValue
                AccessTokenType = ''
                ApiBaseUri = 'https://api.github.com'
                ApiVersion = '2022-11-28'
                AuthType = ''
                DeviceFlowType = ''
                Owner = ''
                RefreshToken = ''
                RefreshTokenExpirationDate = [datetime]::MinValue
                Repo = ''
                Scope = ''
                UserName = ''
            }
        }
    }
    Set-GitHubConfig @Settings
}
