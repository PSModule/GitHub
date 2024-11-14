#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }

filter New-GitHubRepositoryOrg {
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
            HasDownloads             = $true
            IsTemplate               = $true
            AutoInit                 = $true
            AllowSquashMerge         = $true
            AllowAutoMerge           = $true
            DeleteBranchOnMerge      = $true
            SquashMergeCommitTitle   = 'PR_TITLE'
            SquashMergeCommitMessage = 'PR_BODY'
        }
        New-GitHubRepositoryOrg @params

        Creates a new public repository named "Hello-World" owned by the organization "PSModule".

        .PARAMETER GitignoreTemplate
        Desired language or platform .gitignore template to apply. Use the name of the template without the extension. For example, "Haskell".

        .PARAMETER LicenseTemplate
        Choose an open source license template that best suits your needs, and then use the license keyword as the license_template string.
        For example, "mit" or "mpl-2.0".

        .NOTES
        https://docs.github.com/rest/repos/repos#create-an-organization-repository

    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments',
        'GitignoreTemplate',
        Justification = 'Parameter is used in dynamic parameter validation.'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments',
        'LicenseTemplate',
        Justification = 'Parameter is used in dynamic parameter validation.'
    )]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

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

        # Either true to enable issues for this repository or false to disable them.
        [Parameter()]
        [Alias('has_issues')]
        [switch] $HasIssues,

        # Either true to enable projects for this repository or false to disable them.
        # Note: If you're creating a repository in an organization that has disabled repository projects, the default is false,
        # and if you pass true, the API returns an error.
        [Parameter()]
        [Alias('has_projects')]
        [switch] $HasProjects,

        # Either true to enable the wiki for this repository or false to disable it.
        [Parameter()]
        [Alias('has_wiki')]
        [switch] $HasWiki,

        # Whether downloads are enabled.
        [Parameter()]
        [Alias('has_downloads')]
        [switch] $HasDownloads,

        # Either true to make this repo available as a template repository or false to prevent it.
        [Parameter()]
        [Alias('is_template')]
        [switch] $IsTemplate,

        # The ID of the team that will be granted access to this repository. This is only valid when creating a repository in an organization.
        [Parameter()]
        [Alias('team_id')]
        [int] $TeamId,

        # Pass true to create an initial commit with empty README.
        [Parameter()]
        [Alias('auto_init')]
        [switch] $AutoInit,

        # Either true to allow squash-merging pull requests, or false to prevent squash-merging.
        [Parameter()]
        [Alias('allow_squash_merge')]
        [switch] $AllowSquashMerge,

        # Either true to allow merging pull requests with a merge commit, or false to prevent merging pull requests with merge commits.
        [Parameter()]
        [Alias('allow_merge_commit')]
        [switch] $AllowMergeCommit,

        # Either true to allow rebase-merging pull requests, or false to prevent rebase-merging.
        [Parameter()]
        [Alias('allow_rebase_merge')]
        [switch] $AllowRebaseMerge,

        # Either true to allow auto-merge on pull requests, or false to disallow auto-merge.
        [Parameter()]
        [Alias('allow_auto_merge')]
        [switch] $AllowAutoMerge,

        # Either true to allow automatically deleting head branches when pull requests are merged, or false to prevent automatic deletion.
        # The authenticated user must be an organization owner to set this property to true.
        [Parameter()]
        [Alias('delete_branch_on_merge')]
        [switch] $DeleteBranchOnMerge,

        # The default value for a squash merge commit title:
        #   - PR_TITLE - default to the pull request's title.
        #   - COMMIT_OR_PR_TITLE - default to the commit's title (if only one commit) or the pull request's title (when more than one commit).
        [Parameter()]
        [ValidateSet('PR_TITLE', 'COMMIT_OR_PR_TITLE')]
        [Alias('squash_merge_commit_title')]
        [string] $SquashMergeCommitTitle,

        # The default value for a squash merge commit message:
        #   - PR_BODY - default to the pull request's body.
        #   - COMMIT_MESSAGES - default to the branch's commit messages.
        #   - BLANK - default to a blank commit message.
        [Parameter()]
        [ValidateSet('PR_BODY', 'COMMIT_MESSAGES', 'BLANK')]
        [Alias('squash_merge_commit_message')]
        [string] $SquashMergeCommitMessage,

        # The default value for a merge commit title.
        #   - PR_TITLE - default to the pull request's title.
        #   - MERGE_MESSAGE - default to the classic title for a merge message (e.g.,Merge pull request #123 from branch-name).
        [Parameter()]
        [ValidateSet('PR_TITLE', 'MERGE_MESSAGE')]
        [Alias('merge_commit_title')]
        [string] $MergeCommitTitle,

        # The default value for a merge commit message.
        #   - PR_BODY - default to the pull request's body.
        #   - PR_TITLE - default to the pull request's title.
        #   - BLANK - default to a blank commit message.
        [Parameter()]
        [ValidateSet('PR_BODY', 'PR_TITLE', 'BLANK')]
        [Alias('merge_commit_message')]
        [string] $MergeCommitMessage
    )

    dynamicparam {
        $DynamicParamDictionary = New-DynamicParamDictionary

        $dynParam = @{
            Name                   = 'GitignoreTemplate'
            Alias                  = 'gitignore_template'
            Type                   = [string]
            ValidateSet            = Get-GitHubGitignoreList
            DynamicParamDictionary = $DynamicParamDictionary
        }
        New-DynamicParam @dynParam

        $dynParam2 = @{
            Name                   = 'LicenseTemplate'
            Alias                  = 'license_template'
            Type                   = [string]
            ValidateSet            = Get-GitHubLicenseList | Select-Object -ExpandProperty key
            DynamicParamDictionary = $DynamicParamDictionary
        }
        New-DynamicParam @dynParam2

        return $DynamicParamDictionary
    }

    begin {
        $GitignoreTemplate = $PSBoundParameters['GitignoreTemplate']
        $LicenseTemplate = $PSBoundParameters['LicenseTemplate']
    }

    process {
        $PSCmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
            $paramName = $_.Key
            $paramDefaultValue = Get-Variable -Name $paramName -ValueOnly -ErrorAction SilentlyContinue
            $providedValue = $PSBoundParameters[$paramName]
            Write-Verbose "[$paramName]"
            Write-Verbose "  - Default:  [$paramDefaultValue]"
            Write-Verbose "  - Provided: [$providedValue]"
            if (-not $PSBoundParameters.ContainsKey($paramName) -and ($null -ne $paramDefaultValue)) {
                Write-Verbose '  - Using default value'
                $PSBoundParameters[$paramName] = $paramDefaultValue
            } else {
                Write-Verbose '  - Using provided value'
            }
        }

        $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
        Remove-HashtableEntry -Hashtable $body -RemoveNames 'Owner' -RemoveTypes 'SwitchParameter'

        $body['private'] = $Visibility -eq 'private'
        $body['has_issues'] = if ($HasIssues.IsPresent) { $HasIssues } else { $false }
        $body['has_wiki'] = if ($HasWiki.IsPresent) { $HasWiki } else { $false }
        $body['has_projects'] = if ($HasProjects.IsPresent) { $HasProjects } else { $false }
        $body['has_downloads'] = if ($HasDownloads.IsPresent) { $HasDownloads } else { $false }
        $body['is_template'] = if ($IsTemplate.IsPresent) { $IsTemplate } else { $false }
        $body['auto_init'] = if ($AutoInit.IsPresent) { $AutoInit } else { $false }
        $body['allow_squash_merge'] = if ($AllowSquashMerge.IsPresent) { $AllowSquashMerge } else { $false }
        $body['allow_merge_commit'] = if ($AllowMergeCommit.IsPresent) { $AllowMergeCommit } else { $false }
        $body['allow_rebase_merge'] = if ($AllowRebaseMerge.IsPresent) { $AllowRebaseMerge } else { $false }
        $body['allow_auto_merge'] = if ($AllowAutoMerge.IsPresent) { $AllowAutoMerge } else { $false }
        $body['delete_branch_on_merge'] = if ($DeleteBranchOnMerge.IsPresent) { $DeleteBranchOnMerge } else { $false }

        Remove-HashtableEntry -Hashtable $body -NullOrEmptyValues

        $inputObject = @{
            APIEndpoint = "/orgs/$Owner/repos"
            Method      = 'POST'
            Body        = $body
        }

        if ($PSCmdlet.ShouldProcess("Repository in organization $Owner", 'Create')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }
}
