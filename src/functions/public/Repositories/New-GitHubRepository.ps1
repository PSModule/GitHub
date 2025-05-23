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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Create a repository for the authenticated user')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Create a repository in an organization')]
        [Parameter(Mandatory, ParameterSetName = 'Fork a repository to an organization')]
        [Parameter(Mandatory, ParameterSetName = 'Create a repository from a template to an organization')]
        [Alias('Owner')]
        [string] $Organization,

        # The name of the repository.
        [Parameter(ParameterSetName = 'Fork a repository to an organization')]
        [Parameter(ParameterSetName = 'Fork a repository to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Create a repository from a template to an organization')]
        [Parameter(Mandatory, ParameterSetName = 'Create a repository from a template to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Create a repository for the authenticated user')]
        [Parameter(Mandatory, ParameterSetName = 'Create a repository in an organization')]
        [string] $Name,

        # The account owner of the template repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Create a repository from a template to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Create a repository from a template to an organization')]
        [string] $TemplateOwner,

        # The name of the template repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Create a repository from a template to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Create a repository from a template to an organization')]
        [string] $TemplateRepository,

        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Fork a repository to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Fork a repository to an organization')]
        [string] $ForkOwner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Fork a repository to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Fork a repository to an organization')]
        [string] $ForkRepository,

        # Include all branches from the source repository.
        [Parameter(ParameterSetName = 'Create a repository from a template to a user')]
        [Parameter(ParameterSetName = 'Create a repository from a template to an organization')]
        [Parameter(ParameterSetName = 'Fork a repository to a user')]
        [Parameter(ParameterSetName = 'Fork a repository to an organization')]
        [switch] $IncludeAllBranches,

        # Pass true to create an initial commit with empty README.
        [Parameter(ParameterSetName = 'Create a repository for the authenticated user')]
        [Parameter(ParameterSetName = 'Create a repository in an organization')]
        [switch] $AddReadme,

        # The desired language or platform to apply to the .gitignore.
        [Parameter(ParameterSetName = 'Create a repository for the authenticated user')]
        [Parameter(ParameterSetName = 'Create a repository in an organization')]
        [string] $Gitignore,

        # The license keyword of the open source license for this repository.
        [Parameter(ParameterSetName = 'Create a repository for the authenticated user')]
        [Parameter(ParameterSetName = 'Create a repository in an organization')]
        [string] $License,

        # The visibility of the repository.
        [Parameter(ParameterSetName = 'Create a repository for the authenticated user')]
        [Parameter(ParameterSetName = 'Create a repository in an organization')]
        [Parameter(ParameterSetName = 'Create a repository from a template to an organization')]
        [ValidateSet('Public', 'Private', 'Internal')]
        [string] $Visibility = 'Public',

        # A short description of the new repository.
        [Parameter()]
        [string] $Description,

        # A URL with more information about the repository.
        [Parameter()]
        [uri] $Homepage,

        # Whether the repository is archived.
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
        [Parameter(ParameterSetName = 'Fork a repository to an organization')]
        [Parameter(ParameterSetName = 'Create a repository from a template to an organization')]
        [Parameter(ParameterSetName = 'Create a repository in an organization')]
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
        [string] $AllowMergeCommitWith = 'Default message',

        # Allow squash merges for pull requests with the specified setting.
        [Parameter()]
        [ValidateSet('', 'Default message', 'Pull request title', 'Pull request title and description', 'Pull request title and commit details')]
        [string] $AllowSquashMergingWith = 'Default message',

        # Whether to allow rebase merges for pull requests.
        [Parameter()]
        [switch] $AllowRebaseMerging,

        # Whether to always suggest to update a head branch that is behind its base branch during a pull request.
        [Parameter()]
        [System.Nullable[switch]] $SuggestUpdateBranch,

        # Whether to allow Auto-merge to be used on pull requests.
        [Parameter()]
        [System.Nullable[switch]] $AllowAutoMerge,

        # Whether to delete head branches when pull requests are merged
        [Parameter()]
        [System.Nullable[switch]] $DeleteBranchOnMerge,

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
        $repo = switch ($PSCmdlet.ParameterSetName) {
            'Create a repository for the authenticated user' {
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
            'Create a repository in an organization' {
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
            'Create a repository from a template to a user' {
                $params = @{
                    Context            = $Context
                    TemplateOwner      = $TemplateOwner
                    TemplateRepository = $TemplateRepository
                    Name               = $Name
                    IncludeAllBranches = $IncludeAllBranches
                    Visibility         = $Visibility
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                New-GitHubRepositoryFromTemplate @params
            }
            'Create a repository from a template to an organization' {
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
            'Fork a repository to a user' {
                $params = @{
                    Context            = $Context
                    ForkOwner          = $ForkOwner
                    ForkRepository     = $ForkRepository
                    Name               = $Name
                    IncludeAllBranches = $IncludeAllBranches
                }
                $params | Remove-HashtableEntry -NullOrEmptyValues
                New-GitHubRepositoryAsFork @params
            }
            'Fork a repository to an organization' {
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

        Write-Debug 'New repo created'
        Write-Debug "$($repo | Format-Table | Out-String)"

        $updateParams = @{
            Owner                                   = $repo.Owner
            Name                                    = $repo.Name
            Visibility                              = $Visibility
            Description                             = $Description
            Homepage                                = $Homepage
            IsArchived                              = $IsArchived
            IsTemplate                              = $IsTemplate
            WebCommitSignoffRequired                = $WebCommitSignoffRequired
            DefaultBranch                           = $DefaultBranch
            HasWiki                                 = $HasWiki
            HasIssues                               = $HasIssues
            HasSponsorships                         = $HasSponsorships
            HasDiscussions                          = $HasDiscussions
            HasProjects                             = $HasProjects
            AllowMergeCommitWith                    = $AllowMergeCommitWith
            AllowSquashMergingWith                  = $AllowSquashMergingWith
            AllowRebaseMerging                      = $AllowRebaseMerging
            SuggestUpdateBranch                     = $SuggestUpdateBranch
            AllowAutoMerge                          = $AllowAutoMerge
            DeleteBranchOnMerge                     = $DeleteBranchOnMerge
            EnableAdvancedSecurity                  = $EnableAdvancedSecurity
            EnableCodeSecurity                      = $EnableCodeSecurity
            EnableSecretScanning                    = $EnableSecretScanning
            EnableSecretScanningPushProtection      = $EnableSecretScanningPushProtection
            EnableSecretScanningAIDetection         = $EnableSecretScanningAIDetection
            EnableSecretScanningNonProviderPatterns = $EnableSecretScanningNonProviderPatterns
        }
        if ($PSCmdlet.ParameterSetName -like 'Fork*') {
            $updateParams['AllowForking'] = $AllowForking
        }
        Update-GitHubRepository @updateParams
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
