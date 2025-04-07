class GitHubPlan {
    # The name of the plan.
    # Example: free, enterprise
    [string] $Name

    # The number of private repositories allowed.
    # Example: 20
    [System.Nullable[uint]] $PrivateRepos

    # The number of collaborators allowed.
    # Example: 3
    [System.Nullable[uint]] $Collaborators

    # The amount of space allocated in bytes.
    # Example: 976562499
    [System.Nullable[uint]] $Space

    # The total number of user seats included in the plan.
    # Example: 10
    [System.Nullable[uint]] $Seats

    # The number of seats currently filled.
    # Example: 7
    [System.Nullable[uint]] $FilledSeats

    # Simple parameterless constructor
    GitHubPlan() {}

    # Creates an object from a hashtable of key-value pairs.
    GitHubPlan([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubPlan([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    [string] ToString() {
        return $this.Name
    }
}
