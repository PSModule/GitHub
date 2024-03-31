filter New-GitHubRepositoryFromTemplate {
    <#
        .SYNOPSIS
        Create a repository using a template

        .DESCRIPTION
        Creates a new repository using a repository template. Use the `template_owner` and `template_repo`
        route parameters to specify the repository to use as the template. If the repository is not public,
        the authenticated user must own or be a member of an organization that owns the repository.
        To check if a repository is available to use as a template, get the repository's information using the
        [Get a repository](https://docs.github.com/rest/repos/repos#get-a-repository) endpoint and check that the `is_template` key is `true`.

        **OAuth scope requirements**

        When using [OAuth](https://docs.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:

        * `public_repo` scope or `repo` scope to create a public repository. Note: For GitHub AE, use `repo` scope to create an internal repository.
        * `repo` scope to create a private repository

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
        New-GitHubRepositoryFromTemplate @params

        Creates a new private repository named `MyNewRepo` from the `octocat` template repository owned by `GitHub`.

        .NOTES
        https://docs.github.com/rest/repos/repos#create-a-repository-using-a-template

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The account owner of the template repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('template_owner')]
        [string] $TemplateOwner,

        # The name of the template repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('template_repo')]
        [string] $TemplateRepo,

        # The organization or person who will own the new repository.
        # To create a new repository in an organization, the authenticated user must be a member of the specified organization.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the new repository.
        [Parameter(Mandatory)]
        [string] $Name,

        # A short description of the new repository.
        [Parameter()]
        [string] $Description,

        # Set to true to include the directory structure and files from all branches in the template repository,
        # and not just the default branch.
        [Parameter()]
        [Alias('include_all_branches')]
        [switch] $IncludeAllBranches,

        # Either true to create a new private repository or false to create a new public one.
        [Parameter()]
        [switch] $Private
    )

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
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'TemplateOwner', 'TemplateRepo' -RemoveTypes 'SwitchParameter'

    $inputObject = @{
        APIEndpoint = "/repos/$TemplateOwner/$TemplateRepo/generate"
        Method      = 'POST'
        Body        = $body
    }

    if ($PSCmdlet.ShouldProcess("Repository [$Owner/$Name] from template [$TemplateOwner/$TemplateRepo]", 'Create')) {
        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
}
