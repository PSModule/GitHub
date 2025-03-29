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
        Add-GitHubVariableSelectedRepository -Owner 'my-org' -Name 'API_KEY' -RepositoryID '654321' -Context $GitHubContext

        Output:
        ```powershell
        Name        : test-repo
        Id          : 654321
        FullName    : my-org/test-repo
        Private     : True
        ```

        Adds the repository 'test-repo' to the 'API_KEY' variable in the organization 'my-org'.

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/SelectedRepository/Add-GitHubVariableSelectedRepository

        .LINK
        [Add selected repository to an organization variable](https://docs.github.com/rest/actions/variables#add-selected-repository-to-an-organization-variable)
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
        [Parameter(Mandatory)]
        [string] $RepositoryID,

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
            repository_id = $RepositoryID
        }

        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name/repositories"
            Body        = $body
            Context     = $Context
        }

        $null = Invoke-GitHubAPI @inputObject
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
