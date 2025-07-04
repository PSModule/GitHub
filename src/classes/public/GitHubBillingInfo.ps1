class GitHubBillingInfo {
    [int]$AllLicensableUsersCount
    [int]$AssetPacks
    [int]$BandwidthQuota
    [int]$BandwidthUsage
    [int]$BandwidthUsagePercentage
    [int]$StorageQuota
    [int]$StorageUsage
    [int]$StorageUsagePercentage
    [int]$TotalAvailableLicenses
    [int]$TotalLicenses

    GitHubBillingInfo() {}

    GitHubBillingInfo([PSCustomObject] $Object) {
        $this.AllLicensableUsersCount = $Object.allLicensableUsersCount
        $this.AssetPacks = $Object.assetPacks
        $this.BandwidthQuota = $Object.bandwidthQuota
        $this.BandwidthUsage = $Object.bandwidthUsage
        $this.BandwidthUsagePercentage = $Object.bandwidthUsagePercentage
        $this.StorageQuota = $Object.storageQuota
        $this.StorageUsage = $Object.storageUsage
        $this.StorageUsagePercentage = $Object.storageUsagePercentage
        $this.TotalAvailableLicenses = $Object.totalAvailableLicenses
        $this.TotalLicenses = $Object.totalLicenses
    }
}
