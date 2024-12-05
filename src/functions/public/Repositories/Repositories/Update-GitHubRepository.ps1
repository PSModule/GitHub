filter Update-GitHubRepository {
    <#
        .SYNOPSIS
        Update a repository

        .DESCRIPTION
        **Note**: To edit a repository's topics, use the
        [Replace all repository topics](https://docs.github.com/rest/repos/repos#replace-all-repository-topics) endpoint.

        .EXAMPLE
        Update-GitHubRepository -Name 'octocat' -Description 'Hello-World' -Homepage 'https://github.com'

        .EXAMPLE
        $params = @{
            Owner       = 'octocat'
            Repo        = 'Hello-World'
            name        = 'Hello-World-Repo
            description = 'This is your first repository'
            homepage    = 'https://github.com'
        }
        Update-GitHubRepository @params

        .NOTES
        [Update a repository](https://docs.github.com/rest/repos/repos#update-a-repository)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo,

        # The name of the repository.
        [Parameter()]
        [string] $Name,

        # A short description of the repository.
        [Parameter()]
        [string] $Description,

        # A URL with more information about the repository.
        [Parameter()]
        [uri] $Homepage,

        # The visibility of the repository.
        [Parameter()]
        [ValidateSet('public', 'private')]
        [string] $Visibility,

        # Use the status property to enable or disable GitHub Advanced Security for this repository.
        # For more information, see "About GitHub Advanced Security."
        [Parameter()]
        [switch] $EnableAdvancedSecurity,

        # Use the status property to enable or disable secret scanning for this repository.
        # For more information, see "About secret scanning."
        [Parameter()]
        [switch] $EnableSecretScanning,

        # Use the status property to enable or disable secret scanning push protection for this repository.
        # For more information, see "Protecting pushes with secret scanning."
        [Parameter()]
        [switch] $EnableSecretScanningPushProtection,

        # Whether issues are enabled.
        [Parameter()]
        [Alias('has_issues')]
        [switch] $HasIssues,

        # Whether projects are enabled.
        [Parameter()]
        [Alias('has_projects')]
        [switch] $HasProjects,

        # Whether the wiki is enabled.
        [Parameter()]
        [Alias('has_wiki')]
        [switch] $HasWiki,

        # Whether this repository acts as a template that can be used to generate new repositories.
        [Parameter()]
        [Alias('is_template')]
        [switch] $IsTemplate,

        # Updates the default branch for this repository.
        [Parameter()]
        [Alias('default_branch')]
        [string] $DefaultBranch,

        # Whether to allow squash merges for pull requests.
        [Parameter()]
        [Alias('allow_squash_merge')]
        [switch] $AllowSquashMerge,

        # Whether to allow merge commits for pull requests.
        [Parameter()]
        [Alias('allow_merge_commit')]
        [switch] $AllowMergeCommit,

        # Whether to allow rebase merges for pull requests.
        [Parameter()]
        [Alias('allow_rebase_merge')]
        [switch] $AllowRebaseMerge,

        # Whether to allow Auto-merge to be used on pull requests.
        [Parameter()]
        [Alias('allow_auto_merge')]
        [switch] $AllowAutoMerge,

        # Whether to delete head branches when pull requests are merged
        [Parameter()]
        [Alias('delete_branch_on_merge')]
        [switch] $DeleteBranchOnMerge,

        # Either true to always allow a pull request head branch that is behind its base branch
        # to be updated even if it is not required to be up to date before merging, or false otherwise.
        [Parameter()]
        [Alias('allow_update_branch')]
        [switch] $AllowUpdateMerge,

        # The default value for a squash merge commit title:
        # - PR_TITLE - default to the pull request's title.
        # - COMMIT_OR_PR_TITLE - default to the commit's title (if only one commit) or the pull request's title (when more than one commit).
        [Parameter()]
        [ValidateSet('PR_TITLE', 'COMMIT_OR_PR_TITLE')]
        [Alias('squash_merge_commit_title')]
        [string] $SquashMergeCommitTitle,

        # The default value for a squash merge commit message:
        # - PR_BODY - default to the pull request's body.
        # - COMMIT_MESSAGES - default to the branch's commit messages.
        # - BLANK - default to a blank commit message.
        [Parameter()]
        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [Alias('squash_merge_commit_message')]
        [string] $SquashMergeCommitMessage,

        # The default value for a merge commit title.
        # - PR_TITLE - default to the pull request's title.
        # - MERGE_MESSAGE - default to the classic title for a merge message (e.g.,Merge pull request #123 from branch-name).
        [Parameter()]
        [ValidateSet('PR_TITLE', 'MERGE_MESSAGE')]
        [Alias('merge_commit_title')]
        [string] $MergeCommitTitle,

        # The default value for a merge commit message.
        # - PR_BODY - default to the pull request's body.
        # - PR_TITLE - default to the pull request's title.
        # - BLANK - default to a blank commit message.
        [Parameter()]
        [ValidateSet('PR_BODY', 'PR_TITLE', 'BLANK')]
        [Alias('merge_commit_message')]
        [string] $MergeCommitMessage,

        # Whether to archive this repository. false will unarchive a previously archived repository.
        [Parameter()]
        [switch] $Archived,

        # Either true to allow private forks, or false to prevent private forks.
        [Parameter()]
        [Alias('allow_forking')]
        [switch] $AllowForking,

        # Either true to require contributors to sign off on web-based commits,
        # or false to not require contributors to sign off on web-based commits.
        [Parameter()]
        [Alias('web_commit_signoff_required')]
        [switch] $WebCommitSignoffRequired,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    if ([string]::IsNullOrEmpty($Owner)) {
        $Owner = $Context.Owner
    }
    Write-Debug "Owner : [$($Context.Owner)]"

    if ([string]::IsNullOrEmpty($Repo)) {
        $Repo = $Context.Repo
    }
    Write-Debug "Repo : [$($Context.Repo)]"

    $body = @{
        name                            = $Name
        description                     = $Description
        homepage                        = $Homepage
        visibility                      = $Visibility
        private                         = $Visibility -eq 'private'
        default_branch                  = $DefaultBranch
        squash_merge_commit_title       = $SquashMergeCommitTitle
        squash_merge_commit_message     = $SquashMergeCommitMessage
        merge_commit_title              = $MergeCommitTitle
        merge_commit_message            = $MergeCommitMessage

        advanced_security               = if ($EnableAdvancedSecurity.IsPresent) {
            @{
                status = if ($EnableAdvancedSecurity) { 'enabled' } else { 'disabled' }
            }
        } else { $null }
        secret_scanning                 = if ($EnableSecretScanning.IsPresent) {
            @{
                status = if ($EnableSecretScanning) { 'enabled' } else { 'disabled' }
            }
        } else { $null }
        secret_scanning_push_protection = if ($EnableSecretScanningPushProtection.IsPresent) {
            @{
                status = if ($EnableSecretScanningPushProtection) { 'enabled' } else { 'disabled' }
            }
        } else { $null }
        has_issues                      = if ($HasIssues.IsPresent) { $HasIssues } else { $null }
        has_projects                    = if ($HasProjects.IsPresent) { $HasProjects } else { $null }
        has_wiki                        = if ($HasWiki.IsPresent) { $HasWiki } else { $null }
        is_template                     = if ($IsTemplate.IsPresent) { $IsTemplate } else { $null }
        allow_squash_merge              = if ($AllowSquashMerge.IsPresent) { $AllowSquashMerge } else { $null }
        allow_merge_commit              = if ($AllowMergeCommit.IsPresent) { $AllowMergeCommit } else { $null }
        allow_rebase_merge              = if ($AllowRebaseMerge.IsPresent) { $AllowRebaseMerge } else { $null }
        allow_auto_merge                = if ($AllowAutoMerge.IsPresent) { $AllowAutoMerge } else { $null }
        allow_update_branch             = if ($AllowUpdateMerge.IsPresent) { $AllowUpdateMerge } else { $null }
        delete_branch_on_merge          = if ($DeleteBranchOnMerge.IsPresent) { $DeleteBranchOnMerge } else { $null }
        archived                        = if ($Archived.IsPresent) { $Archived } else { $null }
        allow_forking                   = if ($AllowForking.IsPresent) { $AllowForking } else { $null }
        web_commit_signoff_required     = if ($WebCommitSignoffRequired.IsPresent) { $WebCommitSignoffRequired } else { $null }
    }

    Remove-HashtableEntry -Hashtable $body -NullOrEmptyValues

    $inputObject = @{
        Context     = $Context
        APIEndpoint = "/repos/$Owner/$Repo"
        Method      = 'PATCH'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("Repository [$Owner/$Repo]", 'Update')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
