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

    # The head commit details.
    # Example: (nullable-simple-commit object)
    [PSCustomObject] $HeadCommit

    # The head repository of the workflow run.
    # Example: (minimal-repository object)
    [PSCustomObject] $HeadRepository

    # The event-specific title associated with the run or the run-name if set.
    # Example: "Simple Workflow"
    [string] $DisplayTitle

    GitHubWorkflowRun() {}

    GitHubWorkflowRun([PSCustomObject] $Object) {
        $this.ID = $_.id
        $this.Name = $_.name
        $this.Owner = [GitHubOwner]::new($Object.repository.owner)
        $this.Repository = [GitHubRepository]::new($Object.repository)
        $this.NodeID = $_.node_id
        $this.CheckSuiteID = $_.check_suite_id
        $this.CheckSuiteNodeID = $_.check_suite_node_id
        $this.HeadBranch = $_.head_branch
        $this.HeadSha = $_.head_sha
        $this.Path = $_.path
        $this.RunNumber = $_.run_number
        $this.RunAttempt = $_.run_attempt
        $this.ReferencedWorkflows = $_.referenced_workflows
        $this.Event = $_.event
        $this.Status = $_.status
        $this.Conclusion = $_.conclusion
        $this.WorkflowID = $_.workflow_id
        $this.Url = $_.html_url
        $this.PullRequests = $_.pull_requests
        $this.CreatedAt = $_.created_at
        $this.UpdatedAt = $_.updated_at
        $this.RunStartedAt = $_.run_started_at
        $this.Actor = [GitHubUser]::new($_.actor)
        $this.TriggeringActor = [GitHubUser]::new($_.triggering_actor)
        $this.HeadCommit = $_.head_commit
        $this.HeadRepository = [GitHubRepository]::new($_.head_repository)
        $this.DisplayTitle = $_.display_title
    }
}
