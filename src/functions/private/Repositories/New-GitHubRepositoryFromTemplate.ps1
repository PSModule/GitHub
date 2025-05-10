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
            TemplateRepository = 'octocat'
            Owner              = 'PSModule'
            Name               = 'MyNewRepo'
            IncludeAllBranches = $true
            Description        = 'My new repo'
            Private            = $true
        }
        New-GitHubRepositoryFromTemplate @params

        Creates a new private repository named `MyNewRepo` from the `octocat` template repository owned by `GitHub`.

        .OUTPUTS
        GitHubRepository

        .LINK
        [Create a repository using a template](https://docs.github.com/rest/repos/repos#create-a-repository-using-a-template)
    #>
    [OutputType([GitHubRepository])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the template repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $TemplateOwner,

        # The name of the template repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $TemplateRepository,

        # The organization or person who will own the new repository.
        # To create a new repository in an organization, the authenticated user must be a member of the specified organization.
        [Parameter()]
        [string] $Owner,

        # The name of the new repository.
        [Parameter(Mandatory)]
        [string] $Name,

        # A short description of the new repository.
        [Parameter()]
        [string] $Description,

        # Include all branches from the source repository.
        [Parameter()]
        [switch] $IncludeAllBranches,

        # The visibility of the repository.
        [Parameter()]
        [ValidateSet('public', 'private')]
        [string] $Visibility = 'public',

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            owner                = $Owner
            name                 = $Name
            description          = $Description
            include_all_branches = [bool]$IncludeAllBranches
            private              = $Visibility -eq 'private'
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = "/repos/$TemplateOwner/$TemplateRepository/generate"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Repository [$Owner/$Name] from template [$TemplateOwner/$TemplateRepository]", 'Create')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubRepository]::New($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
