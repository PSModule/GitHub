function Add-GitHubVariableSelectedRepository {
    <#
        .SYNOPSIS
        Add selected repository to an organization variable.

        .DESCRIPTION
        Adds a repository to an organization variable that is available to selected repositories.
        Organization variables that are available to selected repositories have their visibility field set to 'selected'.
        Authenticated users must have collaborator access to the repository to create, update, or read secrets.
        OAuth and classic personal access tokens require the 'admin:org' scope. For private repositories, the 'repo' scope is also required.
        Fine-grained tokens must have 'Variables' organization permission (write) and 'Metadata' repository permission (read).

        .EXAMPLE
        Add-GitHubVariableSelectedRepository -Owner 'my-org' -Name 'API_KEY' -RepositoryID '654321'

        Adds the repository 'test-repo' to the 'API_KEY' variable in the organization 'my-org'.

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/SelectedRepository/Add-GitHubVariableSelectedRepository

        .NOTES
        [Add selected repository to an organization variable](https://docs.github.com/rest/actions/variables#add-selected-repository-to-an-organization-variable)

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/SelectedRepository/Add-GitHubVariableSelectedRepository
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long links'
    )]
    [OutputType([void])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the variable.
        [Parameter(Mandatory)]
        [string] $Name,

        # The ID of the repository to add to the variable.
        [Parameter(,
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('DatabaseID', 'ID')]
        [UInt64] $RepositoryID,

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
        $existingSelectedRepositories = Get-GitHubVariableSelectedRepository -Owner $Owner -Name $Name -Context $Context
        $repoIsSelected = $existingSelectedRepositories.ID -contains $RepositoryID
        if ($repoIsSelected) {
            Write-Debug 'Repo is already selected, returning'
            return
        }
        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name/repositories/$RepositoryID"
            Context     = $Context
        }

        $null = Invoke-GitHubAPI @inputObject
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
