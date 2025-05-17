function Set-GitHubRepository {
    <#
        .SYNOPSIS
        Creates or updates a repository.

        .DESCRIPTION
        Checks if the specified repository exists. If it does, the repository is updated using
        the provided parameters. If it does not exist, a new repository is created with the
        provided parameters. The updated or newly created repository is returned.

        .EXAMPLE
        Set-GitHubRepository -Name 'Hello-World' -Description 'My repo'

        Creates the repository `Hello-World` for the authenticated user if it does not exist,
        or updates it if it already exists.

        .EXAMPLE
        $params = @{
            Owner                  = 'octocat'
            Name                   = 'Hello-World'
            AllowSquashMergingWith = 'Pull request title and description'
            HasIssues              = $true
            SuggestUpdateBranch    = $true
            AllowAutoMerge         = $true
            DeleteBranchOnMerge    = $true
        }
        Set-GitHubRepository @params

        Demonstrates using splatting to configure a repository.

        .OUTPUTS
        GitHubRepository

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Set-GitHubRepository/
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'user')]
    param(
        [Parameter(ParameterSetName = 'org')]
        [Parameter(ParameterSetName = 'fork')]
        [Parameter(ParameterSetName = 'template')]
        [Alias('Organization', 'User')]
        # The account owner of the repository. The name is not case sensitive.
        [string] $Owner,

        [Parameter(Mandatory, ParameterSetName = 'user')]
        [Parameter(Mandatory, ParameterSetName = 'org')]
        [Parameter(Mandatory, ParameterSetName = 'template')]
        [Parameter(Mandatory, ParameterSetName = 'fork')]
        # The name of the repository without the .git extension. The name is not case sensitive.
        [string] $Name,

        [Parameter(Mandatory, ParameterSetName = 'template')]
        # The account owner of the template repository. The name is not case sensitive.
        [string] $TemplateOwner,

        [Parameter(Mandatory, ParameterSetName = 'template')]
        # The name of the template repository without the .git extension. The name is not case sensitive.
        [string] $TemplateRepository,

        [Parameter(Mandatory, ParameterSetName = 'fork')]
        # The account owner of the source repository for the fork.
        [string] $ForkOwner,

        [Parameter(Mandatory, ParameterSetName = 'fork')]
        # The name of the source repository for the fork.
        [string] $ForkRepository,

        [Parameter(ParameterSetName = 'template')]
        [Parameter(ParameterSetName = 'fork')]
        # Include all branches from the source repository.
        [switch] $IncludeAllBranches,

        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        # Pass true to create an initial commit with empty README.
        [switch] $AddReadme,

        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        # The desired language or platform to apply to the .gitignore.
        [string] $Gitignore,

        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        # The license keyword of the open source license for this repository.
        [string] $License,

        [Parameter(ParameterSetName = 'user')]
        [Parameter(ParameterSetName = 'org')]
        [Parameter(ParameterSetName = 'template')]
        [ValidateSet('Public', 'Private', 'Internal')]
        # The visibility of the repository.
        [string] $Visibility = 'Public',

        [Parameter()]
        # The new name to be given to the repository.
        [string] $NewName,

        [Parameter()]
        # A short description of the repository.
        [string] $Description,

        [Parameter()]
        # A URL with more information about the repository.
        [uri] $Homepage,

        [Parameter()]
        # Whether the repository is archived.
        [bool] $IsArchived,

        [Parameter()]
        # Whether this repository acts as a template that can be used to generate new repositories.
        [bool] $IsTemplate,

        [Parameter()]
        # Whether to require contributors to sign off on web-based commits.
        [bool] $WebCommitSignoffRequired,

        [Parameter()]
        # Updates the default branch for this repository.
        [string] $DefaultBranch,

        [Parameter()]
        # Whether the wiki is enabled.
        [bool] $HasWiki,

        [Parameter()]
        # Whether issues are enabled.
        [bool] $HasIssues,

        [Parameter()]
        # Either true to allow forks, or false to prevent them.
        [bool] $AllowForking,

        [Parameter()]
        # Whether sponsorships are enabled.
        [bool] $HasSponsorships,

        [Parameter()]
        # Whether discussions are enabled.
        [bool] $HasDiscussions,

        [Parameter()]
        # Whether projects are enabled.
        [bool] $HasProjects,

        [Parameter()]
        [ValidateSet('', 'Default message', 'Pull request title', 'Pull request title and description')]
        # Allow merge commits for pull requests with the specified setting.
        [string] $AllowMergeCommitWith,

        [Parameter()]
        [ValidateSet('', 'Default message', 'Pull request title', 'Pull request title and description', 'Pull request title and commit details')]
        # Allow squash merges for pull requests with the specified setting.
        [string] $AllowSquashMergingWith,

        [Parameter()]
        # Whether to allow rebase merges for pull requests.
        [switch] $AllowRebaseMerging,

        [Parameter()]
        # Whether to suggest updating a pull request branch if it is behind.
        [bool] $SuggestUpdateBranch,

        [Parameter()]
        # Whether to allow Auto-merge to be used on pull requests.
        [bool] $AllowAutoMerge,

        [Parameter()]
        # Whether to delete head branches when pull requests are merged.
        [bool] $DeleteBranchOnMerge,

        [Parameter()]
        # Whether to enable GitHub Advanced Security for this repository.
        [bool] $EnableAdvancedSecurity,

        [Parameter()]
        # Whether to enable code security for this repository.
        [bool] $EnableCodeSecurity,

        [Parameter()]
        # Whether to enable secret scanning for this repository.
        [bool] $EnableSecretScanning,

        [Parameter()]
        # Whether to enable secret scanning push protection.
        [bool] $EnableSecretScanningPushProtection,

        [Parameter()]
        # Whether to enable secret scanning AI detection.
        [bool] $EnableSecretScanningAIDetection,

        [Parameter()]
        # Whether to enable secret scanning non-provider patterns.
        [bool] $EnableSecretScanningNonProviderPatterns,

        [Parameter()]
        # The context to run the command in. Can be either a string or a GitHubContext object.
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        if (-not $Owner) {
            $Owner = $Context.Username
        }
        Write-Debug "Owner: [$Owner]"
    }

    process {
        $scope = @{ Owner = $Owner; Name = $Name; Context = $Context }
        $repo = Get-GitHubRepository @scope

        $newParams = @{
            Organization                             = $Owner
            Name                                     = $Name
            TemplateOwner                            = $TemplateOwner
            TemplateRepository                       = $TemplateRepository
            ForkOwner                                = $ForkOwner
            ForkRepository                           = $ForkRepository
            IncludeAllBranches                       = $IncludeAllBranches
            AddReadme                                = $AddReadme
            Gitignore                                = $Gitignore
            License                                  = $License
            Visibility                               = $Visibility
            Description                              = $Description
            Homepage                                 = $Homepage
            IsArchived                               = $IsArchived
            IsTemplate                               = $IsTemplate
            WebCommitSignoffRequired                 = $WebCommitSignoffRequired
            DefaultBranch                            = $DefaultBranch
            HasWiki                                  = $HasWiki
            HasIssues                                = $HasIssues
            AllowForking                             = $AllowForking
            HasSponsorships                          = $HasSponsorships
            HasDiscussions                           = $HasDiscussions
            HasProjects                              = $HasProjects
            AllowMergeCommitWith                     = $AllowMergeCommitWith
            AllowSquashMergingWith                   = $AllowSquashMergingWith
            AllowRebaseMerging                       = $AllowRebaseMerging
            SuggestUpdateBranch                      = $SuggestUpdateBranch
            AllowAutoMerge                           = $AllowAutoMerge
            DeleteBranchOnMerge                      = $DeleteBranchOnMerge
            EnableAdvancedSecurity                   = $EnableAdvancedSecurity
            EnableCodeSecurity                       = $EnableCodeSecurity
            EnableSecretScanning                     = $EnableSecretScanning
            EnableSecretScanningPushProtection       = $EnableSecretScanningPushProtection
            EnableSecretScanningAIDetection          = $EnableSecretScanningAIDetection
            EnableSecretScanningNonProviderPatterns  = $EnableSecretScanningNonProviderPatterns
            Context                                  = $Context
        }
        $newParams | Remove-HashtableEntry -NullOrEmptyValues

        $updateParams = @{
            Owner                                   = $Owner
            Name                                    = $Name
            NewName                                 = $NewName
            Visibility                              = $Visibility
            Description                             = $Description
            Homepage                                = $Homepage
            IsArchived                              = $IsArchived
            IsTemplate                              = $IsTemplate
            WebCommitSignoffRequired                = $WebCommitSignoffRequired
            DefaultBranch                           = $DefaultBranch
            HasWiki                                 = $HasWiki
            HasIssues                               = $HasIssues
            AllowForking                            = $AllowForking
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
            Declare                                 = $true
            Context                                 = $Context
        }
        $updateParams | Remove-HashtableEntry -NullOrEmptyValues

        if ($repo) {
            Update-GitHubRepository @updateParams
        }
        else {
            New-GitHubRepository @newParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
