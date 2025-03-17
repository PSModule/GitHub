function Get-GitHubVariableVisibilityList {
    <#
        .SYNOPSIS
        List selected repositories for an organization variable.

        .DESCRIPTION
        Lists all repositories that can access an organization variable that is available to selected repositories.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private,
        the `repo` scope is also required.

        .EXAMPLE
        Get-GitHubVariableVisibilityList -Owner 'PSModule' -Name 'SELECTEDVAR' -Context (Get-GitHubContext)

        .LINK
        [List selected repositories for an organization variable](https://docs.github.com/rest/actions/variables#list-selected-repositories-for-an-organization-variable)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long links'
    )]
    [OutputType([pscustomobject])]
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
        [object] $Context,

        [Parameter()]
        [ValidateSet('json', 'pscustomobject', 'class', 'raw')]
        [string] $Output = 'class'
    )

    begin {
        # $stackPath = Get-PSCallStackPath
        # Write-Debug "[$stackPath] - Start"
        # Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Owner/actions/variables/$Name/repositories"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $apiReturn = $_
            $repositories = $apiReturn.Response.repositories
            switch ($Output) {
                'raw' {
                    $apiReturn
                    break
                }
                'json' {
                    $repositories | ConvertTo-Json -Depth 5
                    break
                }
                'pscustomobject' {
                    $repositories
                    break
                }
                'class' {
                    $repositories | ForEach-Object {
                        [GitHubRepository]@{
                            Name        = $_.name
                            FullName    = $_.full_name
                            NodeID      = $_.node_id
                            DatabaseID  = $_.id
                            Description = $_.description
                            Owner       = $_.owner.login
                            URL         = $_.html_url
                        }
                    }
                    break
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
