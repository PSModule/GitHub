class GitHubRepository : GitHubNode {
    # The name of the repository.
    # Example: Team Environment
    [string] $Name

    # The full name of the repository.
    # Example: octocat/Hello-World
    [string] $FullName

    # License information for the repository.
    # Example: null
    [object] $License

    # Number of forks.
    # Example: 0
    [int] $Forks

    # Permissions for the repository.
    # Example: @{ admin = $true; pull = $true; push = $true }
    [object] $Permissions

    # The owner of the repository (flattened from owner object).
    # Example: octocat
    [string] $Owner

    # Indicates whether the repository is private.
    # Example: false
    [bool] $Private

    # The HTML URL of the repository.
    # Example: https://github.com/octocat/Hello-World
    [string] $Url

    # The description of the repository.
    # Example: This your first repo!
    [string] $Description

    # Indicates whether the repository is a fork.
    # Example: false
    [bool] $Fork

    # The homepage URL.
    # Example: https://github.com
    [string] $Homepage

    # The primary language of the repository.
    # Example: null
    [string] $Language

    # The number of forks.
    # Example: 9
    [int] $ForksCount

    # The number of stargazers.
    # Example: 80
    [int] $StargazersCount

    # The number of watchers.
    # Example: 80
    [int] $WatchersCount

    # The size of the repository in kilobytes.
    # Example: 108
    [int] $Size

    # The default branch of the repository.
    # Example: master
    [string] $DefaultBranch

    # The number of open issues.
    # Example: 0
    [int] $OpenIssuesCount

    # Indicates whether the repository acts as a template.
    # Example: true
    [bool] $IsTemplate

    # The topics associated with the repository.
    # Example: @()
    [string[]] $Topics

    # Whether issues are enabled.
    # Example: true
    [bool] $HasIssues

    # Whether projects are enabled.
    # Example: true
    [bool] $HasProjects

    # Whether the wiki is enabled.
    # Example: true
    [bool] $HasWiki

    # Whether pages are enabled.
    # Example: false
    [bool] $HasPages

    # Whether downloads are enabled.
    # Example: true
    # Deprecated: This property is deprecated.
    [bool] $HasDownloads

    # Whether discussions are enabled.
    # Example: true
    [bool] $HasDiscussions

    # Indicates whether the repository is archived.
    # Example: false
    [bool] $Archived

    # Indicates whether the repository is disabled.
    # Example: false
    [bool] $Disabled

    # The visibility of the repository (public, private, or internal).
    # Example: public
    [string] $Visibility

    # The date and time of the last push.
    # Example: 2011-01-26T19:06:43Z
    [System.Nullable[datetime]] $PushedAt

    # The date and time the repository was created.
    # Example: 2011-01-26T19:01:12Z
    [System.Nullable[datetime]] $CreatedAt

    # The date and time the repository was last updated.
    # Example: 2011-01-26T19:14:43Z
    [System.Nullable[datetime]] $UpdatedAt

    # Whether to allow rebase merges for pull requests.
    # Example: true
    [bool] $AllowRebaseMerge

    # Temporary clone token.
    # Example: null
    [string] $TempCloneToken

    # Whether to allow squash merges for pull requests.
    # Example: true
    [bool] $AllowSquashMerge

    # Whether to allow auto-merge on pull requests.
    # Example: false
    [bool] $AllowAutoMerge

    # Whether to delete head branches when pull requests are merged.
    # Example: false
    [bool] $DeleteBranchOnMerge

    # Whether a pull request head branch can be updated even if behind its base branch.
    # Example: false
    [bool] $AllowUpdateBranch

    # Whether a squash merge commit can use the pull request title as default.
    # Deprecated: Please use SquashMergeCommitTitle instead.
    # Example: false
    [bool] $UseSquashPrTitleAsDefault

    # The default value for a squash merge commit title.
    # Enum: PR_TITLE, COMMIT_OR_PR_TITLE
    # Example: PR_TITLE
    [string] $SquashMergeCommitTitle

    # The default value for a squash merge commit message.
    # Enum: PR_BODY, COMMIT_MESSAGES, BLANK
    # Example: PR_BODY
    [string] $SquashMergeCommitMessage

    # The default value for a merge commit title.
    # Enum: PR_TITLE, MERGE_MESSAGE
    # Example: PR_TITLE
    [string] $MergeCommitTitle

    # The default value for a merge commit message.
    # Enum: PR_BODY, PR_TITLE, BLANK
    # Example: PR_TITLE
    [string] $MergeCommitMessage

    # Whether to allow merge commits for pull requests.
    # Example: true
    [bool] $AllowMergeCommit

    # Whether to allow forking this repository.
    # Example: true
    [bool] $AllowForking

    # Whether to require contributors to sign off on web-based commits.
    # Example: false
    [bool] $WebCommitSignoffRequired

    # The number of open issues.
    # Example: 0
    [int] $OpenIssues

    # The number of watchers.
    # Example: 0
    [int] $Watchers

    # The name of the master branch.
    # Example: master
    [string] $MasterBranch

    # The date and time when the repository was starred.
    # Example: 2020-07-09T00:17:42Z
    [string] $StarredAt

    # Indicates whether anonymous git access is enabled.
    # Example: false
    [bool] $AnonymousAccessEnabled

    # Simple parameterless constructor
    GitHubRepository() {}

    # Creates an object from a hashtable of key-value pairs.
    GitHubRepository([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubRepository([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    [string] ToString() {
        return $this.Name
    }
}
