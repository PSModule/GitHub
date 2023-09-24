function Set-GitHubConfig {
    <#
        .SYNOPSIS
        Set the GitHub configuration.

        .DESCRIPTION
        Set the GitHub configuration. Specific scopes can be set by using the parameters.

        .EXAMPLE
        Set-GitHubConfig -APIBaseURI 'https://api.github.com' -APIVersion '2022-11-28'

        Sets the App.API scope of the GitHub configuration.
    #>
    [Alias('Set-GHConfig')]
    [CmdletBinding()]
    param (
        # Set the API Base URI.
        [Parameter()]
        [string] $APIBaseURI,

        # Set the GitHub API Version.
        [Parameter()]
        [string] $APIVersion,

        # Set the default for the Owner parameter.
        [Parameter()]
        [string] $Owner,

        # Set the default for the Repo parameter.
        [Parameter()]
        [string] $Repo
    )

    switch ($PSBoundParameters.Keys) {
        'APIBaseURI' {
            $script:Config.App.API.BaseURI = $APIBaseURI
        }
        'APIVersion' {
            $script:Config.App.API.Version = $APIVersion
        }
        'Owner' {
            $script:Config.User.Defaults.Owner = $Owner
        }
        'Repo' {
            $script:Config.User.Defaults.Repo = $Repo
        }
    }
    Save-GitHubConfig
}
