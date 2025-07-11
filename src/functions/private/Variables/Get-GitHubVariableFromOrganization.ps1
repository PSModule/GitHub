﻿function Get-GitHubVariableFromOrganization {
    <#
        .SYNOPSIS
        List repository organization variables.

        .DESCRIPTION
        Lists all organization variables shared with a repository.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubVariableFromOrganization -Owner 'PSModule' -Repository 'GitHub' -Context (Get-GitHubContext)

        Output:
        ```powershell
        Name                 : AVAILVAR
        Value                : ValueVar
        Owner                : PSModule
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:22 AM
        UpdatedAt            : 3/17/2025 10:56:22 AM
        Visibility           :
        SelectedRepositories :

        Name                 : SELECTEDVAR
        Value                : Varselected
        Owner                : PSModule
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:39 AM
        UpdatedAt            : 3/17/2025 10:56:39 AM
        Visibility           :
        SelectedRepositories :

        Name                 : TESTVAR
        Value                : VarTest
        Owner                : PSModule
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:05 AM
        UpdatedAt            : 3/17/2025 10:56:05 AM
        Visibility           :
        SelectedRepositories :
        ```

        Lists the variables visible from 'PSModule' to the 'GitHub' repository.

        .OUTPUTS
        GitHubVariable[]

        .NOTES
        An array of GitHubVariable objects representing the environment variables.
        Each object contains Name, Value, CreatedAt, UpdatedAt, Owner, Repository, and Environment properties.

        .NOTES
        [List repository organization variables](https://docs.github.com/rest/actions/variables#list-repository-organization-variables)
    #>
    [OutputType([GitHubVariable[]])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/organization-variables"
            PerPage     = $PerPage
            Context     = $Context
        }

        try {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                $_.Response.variables | ForEach-Object {
                    [GitHubVariable]::new($_, $Owner, $null, $null, $null)
                }
            }
        } catch {
            return $null
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
