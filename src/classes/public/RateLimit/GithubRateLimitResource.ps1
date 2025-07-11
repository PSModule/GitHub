class GitHubRateLimitResource {
    # The name of the resource.
    [string] $Name

    # The limit for the resource.
    [UInt64] $Limit

    # The number of requests used for the resource.
    [UInt64] $Used

    # The number of requests remaining for the resource.
    [UInt64] $Remaining

    # The time when the rate limit will reset.
    [DateTime] $ResetsAt

    # Simple parameterless constructor
    GitHubRateLimitResource() {}

    # Constructor that initializes the class from a PSCustomObject
    GitHubRateLimitResource([pscustomobject]$Object) {
        $this.Name = $Object.name
        $this.Limit = $Object.limit
        $this.Used = $Object.used
        $this.Remaining = $Object.remaining
        $this.ResetsAt = [DateTime]::UnixEpoch.AddSeconds($Object.reset).ToLocalTime()
    }
}
