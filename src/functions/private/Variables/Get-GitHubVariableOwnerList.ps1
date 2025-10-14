function Get-GitHubVariableOwnerList {
    <#
        .SYNOPSIS
        List organization variables

        .DESCRIPTION
        Lists all organization variables.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private,
        the `repo` scope is also required.

        .EXAMPLE
        ```powershell
        Get-GitHubVariableOwnerList -Owner 'PSModule' -Context (Get-GitHubContext)
        ```

        Output:
        ```powershell
        Name                 : AVAILVAR
        Value                : ValueVar
        Owner                : PSModule
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:22 AM
        UpdatedAt            : 3/17/2025 10:56:22 AM
        Visibility           : all
        SelectedRepositories : {}

        Name                 : SELECTEDVAR
        Value                : Varselected
        Owner                : PSModule
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:39 AM
        UpdatedAt            : 3/17/2025 10:56:39 AM
        Visibility           : selected
        SelectedRepositories : {Build-PSModule, Test-PSModule}

        Name                 : TESTVAR
        Value                : VarTest
        Owner                : PSModule
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:05 AM
        UpdatedAt            : 3/17/2025 10:56:05 AM
        Visibility           : private
        SelectedRepositories : {}
        ```

        Retrieves all variables from the specified organization.

        .OUTPUTS
        GitHubVariable[]

        .NOTES
        An array of GitHubVariable objects representing the environment variables.
        Each object contains Name, Value, CreatedAt, UpdatedAt, Owner, Repository, and Environment properties.

        .NOTES
        [List organization variables](https://docs.github.com/rest/actions/variables#list-organization-variables)
    #>
    [OutputType([GitHubVariable[]])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

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
            APIEndpoint = "/orgs/$Owner/actions/variables"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            $_.Response.variables | ForEach-Object {
                $selectedRepositories = @()
                if ($_.visibility -eq 'selected') {
                    $selectedRepositories = Get-GitHubVariableSelectedRepository -Owner $Owner -Name $_.name -Context $Context
                }
                [GitHubVariable]::new($_, $Owner, $Repository, $Environment, $selectedRepositories)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
