class GitHubOrganization : GitHubOwner {
    [string]$Description
    [bool]$IsVerified
    [int]$TotalPrivateRepos
    [int]$OwnedPrivateRepos
    [int]$DiskUsage
    [int]$Collaborators
    [string]$BillingEmail
    [string]$DefaultRepositoryPermission
    [bool]$MembersCanCreateRepositories
    [bool]$TwoFactorRequirementEnabled
    [string]$MembersAllowedRepositoryCreationType

    # Simple parameterless constructor
    GitHubOrganization() {}

    # Creates a object from a hashtable of key-vaule pairs.
    GitHubOrganization([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a object from a PSCustomObject.
    GitHubOrganization([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
