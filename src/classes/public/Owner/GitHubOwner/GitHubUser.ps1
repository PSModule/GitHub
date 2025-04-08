class GitHubUser : GitHubOwner {
    # The user's biography.
    # Example: There once was...
    [string] $Bio

    # The notification email address of the user.
    # Example: octocat@github.com
    [string] $NotificationEmail

    # Whether the user is hireable.
    [System.Nullable[bool]] $Hireable

    # Whether two-factor authentication is enabled.
    # Example: true
    [System.Nullable[bool]]  $TwoFactorAuthentication

    # Simple parameterless constructor
    GitHubUser() {}

    # Creates an object from a hashtable of key-value pairs.
    GitHubUser([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubUser([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    [string] ToString() {
        return $this.Name
    }
}
