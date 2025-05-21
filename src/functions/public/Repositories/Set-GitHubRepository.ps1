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

        Sets the repository `Hello-World` for the authenticated user if it does not exist,
        or updates it if it already exists. The repository uses GitHub's default settings.

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

        Sets a repository using splatting for the configuration.

        .OUTPUTS
        GitHubRepository

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Set-GitHubRepository/
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'user')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Set a repository in an organization')]
        [Parameter(ParameterSetName = 'Set a forked repository in an organization')]
        [Parameter(ParameterSetName = 'Set a repository from a template to an organization')]
        [Alias('Owner')]
        [string] $Organization,

        # The name of the repository.
        [Parameter(ParameterSetName = 'Set a forked repository in an organization')]
        [Parameter(ParameterSetName = 'Set a repository from a template to an organization')]
        [Parameter(ParameterSetName = 'Set a forked repository for a user')]
        [Parameter(ParameterSetName = 'Set a repository from a template to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Set a repository for the authenticated user')]
        [Parameter(Mandatory, ParameterSetName = 'Set a repository in an organization')]
        [string] $Name,

        # The account owner of the template repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Set a repository from a template to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Set a repository from a template to an organization')]
        [string] $TemplateOwner,

        # The name of the template repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Set a repository from a template to a user')]
        [Parameter(Mandatory, ParameterSetName = 'Set a repository from a template to an organization')]
        [string] $TemplateRepository,

        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Set a forked repository for a user')]
        [Parameter(Mandatory, ParameterSetName = 'Set a forked repository in an organization')]
        [string] $ForkOwner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Set a forked repository for a user')]
        [Parameter(Mandatory, ParameterSetName = 'Set a forked repository in an organization')]
        [string] $ForkRepository,

        # Include all branches from the source repository.
        [Parameter(ParameterSetName = 'Set a repository from a template to a user')]
        [Parameter(ParameterSetName = 'Set a repository from a template to an organization')]
        [Parameter(ParameterSetName = 'Set a forked repository for a user')]
        [Parameter(ParameterSetName = 'Set a forked repository in an organization')]
        [switch] $IncludeAllBranches,

        # Pass true to Set an initial commit with empty README.
        [Parameter(ParameterSetName = 'Set a repository for the authenticated user')]
        [Parameter(ParameterSetName = 'Set a repository in an organization')]
        [switch] $AddReadme,

        # The desired language or platform to apply to the .gitignore.
        [Parameter(ParameterSetName = 'Set a repository for the authenticated user')]
        [Parameter(ParameterSetName = 'Set a repository in an organization')]
        [string] $Gitignore,

        # The license keyword of the open source license for this repository.
        [Parameter(ParameterSetName = 'Set a repository for the authenticated user')]
        [Parameter(ParameterSetName = 'Set a repository in an organization')]
        [string] $License,

        # The visibility of the repository.
        [Parameter(ParameterSetName = 'Set a repository for the authenticated user')]
        [Parameter(ParameterSetName = 'Set a repository in an organization')]
        [Parameter(ParameterSetName = 'Set a repository from a template to an organization')]
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
        [Parameter(ParameterSetName = 'Set a forked repository in an organization')]
        [Parameter(ParameterSetName = 'Set a repository from a template to an organization')]
        [Parameter(ParameterSetName = 'Set a repository in an organization')]
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
        if (-not $Owner) {
            $Owner = $Context.Username
        }
        Write-Debug "Owner: [$Owner]"
    }

    process {
        $params = @{
            Owner   = $Organization
            Name    = $Name
            Context = $Context
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        $repo = Get-GitHubRepository @params

        $params += @{
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
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        if ($repo) {
            $params = @{
                Owner              = $Organization
                TemplateOwner      = $TemplateOwner
                TemplateRepository = $TemplateRepository
                ForkOwner          = $ForkOwner
                ForkRepository     = $ForkRepository
                IncludeAllBranches = $IncludeAllBranches
                AddReadme          = $AddReadme
                Gitignore          = $Gitignore
                License            = $License
            }
            Update-GitHubRepository @params
        } else {
            New-GitHubRepository @params
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
