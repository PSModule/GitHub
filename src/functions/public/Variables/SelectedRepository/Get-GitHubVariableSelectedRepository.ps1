function Get-GitHubVariableSelectedRepository {
    <#
        .SYNOPSIS
        List selected repositories for an organization variable.

        .DESCRIPTION
        Lists all repositories that can access an organization variable that is available to selected repositories.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private,
        the `repo` scope is also required.

        .EXAMPLE
        Get-GitHubVariableSelectedRepository -Owner 'PSModule' -Name 'SELECTEDVAR'

        .OUTPUTS
        GitHubRepository

        .NOTES
        Returns a list of GitHubRepository objects that represent the repositories that can access the variable.

        .LINK
        https://psmodule.io/GitHub/Functions/Variables/SelectedRepository/Get-GitHubVariableSelectedRepository

        .LINK
        [List selected repositories for an organization variable](https://docs.github.com/rest/actions/variables#list-selected-repositories-for-an-organization-variable)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long links'
    )]
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the variable.
        [Parameter(Mandatory)]
        [string] $Name,

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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name/repositories"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response.repositories | ForEach-Object {
                [GitHubRepository]@{
                    Name        = $_.name
                    FullName    = $_.full_name
                    NodeID      = $_.node_id
                    ID          = $_.id
                    Description = $_.description
                    Owner       = $_.owner.login
                    URL         = $_.html_url
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
