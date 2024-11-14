﻿#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }

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
            HasDownloads             = $true
            IsTemplate               = $true
            AutoInit                 = $true
            AllowSquashMerge         = $true
            AllowAutoMerge           = $true
            DeleteBranchOnMerge      = $true
            SquashMergeCommitTitle   = 'PR_TITLE'
            SquashMergeCommitMessage = 'PR_BODY'
        }
        New-GitHubRepositoryUser @params

        Creates a new public repository named "Hello-World" owned by the authenticated user.

        .PARAMETER GitignoreTemplate
        The desired language or platform to apply to the .gitignore.

        .PARAMETER LicenseTemplate
        The license keyword of the open source license for this repository.

        .NOTES
        https://docs.github.com/rest/repos/repos#create-a-repository-for-the-authenticated-user

    #>
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
        [Alias('has_issues')]
        [switch] $HasIssues,

        # Whether projects are enabled.
        [Parameter()]
        [Alias('has_projects')]
        [switch] $HasProjects,

        # Whether the wiki is enabled.
        [Parameter()]
        [Alias('has_wiki')]
        [switch] $HasWiki,

        # Whether discussions are enabled.
        [Parameter()]
        [Alias('has_discussions')]
        [switch] $HasDiscussions,

        # Whether downloads are enabled.
        [Parameter()]
        [Alias('has_downloads')]
        [switch] $HasDownloads,

        # Whether this repository acts as a template that can be used to generate new repositories.
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

        # Whether to allow squash merges for pull requests.
        [Parameter()]
        [Alias('allow_squash_merge')]
        [switch] $AllowSquashMerge,

        # Whether to allow merge commits for pull requests.
        [Parameter()]
        [Alias('allow_merge_commit')]
        [switch] $AllowMergeCommit,

        # Whether to allow rebase merges for pull requests.
        [Parameter()]
        [Alias('allow_rebase_merge')]
        [switch] $AllowRebaseMerge,

        # Whether to allow Auto-merge to be used on pull requests.
        [Parameter()]
        [Alias('allow_auto_merge')]
        [switch] $AllowAutoMerge,

        # Whether to delete head branches when pull requests are merged
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
        Remove-HashtableEntry -Hashtable $body -RemoveNames 'visibility' -RemoveTypes 'SwitchParameter'

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
            APIEndpoint = '/user/repos'
            Method      = 'POST'
            Body        = $body
        }

        if ($PSCmdlet.ShouldProcess('Repository for user', 'Create')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }
}
