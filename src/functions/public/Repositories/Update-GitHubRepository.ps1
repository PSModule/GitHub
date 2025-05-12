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

        # Whether to enable GitHub Advanced Security for this repository.
        [Parameter()]
        [System.Nullable[bool]] $EnableAdvancedSecurity,

        # Whether to enable code security for this repository.
        [Parameter()]
        [System.Nullable[bool]] $EnableCodeSecurity,

        # Whether to enable secret scanning for this repository.
        [Parameter()]
        [System.Nullable[bool]] $EnableSecretScanning,

        # Whether to enable secret scanning push protection for this repository.
        [Parameter()]
        [System.Nullable[bool]] $EnableSecretScanningPushProtection,

        # Whether to enable secret scanning AI detection for this repository.
        [Parameter()]
        [System.Nullable[bool]] $EnableSecretScanningAIDetection,

        # Whether to enable secret scanning non-provider patterns for this repository.
        [Parameter()]
        [System.Nullable[bool]] $EnableSecretScanningNonProviderPatterns,

        # Whether issues are enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasIssues,

        # Whether projects are enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasProjects,

        # Whether the wiki is enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasWiki,

        # Whether discussions are enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasDiscussions,

        # Whether sponsorships are enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasSponsorships,

        # Whether this repository acts as a template that can be used to generate new repositories.
        [Parameter()]
        [System.Nullable[bool]] $IsTemplate,

        # Updates the default branch for this repository.
        [Parameter()]
        [string] $DefaultBranch,

        # Whether to allow squash merges for pull requests.
        [Parameter()]
        [System.Nullable[bool]] $AllowSquashMerge,

        # Whether to allow merge commits for pull requests.
        [Parameter()]
        [System.Nullable[bool]] $AllowMergeCommit,

        # Whether to allow rebase merges for pull requests.
        [Parameter()]
        [System.Nullable[bool]] $AllowRebaseMerge,

        # Whether to allow Auto-merge to be used on pull requests.
        [Parameter()]
        [System.Nullable[bool]] $AllowAutoMerge,

        # Whether to delete head branches when pull requests are merged
        [Parameter()]
        [System.Nullable[bool]] $DeleteBranchOnMerge,

        # Either true to always allow a pull request head branch that is behind its base branch
        # to be updated even if it is not required to be up to date before merging, or false otherwise.
        [Parameter()]
        [System.Nullable[bool]] $SuggestUpdateBranch,

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
        [System.Nullable[bool]] $IsArchived,

        # Either true to allow private forks, or false to prevent private forks.
        [Parameter()]
        [System.Nullable[bool]] $AllowForking,

        # Either true to require contributors to sign off on web-based commits,
        # or false to not require contributors to sign off on web-based commits.
        [Parameter()]
        [System.Nullable[bool]] $WebCommitSignoffRequired,

        # Takes all parameters and updates the repository with the provided _AND_ the default values of the non-provided parameters.
        # Used for Set-GitHubRepository.
        [Parameter()]
        [switch] $Declare,

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
            name                                  = $NewName
            description                           = $Description
            homepage                              = $Homepage
            visibility                            = $Visibility.ToLower()
            default_branch                        = $DefaultBranch
            advanced_security                     = $PSBoundParameters.ContainsKey('EnableAdvancedSecurity') ? @{
                status = $EnableAdvancedSecurity ? 'enabled' : 'disabled'
            } : $null
            code_security                         = $PSBoundParameters.ContainsKey('EnableCodeSecurity') ? @{
                status = $EnableCodeSecurity ? 'enabled' : 'disabled'
            } : $null
            secret_scanning                       = $PSBoundParameters.ContainsKey('EnableSecretScanning') ? @{
                status = $EnableSecretScanning ? 'enabled' : 'disabled'
            } : $null
            secret_scanning_push_protection       = $PSBoundParameters.ContainsKey('EnableSecretScanningPushProtection') ? @{
                status = $EnableSecretScanningPushProtection ? 'enabled' : 'disabled'
            } : $null
            secret_scanning_ai_detection          = $PSBoundParameters.ContainsKey('EnableSecretScanningAIDetection') ? @{
                status = $EnableSecretScanningAIDetection ? 'enabled' : 'disabled'
            } : $null
            secret_scanning_non_provider_patterns = $PSBoundParameters.ContainsKey('EnableSecretScanningNonProviderPatterns') ? @{
                status = $EnableSecretScanningNonProviderPatterns ? 'enabled' : 'disabled'
            } : $null
            has_issues                            = $PSBoundParameters.ContainsKey('HasIssues') ? $HasIssues : $null
            has_projects                          = $PSBoundParameters.ContainsKey('HasProjects') ? $HasProjects : $null
            has_wiki                              = $PSBoundParameters.ContainsKey('HasWiki') ? $HasWiki : $null
            is_template                           = $PSBoundParameters.ContainsKey('IsTemplate') ? $IsTemplate : $null
            allow_squash_merge                    = $PSBoundParameters.ContainsKey('AllowSquashMerge') ? $AllowSquashMerge : $null
            allow_merge_commit                    = $PSBoundParameters.ContainsKey('AllowMergeCommit') ? $AllowMergeCommit : $null
            squash_merge_commit_title             = $SquashMergeCommitTitle
            squash_merge_commit_message           = $SquashMergeCommitMessage
            merge_commit_title                    = $MergeCommitTitle
            merge_commit_message                  = $MergeCommitMessage
            allow_rebase_merge                    = $PSBoundParameters.ContainsKey('AllowRebaseMerge') ? $AllowRebaseMerge : $null
            allow_auto_merge                      = $PSBoundParameters.ContainsKey('AllowAutoMerge') ? $AllowAutoMerge : $null
            allow_update_branch                   = $PSBoundParameters.ContainsKey('SuggestUpdateBranch') ? $SuggestUpdateBranch : $null
            delete_branch_on_merge                = $PSBoundParameters.ContainsKey('DeleteBranchOnMerge') ? $DeleteBranchOnMerge : $null
            archived                              = $PSBoundParameters.ContainsKey('Archived') ? $Archived : $null
            allow_forking                         = $PSBoundParameters.ContainsKey('AllowForking') ? $AllowForking : $null
            web_commit_signoff_required           = $PSBoundParameters.ContainsKey('WebCommitSignoffRequired') ? $WebCommitSignoffRequired : $null
        }
        if (-not $Declare) {
            $body | Remove-HashtableEntry -NullOrEmptyValues
        }

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = "/repos/$Owner/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Repository [$Owner/$Name]", 'Update')) {
            $repo = Invoke-GitHubAPI @inputObject | Select-Object -ExpandProperty Response
        }

        $updateGraphQLInputs = @{
            query = @"
                mutation {
                    updateRepository(input: {
                        repositoryId           = $($repo.NodeID)
                        hasDiscussionsEnabled  = $HasDiscussions
                        hasSponsorshipsEnabled = $HasSponsorships
                    }) {
                        repository {
                            id
                            name
                            owner {
                                login
                            }
                            hasDiscussionsEnabled
                            hasSponsorshipsEnabled
                        }
                    }
                }
"@
        }

        Invoke-GitHubGraphQLQuery @updateGraphQLInputs
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
