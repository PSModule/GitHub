﻿filter New-GitHubRepositoryOrg {
    <#
        .SYNOPSIS
        Create an organization repository

        .DESCRIPTION
        Creates a new repository in the specified organization. The authenticated user must be a member of the organization.

        **OAuth scope requirements**

        When using [OAuth](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:

        * `public_repo` scope or `repo` scope to create a public repository. Note: For GitHub AE, use `repo` scope to create an internal repository.
        * `repo` scope to create a private repository

        .EXAMPLE
        $params = @{
            Owner                    = 'PSModule'
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
        New-GitHubRepositoryOrg @params

        Creates a new public repository named "Hello-World" owned by the organization "PSModule".

        .OUTPUTS
        GitHubRepository

        .NOTES
        [Create an organization repository](https://docs.github.com/rest/repos/repos#create-an-organization-repository)
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Organization,

        # The name of the repository.
        [Parameter(Mandatory)]
        [string] $Name,

        # A short description of the repository.
        [Parameter()]
        [string] $Description,

        # A URL with more information about the repository.
        [Parameter()]
        [uri] $Homepage,

        # The visibility of the repository.
        [Parameter()]
        [ValidateSet('Public', 'Private', 'Internal')]
        [string] $Visibility = 'Public',

        # Either true to enable issues for this repository or false to disable them.
        [Parameter()]
        [bool] $HasIssues = $true,

        # Either true to enable projects for this repository or false to disable them.
        # Note: If you're creating a repository in an organization that has disabled repository projects, the default is false,
        # and if you pass true, the API returns an error.
        [Parameter()]
        [bool] $HasProjects = $true,

        # Either true to enable the wiki for this repository or false to disable it.
        [Parameter()]
        [bool] $HasWiki = $true,

        # Either true to make this repo available as a template repository or false to prevent it.
        [Parameter()]
        [bool] $IsTemplate = $false,

        # Pass true to create an initial commit with empty README.
        [Parameter()]
        [bool] $AddReadme = $false,

        # The desired language or platform to apply to the .gitignore.
        [Parameter()]
        [string] $Gitignore,

        # The license keyword of the open source license for this repository.
        [Parameter()]
        [string] $License,

        # Either true to allow squash-merging pull requests, or false to prevent squash-merging.
        [Parameter()]
        [bool] $AllowSquashMerge = $true,

        # Either true to allow merging pull requests with a merge commit, or false to prevent merging pull requests with merge commits.
        [Parameter()]
        [bool] $AllowMergeCommit = $true,

        # Either true to allow rebase-merging pull requests, or false to prevent rebase-merging.
        [Parameter()]
        [bool] $AllowRebaseMerge = $true,

        # Either true to allow auto-merge on pull requests, or false to disallow auto-merge.
        [Parameter()]
        [bool] $AllowAutoMerge = $false,

        # Either true to allow automatically deleting head branches when pull requests are merged, or false to prevent automatic deletion.
        # The authenticated user must be an organization owner to set this property to true.
        [Parameter()]
        [bool] $DeleteBranchOnMerge = $false,

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
            homepage                    = [string]$Homepage
            visibility                  = $Visibility.ToLower()
            has_issues                  = $HasIssues
            has_projects                = $HasProjects
            has_wiki                    = $HasWiki
            is_template                 = $IsTemplate
            auto_init                   = $AddReadme
            allow_squash_merge          = $AllowSquashMerge
            allow_merge_commit          = $AllowMergeCommit
            allow_rebase_merge          = $AllowRebaseMerge
            allow_auto_merge            = $AllowAutoMerge
            delete_branch_on_merge      = $DeleteBranchOnMerge
            squash_merge_commit_title   = $SquashMergeCommitTitle
            squash_merge_commit_message = $SquashMergeCommitMessage
            merge_commit_title          = $MergeCommitTitle
            merge_commit_message        = $MergeCommitMessage
            gitignore_template          = $Gitignore
            license_template            = $License
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $apiParams = @{
            Method      = 'POST'
            APIEndpoint = "/orgs/$Organization/repos"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Repository [$Name] in organization [$Organization]", 'Create')) {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                [GitHubRepository]::New($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
