function Remove-GitHubVariableSelectedRepository {
    <#
        .SYNOPSIS
        Remove selected repository from an organization variable.

        .DESCRIPTION
        Removes a repository from an organization variable that is
        available to selected repositories. Organization variables that are available to
        selected repositories have their visibility field set to 'selected'.

        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the 'admin:org' scope to use this endpoint.
        If the repository is private, the 'repo' scope is also required.

        Fine-grained personal access tokens must have 'Variables' organization permissions (write) and
        'Metadata' repository permissions (read).

        .EXAMPLE
        Remove-GitHubVariableSelectedRepository -Owner 'my-org' -Name 'ENV_SECRET' -RepositoryID 123456

        Removes repository with ID 123456 from the organization variable 'ENV_SECRET' in 'my-org'.

        .OUTPUTS
        void

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/SelectedRepository/Remove-GitHubVariableSelectedRepository/

                https://psmodule.io/GitHub/Functions/Variables/SelectedRepository/Remove-GitHubVariableSelectedRepository

        .NOTES
        [Remove selected repository from an organization variable](https://docs.github.com/rest/actions/variables#remove-selected-repository-from-an-organization-variable)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long links'
    )]
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the variable.
        [Parameter(Mandatory)]
        [string] $Name,

        # The ID of the repository to remove to the variable.
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
        $repoIsNotSelected = $existingSelectedRepositories.ID -notcontains $RepositoryID
        if ($repoIsNotSelected) {
            Write-Debug 'Repo is not selected, returning'
            return
        }
        $inputObject = @{
            Method      = 'DELETE'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name/repositories/$RepositoryID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("access to variable [$Owner/$Name] for repository [$RepositoryID]", 'Remove')) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
