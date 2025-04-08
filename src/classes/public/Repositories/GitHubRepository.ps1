class GitHubRepository : GitHubNode {
    # The name of the repository.
    # Example: Team Environment
    [string] $Name

    # The owner of the repository.
    # Example: octocat
    [GitHubOwner] $Owner

    # The HTML URL of the repository.
    # Example: https://github.com/octocat/Hello-World
    [string] $Url

    # The description of the repository.
    # Example: This your first repo!
    [string] $Description

    # The date and time the repository was created.
    # Example: 2011-01-26T19:01:12Z
    [System.Nullable[datetime]] $CreatedAt

    # The date and time the repository was last updated.
    # Example: 2011-01-26T19:14:43Z
    [System.Nullable[datetime]] $UpdatedAt

    # The date and time of the last push.
    # Example: 2011-01-26T19:06:43Z
    [System.Nullable[datetime]] $PushedAt

    # The homepage URL.
    # Example: https://github.com
    [string] $Homepage

    # The size of the repository, in kilobytes.
    # Example: 108
    [System.Nullable[uint]] $Size

    # The primary language of the repository.
    # Example: null
    [string] $Language

    # Whether issues are enabled.
    # Example: true
    [System.Nullable[bool]] $HasIssues

    # Whether projects are enabled.
    # Example: true
    [System.Nullable[bool]] $HasProjects

    # Whether the wiki is enabled.
    # Example: true
    [System.Nullable[bool]] $HasWiki

    # Whether pages are enabled.
    # Example: false
    [System.Nullable[bool]] $HasPages

    # Whether discussions are enabled.
    # Example: true
    [System.Nullable[bool]] $HasDiscussions

    # Indicates whether the repository is archived.
    # Example: false
    [System.Nullable[bool]] $IsArchived

    # Indicates whether the repository is disabled.
    # Example: false
    [System.Nullable[bool]] $IsDisabled

    # Indicates whether the repository acts as a template.
    # Example: true
    [System.Nullable[bool]] $IsTemplate

    # Indicates whether the repository is a fork.
    # Example: false
    [System.Nullable[bool]] $IsFork

    # License information for the repository.
    # Example: 'MIT License', 'Mozilla Public License 2.0'
    [string] $License

    # Whether to allow forking this repository.
    # Example: true
    [System.Nullable[bool]] $AllowForking

    # Whether to require contributors to sign off on web-based commits
    # Example: false
    [System.Nullable[bool]] $RequireWebCommitSignoff

    # The topics associated with the repository.
    # Example: @()
    [string[]] $Topics

    # The visibility of the repository (public, private, or internal).
    # Example: public
    [string] $Visibility

    # The number of open issues.
    # Example: 15
    [System.Nullable[uint]] $OpenIssues

    # The number of stargazers.
    # Example: 80
    [System.Nullable[uint]] $Stargazers

    # The number of watchers.
    # Example: 80
    [System.Nullable[uint]] $Watchers

    # The number of forks.
    # Example: 9
    [System.Nullable[uint]] $Forks

    # The default branch of the repository.
    # Example: main
    [string] $DefaultBranch

    # Permissions for the repository.
    # Example: @{ Admin = $true; Pull = $true; Push = $true }
    [GitHubRepositoryPermissions] $Permissions

    # Whether to allow squash merges for pull requests.
    # Example: true
    [System.Nullable[bool]] $AllowSquashMerge

    # Whether to allow merge commits for pull requests.
    # Example: true
    [System.Nullable[bool]] $AllowMergeCommit

    # Whether to allow rebase merges for pull requests.
    # Example: true
    [System.Nullable[bool]] $AllowRebaseMerge

    # Whether to allow auto-merge on pull requests.
    # Example: false
    [System.Nullable[bool]] $AllowAutoMerge

    # Whether to delete head branches when pull requests are merged.
    # Example: false
    [System.Nullable[bool]] $DeleteBranchOnMerge

    # Whether a pull request head branch can be updated even if behind its base branch.
    # Example: false
    [System.Nullable[bool]] $AllowUpdateBranch

    # The default value for a squash merge commit message.
    # Enum: PR_BODY, COMMIT_MESSAGES, BLANK
    # Example: PR_BODY
    [string] $SquashMergeCommitMessage

    # The default value for a squash merge commit title.
    # Enum: PR_TITLE, COMMIT_OR_PR_TITLE
    # Example: PR_TITLE
    [string] $SquashMergeCommitTitle

    # The default value for a merge commit message.
    # Enum: PR_BODY, PR_TITLE, BLANK
    # Example: PR_TITLE
    [string] $MergeCommitMessage

    # The default value for a merge commit title.
    # Enum: PR_TITLE, MERGE_MESSAGE
    # Example: PR_TITLE
    [string] $MergeCommitTitle

    # The template repository that this repository was created from
    [GithubRepository] $TemplateRepository

    # The repository this repository was forked from.
    [GithubRepository] $ForkParent

    # The ultimate source for the fork network.
    [GithubRepository] $ForkSource

    # Custom properties for the repository.
    [PSCustomObject] $CustomProperties

    GitHubRepository() {}

    GitHubRepository([PSCustomObject]$Object) {
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id
        $this.Name = $Object.name
        $this.Owner = [GitHubOwner]::New($Object.owner)
        $this.Visibility = $Object.visibility
        $this.Description = $Object.description
        $this.Homepage = $Object.homepage
        $this.Url = $Object.html_url
        $this.Size = $Object.size
        $this.Language = $Object.language
        $this.License = [GitHubLicense]::New($Object.license)
        $this.IsFork = $Object.fork
        $this.IsArchived = $Object.archived
        $this.IsDisabled = $Object.disabled
        $this.IsTemplate = $Object.is_template
        $this.AllowForking = $Object.allow_forking
        $this.HasIssues = $Object.has_issues
        $this.HasProjects = $Object.has_projects
        $this.HasWiki = $Object.has_wiki
        $this.HasDiscussions = $Object.has_discussions
        $this.HasPages = $Object.has_pages
        $this.RequireWebCommitSignoff = $Object.web_commit_signoff_required
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.created_at
        $this.PushedAt = $Object.pushed_at
        $this.Topics = $Object.topics
        $this.Forks = $Object.forks_count
        $this.OpenIssues = $Object.open_issues_count
        $this.Watchers = $Object.watchers_count
        $this.Stargazers = $Object.stargazers_count
        $this.DefaultBranch = $Object.default_branch
        $this.Permissions = [GitHubRepositoryPermissions]::New($Object.permissions)
        $this.AllowSquashMerge = $Object.allow_squash_merge
        $this.AllowMergeCommit = $Object.allow_merge_commit
        $this.AllowRebaseMerge = $Object.allow_rebase_merge
        $this.AllowAutoMerge = $Object.allow_auto_merge
        $this.DeleteBranchOnMerge = $Object.delete_branch_on_merge
        $this.AllowUpdateBranch = $Object.allow_update_branch
        $this.SquashMergeCommitMessage = $Object.squash_merge_commit_message
        $this.SquashMergeCommitTitle = $Object.squash_merge_commit_title
        $this.MergeCommitMessage = $Object.merge_commit_message
        $this.MergeCommitTitle = $Object.merge_commit_title
        $this.CustomProperties = $Object.custom_properties
        $this.ForkParent = $null -ne $Object.parent ? [GitHubRepository]::New($Object.parent) : $null
        $this.ForkSource = $null -ne $Object.source ? [GitHubRepository]::New($Object.source) : $null
        $this.TemplateRepository = $null -ne $Object.template_repository ? [GitHubRepository]::New($Object.template_repository) : $null
    }

    [string] ToString() {
        return $this.Name
    }
}
