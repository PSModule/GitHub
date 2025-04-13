#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }

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
            HasDownloads             = $true
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
            Owner                    = 'PSModule'
            Name                     = 'Hello-World'
            Description              = 'This is your first repository'
            Homepage                 = 'https://github.com'
            HasIssues                = $true
            HasProjects              = $true
            HasWiki                  = $true
            HasDownloads             = $true
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
            TemplateRepo       = 'octocat'
            Owner              = 'PSModule'
            Name               = 'MyNewRepo'
            IncludeAllBranches = $true
            Description        = 'My new repo'
            Private            = $true
        }
        New-GitHubRepository @params

        Creates a new private repository named `MyNewRepo` from the `octocat` template repository owned by `GitHub`.

        .EXAMPLE
        $params = @{
            ForkOwner         = 'octocat'
            ForkRepo          = 'Hello-World'
            Owner             = 'PSModule'
            Name              = 'MyNewRepo'
            DefaultBranchOnly = $true
        }
        New-GitHubRepository @params

        Creates a new repository named `MyNewRepo` as a fork of `Hello-World` owned by `octocat`.
        Only the default branch will be forked.

        .PARAMETER Gitignore
        The desired language or platform to apply to the .gitignore.

        .PARAMETER License
        The license keyword of the open source license for this repository.

        .OUTPUTS
        GitHubRepository

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/New-GitHubRepository/

        .LINK
        [Create a repository for the authenticated user](https://docs.github.com/rest/repos/repos#create-a-repository-for-the-authenticated-user)

        .LINK
        [Create an organization repository](https://docs.github.com/rest/repos/repos#create-an-organization-repository)
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'user')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'org')]
        [Parameter(ParameterSetName = 'fork')]
        [string] $Owner,

        # The name of the repository.
        [Parameter(ParameterSetName = 'fork')]
        [Parameter(Mandatory, ParameterSetName = 'user')]
        [Parameter(Mandatory, ParameterSetName = 'org')]
        [Parameter(Mandatory, ParameterSetName = 'template')]
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

        # When forking from an existing repository, fork with only the default branch.
        [Parameter(ParameterSetName = 'fork')]
        [switch] $DefaultBranchOnly,

        # A short description of the new repository.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [Parameter(ParameterSetName = 'template')]
        [string] $Description,

        # Set to true to include the directory structure and files from all branches in the template repository,
        # and not just the default branch.
        [Parameter(ParameterSetName = 'template')]
        [switch] $IncludeAllBranches,

        # A URL with more information about the repository.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [ValidateNotNullOrEmpty()]
        [uri] $Homepage,

        # The visibility of the repository.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [Parameter(ParameterSetName = 'template')]
        [ValidateSet('public', 'private', 'internal')]
        [string] $Visibility = 'public',

        # Whether issues are enabled.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $HasIssues,

        # Whether projects are enabled.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $HasProjects,

        # Whether the wiki is enabled.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $HasWiki,

        # Whether discussions are enabled.
        [Parameter(ParameterSetName = 'user')]
        [switch] $HasDiscussions,

        # Whether downloads are enabled.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $HasDownloads,

        # Whether this repository acts as a template that can be used to generate new repositories.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $IsTemplate,

        # The ID of the team that will be granted access to this repository. This is only valid when creating a repository in an organization.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [System.Nullable[int]] $TeamId,

        # Pass true to create an initial commit with empty README.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $AddReadme,

        # Whether to allow squash merges for pull requests.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $AllowSquashMerge,

        # Whether to allow merge commits for pull requests.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $AllowMergeCommit,

        # Whether to allow rebase merges for pull requests.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $AllowRebaseMerge,

        # Whether to allow Auto-merge to be used on pull requests.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $AllowAutoMerge,

        # Whether to delete head branches when pull requests are merged
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [switch] $DeleteBranchOnMerge,

        # The default value for a squash merge commit title:
        # - PR_TITLE - default to the pull request's title.
        # - COMMIT_OR_PR_TITLE - default to the commit's title (if only one commit) or the pull request's title (when more than one commit).
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [ValidateSet('PR_TITLE', 'COMMIT_OR_PR_TITLE')]
        [string] $SquashMergeCommitTitle,

        # The default value for a squash merge commit message:
        # - PR_BODY - default to the pull request's body.
        # - COMMIT_MESSAGES - default to the branch's commit messages.
        # - BLANK - default to a blank commit message.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [string] $SquashMergeCommitMessage,

        # The default value for a merge commit title.
        # - PR_TITLE - default to the pull request's title.
        # - MERGE_MESSAGE - default to the classic title for a merge message (e.g.,Merge pull request #123 from branch-name).
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [ValidateSet('PR_TITLE', 'MERGE_MESSAGE')]
        [string] $MergeCommitTitle,

        # The default value for a merge commit message.
        # - PR_BODY - default to the pull request's body.
        # - PR_TITLE - default to the pull request's title.
        # - BLANK - default to a blank commit message.
        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [ValidateSet('PR_BODY', 'PR_TITLE', 'BLANK')]
        [string] $MergeCommitMessage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    #TODO: Move this to argument completers that are linked to all params with this name.
    dynamicparam {
        $DynamicParamDictionary = New-DynamicParamDictionary

        $dynParam = @{
            Name                   = 'Gitignore'
            Type                   = [string]
            ValidateSet            = Get-GitHubGitignore
            DynamicParamDictionary = $DynamicParamDictionary
        }
        New-DynamicParam @dynParam

        $dynParam2 = @{
            Name                   = 'License'
            Type                   = [string]
            ValidateSet            = Get-GitHubLicense | Select-Object -ExpandProperty key
            DynamicParamDictionary = $DynamicParamDictionary
        }
        New-DynamicParam @dynParam2

        return $DynamicParamDictionary
    }

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
                    Context                  = $Context
                    Name                     = $Name
                    Description              = $Description
                    Homepage                 = $Homepage
                    Visibility               = $Visibility
                    HasIssues                = $HasIssues
                    HasProjects              = $HasProjects
                    HasWiki                  = $HasWiki
                    HasDiscussions           = $HasDiscussions
                    HasDownloads             = $HasDownloads
                    IsTemplate               = $IsTemplate
                    TeamId                   = $TeamId
                    AddReadme                = $AddReadme
                    AllowSquashMerge         = $AllowSquashMerge
                    AllowMergeCommit         = $AllowMergeCommit
                    AllowRebaseMerge         = $AllowRebaseMerge
                    AllowAutoMerge           = $AllowAutoMerge
                    DeleteBranchOnMerge      = $DeleteBranchOnMerge
                    SquashMergeCommitTitle   = $SquashMergeCommitTitle
                    SquashMergeCommitMessage = $SquashMergeCommitMessage
                    MergeCommitTitle         = $MergeCommitTitle
                    MergeCommitMessage       = $MergeCommitMessage
                    Gitignore                = $PSBoundParameters['Gitignore']
                    License                  = $PSBoundParameters['License']
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                if ($PSCmdlet.ShouldProcess("repository for user [$Name]", 'Create')) {
                    New-GitHubRepositoryUser @params
                }
            }
            'org' {
                $params = @{
                    Context                  = $Context
                    Owner                    = $Owner
                    Name                     = $Name
                    Description              = $Description
                    Homepage                 = $Homepage
                    Visibility               = $Visibility
                    HasIssues                = $HasIssues
                    HasProjects              = $HasProjects
                    HasWiki                  = $HasWiki
                    HasDownloads             = $HasDownloads
                    IsTemplate               = $IsTemplate
                    TeamId                   = $TeamId
                    AddReadme                = $AddReadme
                    AllowSquashMerge         = $AllowSquashMerge
                    AllowMergeCommit         = $AllowMergeCommit
                    AllowRebaseMerge         = $AllowRebaseMerge
                    AllowAutoMerge           = $AllowAutoMerge
                    DeleteBranchOnMerge      = $DeleteBranchOnMerge
                    SquashMergeCommitTitle   = $SquashMergeCommitTitle
                    SquashMergeCommitMessage = $SquashMergeCommitMessage
                    MergeCommitTitle         = $MergeCommitTitle
                    MergeCommitMessage       = $MergeCommitMessage
                    Gitignore                = $PSBoundParameters['Gitignore']
                    License                  = $PSBoundParameters['License']
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                if ($PSCmdlet.ShouldProcess("repository for organization [$Owner/$Name]", 'Create')) {
                    New-GitHubRepositoryOrg @params
                }
            }
            'template' {
                if ($PSCmdlet.ShouldProcess("repository [$Owner/$Name] from template [$TemplateOwner/$TemplateRepository]", 'Create')) {
                    $params = @{
                        Context            = $Context
                        TemplateOwner      = $TemplateOwner
                        TemplateRepo       = $TemplateRepository
                        Owner              = $Owner
                        Name               = $Name
                        IncludeAllBranches = $IncludeAllBranches
                        Description        = $Description
                        Private            = $Visibility -eq 'private'
                    }
                    $params | Remove-HashtableEntry -NullOrEmptyValues
                    New-GitHubRepositoryFromTemplate @params
                }
            }
            'fork' {
                if ([string]::IsNullorEmpty($Name)) {
                    $Name = $ForkRepository
                }
                if ($PSCmdlet.ShouldProcess("repository [$Owner/$Name] as fork from [$ForkOwner/$ForkRepository]", 'Create')) {
                    $params = @{
                        Context           = $Context
                        Owner             = $ForkOwner
                        Repository        = $ForkRepository
                        Organization      = $Owner
                        Name              = $Name
                        DefaultBranchOnly = $DefaultBranchOnly
                    }
                    $params | Remove-HashtableEntry -NullOrEmptyValues
                    New-GitHubRepositoryAsFork @params
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
