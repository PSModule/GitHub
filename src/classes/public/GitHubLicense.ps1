﻿class GitHubLicenseRule {
    # A description of the rule.
    [string] $Description

    # The machine-readable rule key.
    [string] $Key

    # The human-readable rule label.
    [string] $Label

    GitHubLicenseRule() {}

    GitHubLicenseRule([PSCustomObject]$Object) {
        $this.Description = $Object.description
        $this.Key = $Object.key
        $this.Label = $Object.label
    }

    [string] ToString() {
        return $this.Description
    }
}


class GitHubLicense {
    # The license key, used as an identifier.
    # Example: 'mit'
    [string] $Key

    # The full name of the license.
    # Example: 'MIT License'
    [string] $Name

    # Customary short name if applicable (e.g, GPLv3).
    # Example: 'MIT'
    [string] $NickName

    # The SPDX identifier of the license, or $null.
    # Example: 'MIT'
    [string] $SpdxId

    # The node ID of the license.
    # Example: 'MDc6TGljZW5zZW1pdA=='
    [string] $NodeID

    # The HTML URL where the license can be viewed.
    # Example: 'http://choosealicense.com/licenses/mit/'
    [string] $Url

    # A short description of the license.
    # Example: 'A permissive license that is short and to the point...'
    [string] $Description

    # Instructions for implementing the license in a project.
    # Example: 'Create a text file (typically named LICENSE or LICENSE.txt)...'
    [string] $Implementation

    # A list of permissions granted by the license.
    # Example: @('commercial-use', 'modifications', 'distribution', 'sublicense', 'private-use')
    [string[]] $Permissions

    # A list of conditions required by the license.
    # @('include-copyright')
    [string[]] $Conditions

    # A list of limitations of the license.
    # Example: @('no-liability')
    [string[]] $Limitations

    # The full body text of the license.
    # Example: 'The MIT License (MIT)...'
    [string] $Body

    # Indicates if this license is featured.
    # Example: $true
    [System.Nullable[bool]] $Featured

    GitHubLicense() {}

    GitHubLicense([PSCustomObject]$Object) {
        $this.Key = $Object.key
        $this.Name = $Object.name
        $this.NickName = $Object.nickname
        $this.SpdxId = $Object.spdx_id ?? $Object.spdxId
        $this.NodeID = $Object.node_id ?? $Object.id
        $this.Url = $Object.html_url ?? $Object.url
        $this.Description = $Object.description
        $this.Implementation = $Object.implementation
        $this.Permissions = [GitHubLicenseRule]::new($Object.permissions)
        $this.Conditions = [GitHubLicenseRule]::new($Object.conditions)
        $this.Limitations = [GitHubLicenseRule]::new($Object.limitations)
        $this.Body = $Object.body
        $this.Featured = $Object.featured
    }

    [string] ToString() {
        return $this.Name
    }
}
