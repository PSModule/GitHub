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

    # The public repository count.
    # Example: 2
    [System.Nullable[uint]] $PublicRepos

    # The public gist count.
    # Example: 1
    [System.Nullable[uint]] $PublicGists

    # The number of followers.
    # Example: 20
    [System.Nullable[uint]] $Followers

    # The number of accounts the organization is following.
    # Example: 0
    [System.Nullable[uint]] $Following

    # The number of total private repositories.
    # Example: 100
    [System.Nullable[uint]] $TotalPrivateRepos

    # The number of owned private repositories.
    # Example: 100
    [System.Nullable[uint]] $OwnedPrivateRepos

    # The number of private gists.
    # Example: 81
    [System.Nullable[uint]] $PrivateGists

    # The disk usage in kilobytes.
    # Example: 10000
    [System.Nullable[uint]] $DiskUsage

    # The number of collaborators on private repositories.
    # Example: 8
    [System.Nullable[uint]] $Collaborators

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
        return $this.Login
    }
}
