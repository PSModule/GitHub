function Add-GitHubSecretSelectedRepository {
    <#
        .SYNOPSIS
        Add selected repository to an organization secret.

        .DESCRIPTION
        Adds a repository to an organization secret when the `visibility` for repository access is set to `selected`. For more information about
        setting the visibility, see [Create or update an organization secret](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret).
        Authenticated users must have collaborator access to a repository to create, update, or read secrets.
        OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, OAuth tokens
        and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Add-GitHubSecretSelectedRepository -Owner 'my-org' -Name 'API_KEY' -RepositoryID '654321'

        Adds the repository 'test-repo' to the 'API_KEY' secret in the organization 'my-org'.

        .INPUTS
        [GitHubSecret]

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/SelectedRepository/Add-GitHubSecretSelectedRepository

        .NOTES
        [Add selected repository to an organization secret](https://docs.github.com/rest/actions/secrets#add-selected-repository-to-an-organization-secret)
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

        # The name of the secret.
        [Parameter(Mandatory)]
        [string] $Name,

        # The ID of the repository to add to the secret.
        [Parameter(,
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('DatabaseID', 'ID')]
        [UInt64] $RepositoryID,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $existingSelectedRepositories = Get-GitHubSecretSelectedRepository -Owner $Owner -Name $Name -Context $Context
        $repoIsSelected = $existingSelectedRepositories.ID -contains $RepositoryID
        if ($repoIsSelected) {
            Write-Debug 'Repo is already selected, returning'
            return
        }
        $inputObject = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$Owner/actions/secrets/$Name/repositories/$RepositoryID"
            Context     = $Context
        }

        $null = Invoke-GitHubAPI @inputObject
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
