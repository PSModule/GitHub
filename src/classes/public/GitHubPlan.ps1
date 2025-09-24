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

    GitHubPlan() {}

    GitHubPlan([PSCustomObject]$Object) {
        $this.Name = $Object.name
        $this.PrivateRepos = $Object.private_repos ?? $Object.PrivateRepos
        $this.Collaborators = $Object.collaborators
        $this.Space = $Object.space
        $this.Seats = $Object.seats
        $this.FilledSeats = $Object.filled_seats ?? $Object.FilledSeats
    }

    [string] ToString() {
        return $this.Name
    }
}
