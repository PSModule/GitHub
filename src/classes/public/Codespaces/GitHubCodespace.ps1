class GitHubCodespace {
    # Unique identifier of the delivery.
    [uint64] $ID

    [string] $Name

    [Guid] $environment_id

    # Time when the delivery was delivered.
    [object] $Owner
    [object] $Billable_Owner
    [object] $Repository
    [object] $Machine
    [bool] $Prebuild
    [datetime] $created_at
    [Nullable[datetime]] $updated_at
    [Nullable[datetime]] $last_used_at
    [string]$State
    [string] $url
    [object] $git_status
    [string] $location
    [uint16] $idle_timeout_minutes
    [string] $web_url
    [string] $machines_url
    [string] $start_url
    [string] $stop_url
    [string] $pulls_url
    [string[]] $recent_folders
    [object] $runtime_constraints
    [string] $display_name
    [string] $devcontainer_path
    [bool] $pending_operation
    [UInt32] $retention_period_minutes
    [Nullable[datetime]] $retention_expires_at
    [string] $template
    [string] $publish_url

    # Simple parameterless constructor
    GitHubCodespace() {}

    # Creates a context object from a hashtable of key-vaule pairs.
    GitHubCodespace([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    GitHubCodespace([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
