filter New-GitHubRepository {
    <#
        .SYNOPSIS
        Create a repository for a user or an organization.

        .DESCRIPTION
        Creates a new repository for a user or in a specified organization.

        **OAuth scope requirements**

        When using [OAuth](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:

        * `public_repo` scope or `repo` scope to create a public repository. Note: For GitHub AE, use `repo` scope to create an internal repository.
        * `repo` scope to create a private repository

        .EXAMPLE
        $params = @{
            Name                     = 'Hello-World'
            Description              = 'This is your first repository'
            Homepage                 = 'https://github.com'
            HasIssues                = $true
            HasProjects              = $true
            HasWiki                  = $true
            HasDiscussions           = $true
            IsTemplate               = $true
            AddReadme                = $true
            AllowSquashMerge         = $true
            AllowAutoMerge           = $true
            DeleteBranchOnMerge      = $true
            SquashMergeCommitTitle   = 'PR_TITLE'
            SquashMergeCommitMessage = 'PR_BODY'
        }
        New-GitHubRepository @params

        Creates a new public repository named "Hello-World" owned by the authenticated user.

        .EXAMPLE
        $params = @{
            Organization             = 'PSModule'
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
        New-GitHubRepository @params

        Creates a new public repository named "Hello-World" owned by the organization "PSModule".

        .EXAMPLE
        $params = @{
            TemplateOwner      = 'GitHub'
            TemplateRepository = 'octocat'
            Organization       = 'PSModule'
            Name               = 'MyNewRepo'
            IncludeAllBranches = $true
            Description        = 'My new repo'
            Visibility         = 'Private'
        }
        New-GitHubRepository @params

        Creates a new private repository named `MyNewRepo` from the `octocat` template repository owned by `GitHub`.

        .EXAMPLE
        $params = @{
            ForkOwner         = 'octocat'
            ForkRepo          = 'Hello-World'
            Organization      = 'PSModule'
            Name              = 'MyNewRepo'
            DefaultBranchOnly = $true
        }
        New-GitHubRepository @params

        Creates a new repository named `MyNewRepo` as a fork of `Hello-World` owned by `octocat`.
        Only the default branch will be forked.

        .OUTPUTS
        GitHubRepository

        .NOTES
        [Create a repository for the authenticated user](https://docs.github.com/rest/repos/repos#create-a-repository-for-the-authenticated-user)
        [Create an organization repository](https://docs.github.com/rest/repos/repos#create-an-organization-repository)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/New-GitHubRepository/
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'user')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'org')]
        [Parameter(ParameterSetName = 'fork')]
        [Parameter(ParameterSetName = 'template')]
        [Alias('Owner')]
        [string] $Organization,

        # The name of the repository.
        [Parameter(ParameterSetName = 'fork')]
        [Parameter(ParameterSetName = 'template')]
        [Parameter(Mandatory, ParameterSetName = 'user')]
        [Parameter(Mandatory, ParameterSetName = 'org')]
        [string] $Name,

        # The account owner of the template repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'template')]
        [string] $TemplateOwner,

        # The name of the template repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'template')]
        [string] $TemplateRepository,

        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'fork')]
        [string] $ForkOwner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'fork')]
        [string] $ForkRepository,

        # Include all branches from the source repository.
        [Parameter(ParameterSetName = 'template')]
        [Parameter(ParameterSetName = 'fork')]
        [switch] $IncludeAllBranches,

        # A short description of the new repository.
        [Parameter()]
        [string] $Description,

        # A URL with more information about the repository.
        [Parameter()]
        [uri] $Homepage,

        # The visibility of the repository.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [Parameter(ParameterSetName = 'template')]
        [ValidateSet('Public', 'Private', 'Internal')]
        [string] $Visibility = 'Public',

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

        # Whether sponsorships are enabled.
        [Parameter()]
        [bool] $HasSponsorships,

        # Whether this repository acts as a template that can be used to generate new repositories.
        [Parameter()]
        [switch] $IsTemplate,

        # Whether the repository is archived.
        [Parameter()]
        [bool] $IsArchived,

        # Pass true to create an initial commit with empty README.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $AddReadme,

        # The desired language or platform to apply to the .gitignore.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [string] $Gitignore,

        # The license keyword of the open source license for this repository.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
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
    }

    process {
        Write-Verbose "ParameterSetName: $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName) {
            'user' {
                $params = @{
                    Context    = $Context
                    Name       = $Name
                    Visibility = $Visibility
                    AddReadme  = $AddReadme
                    Gitignore  = $Gitignore
                    License    = $License
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                New-GitHubRepositoryUser @params
            }
            'org' {
                $params = @{
                    Context      = $Context
                    Organization = $Organization
                    Name         = $Name
                    Visibility   = $Visibility
                    AddReadme    = $AddReadme
                    Gitignore    = $Gitignore
                    License      = $License
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                New-GitHubRepositoryOrg @params
            }
            'template' {
                $params = @{
                    Context            = $Context
                    TemplateOwner      = $TemplateOwner
                    TemplateRepository = $TemplateRepository
                    Owner              = $Organization
                    Name               = $Name
                    IncludeAllBranches = $IncludeAllBranches
                    Visibility         = $Visibility
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                New-GitHubRepositoryFromTemplate @params
            }
            'fork' {
                $params = @{
                    Context            = $Context
                    ForkOwner          = $ForkOwner
                    ForkRepository     = $ForkRepository
                    Owner              = $Organization
                    Name               = $Name
                    IncludeAllBranches = $IncludeAllBranches
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                New-GitHubRepositoryAsFork @params
            }
        }

        $updateParams = @{
            Owner                                   = $Owner ?? $Context.Username
            Name                                    = $Name
            Description                             = $Description
            Homepage                                = $Homepage
            Visibility                              = $Visibility
            EnableAdvancedSecurity                  = $EnableAdvancedSecurity
            EnableCodeSecurity                      = $EnableCodeSecurity
            EnableSecretScanning                    = $EnableSecretScanning
            EnableSecretScanningPushProtection      = $EnableSecretScanningPushProtection
            EnableSecretScanningAIDetection         = $EnableSecretScanningAIDetection
            EnableSecretScanningNonProviderPatterns = $EnableSecretScanningNonProviderPatterns
            HasIssues                               = $HasIssues
            HasProjects                             = $HasProjects
            HasWiki                                 = $HasWiki
            HasDiscussions                          = $HasDiscussions
            HasSponsorships                         = $HasSponsorships
            IsTemplate                              = $IsTemplate
            DefaultBranch                           = $DefaultBranch
            AllowSquashMerge                        = $AllowSquashMerge
            AllowMergeCommit                        = $AllowMergeCommit
            AllowRebaseMerge                        = $AllowRebaseMerge
            AllowAutoMerge                          = $AllowAutoMerge
            DeleteBranchOnMerge                     = $DeleteBranchOnMerge
            SuggestUpdateBranch                     = $SuggestUpdateBranch
            SquashMergeCommitTitle                  = $SquashMergeCommitTitle
            SquashMergeCommitMessage                = $SquashMergeCommitMessage
            MergeCommitTitle                        = $MergeCommitTitle
            MergeCommitMessage                      = $MergeCommitMessage
            IsArchived                              = $IsArchived
            AllowForking                            = $AllowForking
            WebCommitSignoffRequired                = $WebCommitSignoffRequired
        }
        Update-GitHubRepository @updateParams
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
