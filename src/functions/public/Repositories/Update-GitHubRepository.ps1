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
            NewName     = 'Hello-World-Repository'
            Description = 'This is your first repository'
            Homepage    = 'https://github.com'
        }
        Update-GitHubRepository @params

        .INPUTS
        GitHubRepository

        .OUTPUTS
        GitHubRepository

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Update-GitHubRepository/

        .NOTES
        [Update a repository](https://docs.github.com/rest/repos/repos#update-a-repository)
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # The name of the repository.
        [Parameter()]
        [string] $NewName,

        # A short description of the repository.
        [Parameter()]
        [string] $Description,

        # A URL with more information about the repository.
        [Parameter()]
        [uri] $Homepage,

        # The visibility of the repository.
        [Parameter()]
        [ValidateSet('Public', 'Private', 'Internal')]
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
        [switch] $HasIssues,

        # Whether projects are enabled.
        [Parameter()]
        [switch] $HasProjects,

        # Whether the wiki is enabled.
        [Parameter()]
        [switch] $HasWiki,

        # Whether this repository acts as a template that can be used to generate new repositories.
        [Parameter()]
        [switch] $IsTemplate,

        # Updates the default branch for this repository.
        [Parameter()]
        [string] $DefaultBranch,

        # Whether to allow squash merges for pull requests.
        [Parameter()]
        [switch] $AllowSquashMerge,

        # Whether to allow merge commits for pull requests.
        [Parameter()]
        [switch] $AllowMergeCommit,

        # Whether to allow rebase merges for pull requests.
        [Parameter()]
        [switch] $AllowRebaseMerge,

        # Whether to allow Auto-merge to be used on pull requests.
        [Parameter()]
        [switch] $AllowAutoMerge,

        # Whether to delete head branches when pull requests are merged
        [Parameter()]
        [switch] $DeleteBranchOnMerge,

        # Either true to always allow a pull request head branch that is behind its base branch
        # to be updated even if it is not required to be up to date before merging, or false otherwise.
        [Parameter()]
        [switch] $SuggestUpdateBranch,

        # The default value for a squash merge commit title:
        # - PR_TITLE - default to the pull request's title.
        # - COMMIT_OR_PR_TITLE - default to the commit's title (if only one commit) or the pull request's title (when more than one commit).
        [Parameter()]
        [ValidateSet('PR_TITLE', 'COMMIT_OR_PR_TITLE')]
        [string] $SquashMergeCommitTitle,

        # The default value for a squash merge commit message:
        # - PR_BODY - default to the pull request's body.
        # - COMMIT_MESSAGES - default to the branch's commit messages.
        # - BLANK - default to a blank commit message.
        [Parameter()]
        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [string] $SquashMergeCommitMessage,

        # The default value for a merge commit title.
        # - PR_TITLE - default to the pull request's title.
        # - MERGE_MESSAGE - default to the classic title for a merge message (e.g.,Merge pull request #123 from branch-name).
        [Parameter()]
        [ValidateSet('PR_TITLE', 'MERGE_MESSAGE')]
        [string] $MergeCommitTitle,

        # The default value for a merge commit message.
        # - PR_BODY - default to the pull request's body.
        # - PR_TITLE - default to the pull request's title.
        # - BLANK - default to a blank commit message.
        [Parameter()]
        [ValidateSet('PR_BODY', 'PR_TITLE', 'BLANK')]
        [string] $MergeCommitMessage,

        # Whether to archive this repository. false will unarchive a previously archived repository.
        [Parameter()]
        [switch] $Archived,

        # Either true to allow private forks, or false to prevent private forks.
        [Parameter()]
        [switch] $AllowForking,

        # Either true to require contributors to sign off on web-based commits,
        # or false to not require contributors to sign off on web-based commits.
        [Parameter()]
        [switch] $WebCommitSignoffRequired,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Username
        }
        Write-Debug "Owner: [$Owner]"
    }

    process {
        $body = @{
            name                            = $NewName
            description                     = $Description
            homepage                        = $Homepage
            visibility                      = $Visibility.ToLower()
            default_branch                  = $DefaultBranch
            advanced_security               = $EnableAdvancedSecurity ? @{
                status = $EnableAdvancedSecurity ? 'enabled' : 'disabled'
            } : $null
            secret_scanning                 = $EnableSecretScanning ? @{
                status = $EnableSecretScanning ? 'enabled' : 'disabled'
            } : $null
            secret_scanning_push_protection = $EnableSecretScanningPushProtection ? @{
                status = $EnableSecretScanningPushProtection ? 'enabled' : 'disabled'
            } : $null
            has_issues                      = $HasIssues ? $HasIssues : $null
            has_projects                    = $HasProjects ? $HasProjects : $null
            has_wiki                        = $HasWiki ? $HasWiki : $null
            is_template                     = $IsTemplate ? $IsTemplate : $null
            allow_squash_merge              = $AllowSquashMerge ? $AllowSquashMerge : $null
            squash_merge_commit_title       = $SquashMergeCommitTitle
            squash_merge_commit_message     = $SquashMergeCommitMessage
            allow_merge_commit              = $AllowMergeCommit ? $AllowMergeCommit : $null
            merge_commit_title              = $MergeCommitTitle
            merge_commit_message            = $MergeCommitMessage
            allow_rebase_merge              = $AllowRebaseMerge ? $AllowRebaseMerge : $null
            allow_auto_merge                = $AllowAutoMerge ? $AllowAutoMerge : $null
            allow_update_branch             = $SuggestUpdateBranch ? $SuggestUpdateBranch : $null
            delete_branch_on_merge          = $DeleteBranchOnMerge ? $DeleteBranchOnMerge : $null
            archived                        = $Archived ? $Archived : $null
            allow_forking                   = $AllowForking ? $AllowForking : $null
            web_commit_signoff_required     = $WebCommitSignoffRequired ? $WebCommitSignoffRequired : $null
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = "/repos/$Owner/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Repository [$Owner/$Name]", 'Update')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
