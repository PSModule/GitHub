Class GitHubRateLimitResource {
    # The name of the resource.
    [string] $Name

    # The limit for the resource.
    [UInt64] $Limit

    # The number of requests used for the resource.
    [UInt64] $Used

    # The number of requests remaining for the resource.
    [UInt64] $Remaining

    # The time when the rate limit will reset.
    [DateTime] $Reset

    # Simple parameterless constructor
    GitHubRateLimitResource() {}

    # Constructor that initializes the class from a hashtable
    GitHubRateLimitResource([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Constructor that initializes the class from a PSCustomObject
    GitHubRateLimitResource([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
