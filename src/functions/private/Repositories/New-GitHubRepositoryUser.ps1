filter New-GitHubRepositoryUser {
    <#
        .SYNOPSIS
        Create a repository for the authenticated user

        .DESCRIPTION
        Creates a new repository for the authenticated user.

        **OAuth scope requirements**

        When using [OAuth](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:

        * `public_repo` scope or `repo` scope to create a public repository. Note: For GitHub AE, use `repo` scope to create an internal repository.
        * `repo` scope to create a private repository.

        .EXAMPLE
        $params = @{
            Name                     = 'Hello-World'
            Description              = 'This is your first repository'
            Homepage                 = 'https://github.com'
            HasIssues                = $true
            HasProjects              = $true
            HasWiki                  = $true
            IsTemplate               = $true
            AddReadme                = $true
            AllowSquashMerge         = $true
            AllowAutoMerge           = $true
            DeleteBranchOnMerge      = $true
            SquashMergeCommitTitle   = 'PR_TITLE'
            SquashMergeCommitMessage = 'PR_BODY'
        }
        New-GitHubRepositoryUser @params

        Creates a new public repository named "Hello-World" owned by the authenticated user.

        .OUTPUTS
        GitHubRepository

        .LINK
        [Create a repository for the authenticated user](https://docs.github.com/rest/repos/repos#create-a-repository-for-the-authenticated-user)
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the repository.
        [Parameter(Mandatory)]
        [string] $Name,

        # A short description of the repository.
        [Parameter()]
        [string] $Description,

        # A URL with more information about the repository.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [uri] $Homepage,

        # The visibility of the repository.
        [Parameter()]
        [ValidateSet('public', 'private')]
        [string] $Visibility = 'public',

        # Whether issues are enabled.
        [Parameter()]
        [switch] $HasIssues,

        # Whether projects are enabled.
        [Parameter()]
        [switch] $HasProjects,

        # Whether the wiki is enabled.
        [Parameter()]
        [switch] $HasWiki,

        # Whether discussions are enabled.
        [Parameter()]
        [switch] $HasDiscussions,

        # Whether this repository acts as a template that can be used to generate new repositories.
        [Parameter()]
        [switch] $IsTemplate,

        # The ID of the team that will be granted access to this repository. This is only valid when creating a repository in an organization.
        [Parameter()]
        [System.Nullable[int]] $TeamId,

        # Pass true to create an initial commit with empty README.
        [Parameter()]
        [switch] $AddReadme,

        # The desired language or platform to apply to the .gitignore.
        [Parameter()]
        [string] $Gitignore,

        #The license keyword of the open source license for this repository.
        [Parameter()]
        [string] $License,

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

        # The default value for a squash merge commit title:
        #   - PR_TITLE - default to the pull request's title.
        #   - COMMIT_OR_PR_TITLE - default to the commit's title (if only one commit) or the pull request's title (when more than one commit).
        [Parameter()]
        [ValidateSet('PR_TITLE', 'COMMIT_OR_PR_TITLE')]
        [string] $SquashMergeCommitTitle,

        # The default value for a squash merge commit message:
        #   - PR_BODY - default to the pull request's body.
        #   - COMMIT_MESSAGES - default to the branch's commit messages.
        #   - BLANK - default to a blank commit message.
        [Parameter()]
        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [string] $SquashMergeCommitMessage,

        # The default value for a merge commit title.
        #   - PR_TITLE - default to the pull request's title.
        #   - MERGE_MESSAGE - default to the classic title for a merge message (e.g.,Merge pull request #123 from branch-name).
        [Parameter()]
        [ValidateSet('PR_TITLE', 'MERGE_MESSAGE')]
        [string] $MergeCommitTitle,

        # The default value for a merge commit message.
        #   - PR_BODY - default to the pull request's body.
        #   - PR_TITLE - default to the pull request's title.
        #   - BLANK - default to a blank commit message.
        [Parameter()]
        [ValidateSet('PR_BODY', 'PR_TITLE', 'BLANK')]
        [string] $MergeCommitMessage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            name                        = $Name
            description                 = $Description
            homepage                    = $Homepage
            has_issues                  = [bool]$HasIssues
            has_projects                = [bool]$HasProjects
            has_wiki                    = [bool]$HasWiki
            is_template                 = [bool]$IsTemplate
            team_id                     = $TeamId
            auto_init                   = [bool]$AddReadme
            gitignore_template          = $Gitignore
            license_template            = $License
            allow_squash_merge          = [bool]$AllowSquashMerge
            allow_merge_commit          = [bool]$AllowMergeCommit
            allow_rebase_merge          = [bool]$AllowRebaseMerge
            allow_auto_merge            = [bool]$AllowAutoMerge
            delete_branch_on_merge      = [bool]$DeleteBranchOnMerge
            squash_merge_commit_title   = $SquashMergeCommitTitle
            squash_merge_commit_message = $SquashMergeCommitMessage
            merge_commit_title          = $MergeCommitTitle
            merge_commit_message        = $MergeCommitMessage
            private                     = $Visibility -eq 'private'
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = '/user/repos'
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess('Repository for user', 'Create')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubRepository]::New($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
