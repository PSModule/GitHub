function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set the GitHub configuration.

        .DESCRIPTION
        Set the GitHub configuration. Specific scopes can be set by using the parameters.

        .EXAMPLE
        Set-GitHubConfig -APIBaseURI 'https://api.github.com' -APIVersion '2022-11-28'

        Sets the App.API scope of the GitHub configuration.

        .EXAMPLE
        Set-GitHubConfig -Name 'MyFavouriteRepo' -Value 'https://github.com/PSModule/GitHub'

        Sets a item called 'MyFavouriteRepo' in the GitHub configuration.
    #>
    [Alias('Set-GHConfig')]
    [CmdletBinding()]
    param (
        # Set the API Base URI.
        [Parameter()]
        [string] $ApiBaseUri,

        # Set the GitHub API Version.
        [Parameter()]
        [string] $ApiVersion,

        # Set the default for the Owner parameter.
        [Parameter()]
        [string] $Owner,

        # Set the default for the Repo parameter.
        [Parameter()]
        [string] $Repo,

        # Choose a custom name to set.
        [Parameter()]
        [string] $Name,

        # Choose a custom value to set.
        [Parameter()]
        [string] $Value = ''
    )

    switch ($PSBoundParameters.Keys) {
        'ApiBaseUri' {
            $script:Config.ApiBaseUri = $ApiBaseUri
        }
        'ApiVersion' {
            $script:Config.ApiVersion = $ApiVersion
        }
        'Owner' {
            $script:Config.Owner = $Owner
        }
        'Repo' {
            $script:Config.Repo = $Repo
        }
        'Name' {
            $script:Config.$Name = $Value
        }
    }
    Save-GitHubConfig
}
