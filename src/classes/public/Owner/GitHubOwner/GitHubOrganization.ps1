class GitHubOrganization : GitHubOwner {
    # The description of the organization.
    # Example: A great organization
    [string] $Description

    # Whether the organization is verified.
    # Example: $true
    [System.Nullable[bool]] $IsVerified

    # Whether organization projects are enabled.
    # Example: $true
    [System.Nullable[bool]] $HasOrganizationProjects

    # Whether repository projects are enabled.
    # Example: $true
    [System.Nullable[bool]] $HasRepositoryProjects

    # The billing email address for the organization.
    # Example: org@example.com
    [string] $BillingEmail

    # The date and time when the organization was archived, if applicable.
    [System.Nullable[datetime]] $ArchivedAt

    # Simple parameterless constructor
    GitHubOrganization() {}

    # Creates an object from a hashtable of key-value pairs.
    GitHubOrganization([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubOrganization([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    [string] ToString() {
        return $this.Name
    }
}
