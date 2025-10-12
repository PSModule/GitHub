function Set-GitHubVariableSelectedRepository {
    <#
        .SYNOPSIS
        Set selected repositories for an organization variable.

        .DESCRIPTION
        Sets which repositories has access to an organization variable.
        Organization variables that are available to selected repositories have their `visibility` field set to `selected`.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

        .EXAMPLE
        ```pwsh
        ```

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/SelectedRepository/Set-GitHubVariableSelectedRepository

        .NOTES
        [Set selected repositories for an organization variable](https://docs.github.com/rest/actions/variables#set-selected-repositories-for-an-organization-variable)

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/SelectedRepository/Set-GitHubVariableSelectedRepository
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long links'
    )]
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the variable.
        [Parameter(Mandatory)]
        [string] $Name,

        # The ID of the repository to set to the variable.
        [Parameter(Mandatory)]
        [UInt64[]] $RepositoryID,

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
        $body = @{
            selected_repository_ids = @($RepositoryID)
        }
        $apiParams = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name/repositories"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("access to variable [$Owner/$Name] for repository [$RepositoryID]", 'Set')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
