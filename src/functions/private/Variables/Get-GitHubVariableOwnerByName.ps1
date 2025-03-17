function Get-GitHubVariableOwnerByName {
    <#
        .SYNOPSIS
        Get an organization variable.

        .DESCRIPTION
        Gets a specific variable in an organization.
        The authenticated user must have collaborator access to a repository to create, update, or read variables.
        OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private,
        OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubVariableOwnerByName -Owner 'PSModule' -Name 'SELECTEDVAR' -Context (Get-GitHubContext)

        Output:
        ```powershell
        Name                 : SELECTEDVAR
        Value                : Varselected
        Owner                : PSModule
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:39 AM
        UpdatedAt            : 3/17/2025 10:56:39 AM
        Visibility           : selected
        SelectedRepositories : {Build-PSModule, Test-PSModule}
        ```

        Retrieves the specified variable from the specified organization.

        .LINK
        [Get an organization variable](https://docs.github.com/rest/actions/variables#get-an-organization-variable)
    #>
    [OutputType([GitHubVariable])]
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
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response | ForEach-Object {
                $selectedRepositories = @()
                if ($_.visibility -eq 'selected') {
                    $selectedRepositories = Get-GitHubVariableVisibilityList -Owner $Owner -Name $_.name -Context $Context
                }
                [GitHubVariable]@{
                    Name                 = $_.name
                    Value                = $_.value
                    CreatedAt            = $_.created_at
                    UpdatedAt            = $_.updated_at
                    Owner                = $Owner
                    Visibility           = $_.visibility
                    SelectedRepositories = $selectedRepositories
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
