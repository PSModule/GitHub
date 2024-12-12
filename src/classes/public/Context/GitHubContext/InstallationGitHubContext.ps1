﻿class InstallationGitHubContext : GitHubContext {
    # Client ID for GitHub Apps
    [string] $ClientID

    # The token expiration date.
    # 2024-01-01-00:00:00
    [datetime] $TokenExpirationDate

    # The installation ID.
    [int] $InstallationID

    # The permissions that the app is requesting on the target
    [pscustomobject] $Permissions

    # The events that the app is subscribing to once installed
    [string[]] $Events

    # The target type of the installation.
    [string] $TargetType

    # The target login of the installation.
    [string] $TargetName

    # Creates a context object from a hashtable of key-vaule pairs.
    InstallationGitHubContext([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    InstallationGitHubContext([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
