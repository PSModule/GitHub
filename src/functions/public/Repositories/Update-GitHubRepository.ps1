filter Update-GitHubRepository {
    <#
        .SYNOPSIS
        Update a repository

        .DESCRIPTION
        **Note**: To edit a repository's topics, use the
        [Replace all repository topics](https://docs.github.com/rest/repos/repos#replace-all-repository-topics) endpoint.

        .EXAMPLE
        ```powershell
        Update-GitHubRepository -Name 'octocat' -Description 'Hello-World' -Homepage 'https://github.com'
        ```

        .EXAMPLE
        ```powershell
        $params = @{
            Owner       = 'octocat'
            Name        = 'Hello-World'
            NewName     = 'Hello-World-Repository'
            Description = 'This is your first repository'
            Homepage    = 'https://github.com'
        }
        Update-GitHubRepository @params
        ```

        Updates the repository `Hello-World` owned by `octocat` with a new name, description, and homepage URL.

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

        # The visibility of the repository.
        [Parameter()]
        [ValidateSet('Public', 'Private', 'Internal')]
        [string] $Visibility,

        # A short description of the repository.
        [Parameter()]
        [string] $Description,

        # A URL with more information about the repository.
        [Parameter()]
        [uri] $Homepage,

        # Whether to archive this repository. false will unarchive a previously archived repository.
        [Parameter()]
        [System.Nullable[bool]] $IsArchived,

        # Whether this repository acts as a template that can be used to generate new repositories.
        [Parameter()]
        [System.Nullable[bool]] $IsTemplate,

        # Whether to require contributors to sign off on web-based commits.
        [Parameter()]
        [System.Nullable[bool]] $WebCommitSignoffRequired,

        # Updates the default branch for this repository.
        [Parameter()]
        [string] $DefaultBranch,

        # Whether the wiki is enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasWiki,

        # Whether issues are enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasIssues,

        # Either true to allow private forks, or false to prevent private forks.
        [Parameter()]
        [System.Nullable[bool]] $AllowForking,

        # Whether sponsorships are enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasSponsorships,

        # Whether discussions are enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasDiscussions,

        # Whether projects are enabled.
        [Parameter()]
        [System.Nullable[bool]] $HasProjects,

        # Allow merge commits for pull requests with the specified setting.
        [Parameter()]
        [ValidateSet('', 'Default message', 'Pull request title', 'Pull request title and description')]
        [string] $AllowMergeCommitWith,

        # Allow squash merges for pull requests with the specified setting.
        [Parameter()]
        [ValidateSet('', 'Default message', 'Pull request title', 'Pull request title and description', 'Pull request title and commit details')]
        [string] $AllowSquashMergingWith,

        # Whether to allow rebase merges for pull requests.
        [Parameter()]
        [switch] $AllowRebaseMerging,

        # Whether to always suggest to update a head branch that is behind its base branch during a pull request.
        [Parameter()]
        [System.Nullable[bool]] $SuggestUpdateBranch,

        # Whether to allow Auto-merge to be used on pull requests.
        [Parameter()]
        [System.Nullable[bool]] $AllowAutoMerge,

        # Whether to delete head branches when pull requests are merged
        [Parameter()]
        [System.Nullable[bool]] $DeleteBranchOnMerge,

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

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
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
        $repo = Get-GitHubRepository -Owner $Owner -Name $Name
        if (-not $repo) {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    [System.Management.Automation.ItemNotFoundException]::new("Repository '$Name' not found for owner '$Owner'."),
                    'RepositoryNotFound',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $null
                )
            )
        }

        if ($PSBoundParameters.ContainsKey('AllowMergeCommitWith')) {
            switch ($AllowMergeCommitWith) {
                'Default message' {
                    $AllowMergeCommit = $true
                    $MergeCommitTitle = 'MERGE_MESSAGE'
                    $MergeCommitMessage = 'PR_TITLE'
                }
                'Pull request title' {
                    $AllowMergeCommit = $true
                    $MergeCommitTitle = 'PR_TITLE'
                    $MergeCommitMessage = 'BLANK'
                }
                'Pull request title and description' {
                    $AllowMergeCommit = $true
                    $MergeCommitTitle = 'PR_TITLE'
                    $MergeCommitMessage = 'PR_BODY'
                }
                default {
                    $AllowMergeCommit = $false
                }
            }
        }

        if ($PSBoundParameters.ContainsKey('AllowSquashMergingWith')) {
            switch ($AllowSquashMergingWith) {
                'Default message' {
                    $AllowSquashMerge = $true
                    $SquashMergeCommitTitle = 'COMMIT_OR_PR_TITLE'
                    $SquashMergeCommitMessage = 'COMMIT_MESSAGES'
                }
                'Pull request title' {
                    $AllowSquashMerge = $true
                    $SquashMergeCommitTitle = 'PR_TITLE'
                    $SquashMergeCommitMessage = 'BLANK'
                }
                'Pull request title and description' {
                    $AllowSquashMerge = $true
                    $SquashMergeCommitTitle = 'PR_TITLE'
                    $SquashMergeCommitMessage = 'PR_BODY'
                }
                'Pull request title and commit details' {
                    $AllowSquashMerge = $true
                    $SquashMergeCommitTitle = 'PR_TITLE'
                    $SquashMergeCommitMessage = 'COMMIT_MESSAGES'
                }
                default {
                    $AllowSquashMerge = $false
                }
            }
        }

        $body = @{
            name                                  = $NewName
            visibility                            = $Visibility.ToLower()
            description                           = $Description
            homepage                              = $Homepage
            archived                              = $IsArchived
            is_template                           = $IsTemplate
            web_commit_signoff_required           = $WebCommitSignoffRequired
            default_branch                        = $DefaultBranch
            has_wiki                              = $HasWiki
            has_issues                            = $HasIssues
            allow_forking                         = $AllowForking
            has_projects                          = $HasProjects
            allow_squash_merge                    = $AllowSquashMerge
            allow_merge_commit                    = $AllowMergeCommit
            squash_merge_commit_title             = $SquashMergeCommitTitle
            squash_merge_commit_message           = $SquashMergeCommitMessage
            merge_commit_title                    = $MergeCommitTitle
            merge_commit_message                  = $MergeCommitMessage
            allow_rebase_merge                    = $AllowRebaseMerge
            allow_update_branch                   = $SuggestUpdateBranch
            allow_auto_merge                      = $AllowAutoMerge
            delete_branch_on_merge                = $DeleteBranchOnMerge
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
        }

        $body | Remove-HashtableEntry -NullOrEmptyValues

        if ($DebugPreference -eq 'Continue') {
            Write-Debug 'Changed settings for REST call is:'
            [pscustomobject]$body | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        }
        if ($body.Keys.Count -gt 0) {
            $apiParams = @{
                Method      = 'PATCH'
                APIEndpoint = "/repos/$Owner/$Name"
                Body        = $body
                Context     = $Context
            }

            if ($PSCmdlet.ShouldProcess("Repository [$Owner/$Name]", 'Update')) {
                $updatedRepo = Invoke-GitHubAPI @apiParams | Select-Object -ExpandProperty Response
            }
            if ($DebugPreference -eq 'Continue') {
                Write-Debug 'Repo has been updated'
                $updatedRepo | Select-Object * | Out-String -Stream | ForEach-Object { Write-Debug $_ }
            }
        } else {
            Write-Debug 'No changes made to repo via REST'
        }

        $inputParams = @{
            hasSponsorshipsEnabled = $HasSponsorships
            hasDiscussionsEnabled  = $HasDiscussions
        }
        $inputParams | Remove-HashtableEntry -NullOrEmptyValues

        if ($DebugPreference -eq 'Continue') {
            Write-Debug 'Changed settings for GraphQL call is:'
            $inputParams | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        }
        if ($inputParams.Keys.Count -gt 0) {
            $inputParams += @{
                repositoryId = $repo.NodeID
            }

            $updateGraphQLInputs = @{
                query     = @'
                mutation($input:UpdateRepositoryInput!) {
                    updateRepository(input:$input) {
                        repository {
                            id
                            name
                            hasSponsorshipsEnabled
                            hasDiscussionsEnabled
                        }
                    }
                }
'@
                variables = @{
                    input = $inputParams
                }
            }
            $null = Invoke-GitHubGraphQLQuery @updateGraphQLInputs
        } else {
            Write-Debug 'No changes made to repo via GraphQL'
        }

        Get-GitHubRepository -Owner $Owner -Name $Name
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
