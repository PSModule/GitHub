function Get-GitHubVariableEnvironmentList {
    <#
        .SYNOPSIS
        Retrieves all variables for a specified environment in a GitHub repository.

        .DESCRIPTION
        Lists all environment variables in a specified repository environment.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubVariableEnvironmentList -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Context $GitHubContext

        Output:
        ```powershell
        Name                 : NAME
        Value                : John Doe
        Owner                : octocat
        Repository           : Hello-World
        Environment          : dev

        Name                 : EMAIL
        Value                : John.Doe@example.com
        Owner                : octocat
        Repository           : Hello-World
        Environment          : dev
        ```

        Retrieves all variables for the specified environment.

        .OUTPUTS
        GitHubVariable[]

        .NOTES
        An array of GitHubVariable objects representing the environment variables.
        Each object contains Name, Value, CreatedAt, UpdatedAt, Owner, Repository, and Environment properties.

        .LINK
        [List environment variables](https://docs.github.com/rest/actions/variables#list-environment-variables)
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

        # The name of the environment.
        [Parameter(Mandatory)]
        [string] $Environment,

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
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Environment/variables"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response.variables | ForEach-Object {
                [GitHubVariable]::new($_, $Owner, $Repository, $Environment, $null)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
