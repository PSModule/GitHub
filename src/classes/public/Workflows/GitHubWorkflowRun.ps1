class GitHubWorkflowRun : GitHubNode {
    # The name of the workflow run.
    # Example: "Build"
    [string] $Name

    # The name of the organization or user the variable is associated with.
    # Example: "octocat"
    [string] $Owner

    # The name of the repository the variable is associated with.
    # Example: "hello-world"
    [string] $Repository

    # The ID of the associated check suite.
    # Example: 42
    [System.Nullable[UInt64]] $CheckSuiteID

    # The node ID of the associated check suite.
    # Example: "MDEwOkNoZWNrU3VpdGU0Mg=="
    [string] $CheckSuiteNodeID

    # The branch name of the head commit.
    # Example: "master"
    [string] $HeadBranch

    # The SHA of the head commit that points to the version of the workflow being run.
    # Example: "009b8a3a9ccbb128af87f9b1c0f4c62e8a304f6d"
    [string] $HeadSha

    # The full path of the workflow.
    # Example: "octocat/octo-repo/.github/workflows/ci.yml@main"
    [string] $Path

    # The auto incrementing run number for the workflow run.
    # Example: 106
    [UInt64] $RunNumber

    # Attempt number of the run, 1 for first attempt and higher if the workflow was re-run.
    # Example: 1
    [System.Nullable[int]] $RunAttempt

    # Array of referenced workflows.
    # Example: (array of objects, nullable)
    [PSCustomObject[]] $ReferencedWorkflows

    # The event that triggered the workflow run.
    # Example: "push"
    [string] $Event

    # The current status of the workflow run.
    # Example: "completed"
    [string] $Status

    # The conclusion of the workflow run.
    # Example: "neutral"
    [string] $Conclusion

    # The ID of the parent workflow.
    # Example: 5
    [UInt64] $WorkflowID

    # The URL to the workflow run API endpoint.
    # Example: "https://api.github.com/repos/github/hello-world/actions/runs/5"
    [string] $Url

    # The HTML URL to view the workflow run.
    # Example: "https://github.com/github/hello-world/suites/4"
    [string] $HtmlUrl

    # Pull requests associated with the workflow run.
    # Example: (array of pull request objects, nullable)
    [PSCustomObject[]] $PullRequests

    # The creation timestamp of the workflow run.
    # Example: "2023-01-01T12:00:00Z"
    [string] $CreatedAt

    # The last updated timestamp of the workflow run.
    # Example: "2023-01-01T12:05:00Z"
    [string] $UpdatedAt

    # The user who triggered the workflow run.
    # Example: (simple-user object)
    [PSCustomObject] $Actor

    # The user who actually triggered the workflow run (may differ from Actor).
    # Example: (simple-user object)
    [PSCustomObject] $TriggeringActor

    # The start time of the latest run. Resets on re-run.
    # Example: "2023-01-01T12:01:00Z"
    [string] $RunStartedAt

    # The URL to the jobs for the workflow run.
    # Example: "https://api.github.com/repos/github/hello-world/actions/runs/5/jobs"
    [string] $JobsUrl

    # The URL to download the logs for the workflow run.
    # Example: "https://api.github.com/repos/github/hello-world/actions/runs/5/logs"
    [string] $LogsUrl

    # The URL to the associated check suite.
    # Example: "https://api.github.com/repos/github/hello-world/check-suites/12"
    [string] $CheckSuiteUrl

    # The URL to the artifacts for the workflow run.
    # Example: "https://api.github.com/repos/github/hello-world/actions/runs/5/rerun/artifacts"
    [string] $ArtifactsUrl

    # The URL to cancel the workflow run.
    # Example: "https://api.github.com/repos/github/hello-world/actions/runs/5/cancel"
    [string] $CancelUrl

    # The URL to rerun the workflow run.
    # Example: "https://api.github.com/repos/github/hello-world/actions/runs/5/rerun"
    [string] $RerunUrl

    # The URL to the previous attempted run of this workflow, if one exists.
    # Example: "https://api.github.com/repos/github/hello-world/actions/runs/5/attempts/3"
    [string] $PreviousAttemptUrl

    # The URL to the workflow definition.
    # Example: "https://api.github.com/repos/github/hello-world/actions/workflows/main.yaml"
    [string] $WorkflowUrl

    # The head commit details.
    # Example: (nullable-simple-commit object)
    [PSCustomObject] $HeadCommit

    # The head repository of the workflow run.
    # Example: (minimal-repository object)
    [PSCustomObject] $HeadRepository

    # The event-specific title associated with the run or the run-name if set.
    # Example: "Simple Workflow"
    [string] $DisplayTitle


    # Simple parameterless constructor.
    GitHubWorkflowRun() {
    }

    # Creates an object from a hashtable of key-value pairs.
    GitHubWorkflowRun([hashtable] $Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubWorkflowRun([PSCustomObject] $Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
