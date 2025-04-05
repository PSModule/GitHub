function Remove-GitHubSecretSelectedRepository {
    <#
        .SYNOPSIS
        Remove selected repository from an organization secret.

        .DESCRIPTION
        Removes a repository from an organization secret when the `visibility` for repository access is set to `selected`. The visibility is set when
        you [Create or update an organization secret](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret).
        Authenticated users must have collaborator access to a repository to create, update, or read secrets. OAuth app tokens and personal access
        tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

        .EXAMPLE
        Remove-GitHubSecretSelectedRepository -Owner 'my-org' -Name 'ENV_SECRET' -RepositoryID 123456

        Removes repository with ID 123456 from the organization variable 'ENV_SECRET' in 'my-org'.

        .OUTPUTS
        void

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/SelectedRepository/Remove-GitHubSecretSelectedRepository

        .LINK
        [Remove selected repository from an organization secret](https://docs.github.com/rest/actions/secrets#remove-selected-repository-from-an-organization-secret)
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
        $existingSelectedRepositories = Get-GitHubSecretSelectedRepository -Owner $Owner -Name $Name -Context $Context
        $repoIsNotSelected = $existingSelectedRepositories.DatabaseID -notcontains $RepositoryID
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
