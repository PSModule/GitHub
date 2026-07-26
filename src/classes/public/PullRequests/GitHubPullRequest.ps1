class GitHubPullRequest : GitHubNode {
    # The pull request number
    [int] $Number

    # The repository where the pull request is
    [string] $Repository

    # The owner of the repository
    [string] $Owner

    # The title of the pull request
    [string] $Title

    # The body/description of the pull request
    [string] $Body

    # The state of the pull request (open, closed)
    [string] $State

    # Whether the pull request is a draft
    [bool] $IsDraft

    # Whether the pull request is locked
    [bool] $IsLocked

    # Whether the pull request has been merged
    [bool] $IsMerged

    # The user who created the pull request
    [GitHubUser] $Author

    # The head branch (source branch)
    [string] $HeadRef

    # The head repository owner
    [string] $HeadOwner

    # The head repository name
    [string] $HeadRepository

    # The head SHA
    [string] $HeadSHA

    # The base branch (target branch)
    [string] $BaseRef

    # The base repository owner
    [string] $BaseOwner

    # The base repository name
    [string] $BaseRepository

    # The base SHA
    [string] $BaseSHA

    # Pull request URL
    [string] $Url

    # Timestamp when the pull request was created
    [System.Nullable[datetime]] $CreatedAt

    # Timestamp when the pull request was updated
    [System.Nullable[datetime]] $UpdatedAt

    # Timestamp when the pull request was closed
    [System.Nullable[datetime]] $ClosedAt

    # Timestamp when the pull request was merged
    [System.Nullable[datetime]] $MergedAt

    # User who merged the pull request
    [GitHubUser] $MergedBy

    # Number of commits in the pull request
    [int] $Commits

    # Number of additions in the pull request
    [int] $Additions

    # Number of deletions in the pull request
    [int] $Deletions

    # Number of changed files in the pull request
    [int] $ChangedFiles

    GitHubPullRequest() {}

    GitHubPullRequest([PSCustomObject] $Object, [string] $Owner, [string] $Repository) {
        if ($null -ne $Object.node_id) {
            # REST API response mapping
            $this.ID = $Object.id
            $this.NodeID = $Object.node_id
            $this.Number = $Object.number
            $this.Title = $Object.title
            $this.Body = $Object.body
            $this.State = $Object.state
            $this.IsDraft = $Object.draft
            $this.IsLocked = $Object.locked
            $this.IsMerged = $Object.merged
            $this.Url = $Object.html_url
            $this.Owner = $Owner
            $this.Repository = $Repository
            $this.Author = [GitHubUser]::new($Object.user)
            $this.HeadRef = $Object.head.ref
            $this.HeadOwner = if ($Object.head.repo) { $Object.head.repo.owner.login } else { $null }
            $this.HeadRepository = if ($Object.head.repo) { $Object.head.repo.name } else { $null }
            $this.HeadSHA = $Object.head.sha
            $this.BaseRef = $Object.base.ref
            $this.BaseOwner = if ($Object.base.repo) { $Object.base.repo.owner.login } else { $null }
            $this.BaseRepository = if ($Object.base.repo) { $Object.base.repo.name } else { $null }
            $this.BaseSHA = $Object.base.sha
            $this.CreatedAt = $Object.created_at
            $this.UpdatedAt = $Object.updated_at
            $this.ClosedAt = $Object.closed_at
            $this.MergedAt = $Object.merged_at
            $this.MergedBy = if ($Object.merged_by) { [GitHubUser]::new($Object.merged_by) } else { $null }
            $this.Commits = $Object.commits
            $this.Additions = $Object.additions
            $this.Deletions = $Object.deletions
            $this.ChangedFiles = $Object.changed_files
        } else {
            # GraphQL response mapping
            $this.ID = $Object.databaseId
            $this.NodeID = $Object.id
            $this.Number = $Object.number
            $this.Title = $Object.title
            $this.Body = $Object.body
            $this.State = $Object.state
            $this.IsDraft = $Object.isDraft
            $this.IsLocked = $Object.locked
            $this.IsMerged = $Object.merged
            $this.Url = $Object.url
            $this.Owner = $Owner
            $this.Repository = $Repository
            $this.Author = [GitHubUser]::new($Object.author)
            $this.HeadRef = $Object.headRefName
            $this.HeadSHA = $Object.headRefOid
            $this.BaseRef = $Object.baseRefName
            $this.BaseSHA = $Object.baseRefOid
            $this.CreatedAt = $Object.createdAt
            $this.UpdatedAt = $Object.updatedAt
            $this.ClosedAt = $Object.closedAt
            $this.MergedAt = $Object.mergedAt
            $this.MergedBy = if ($Object.mergedBy) { [GitHubUser]::new($Object.mergedBy) } else { $null }
        }
    }
}
