function Get-GitHubVariableRepositoryList {
    <#
        .SYNOPSIS
        List repository variables.

        .DESCRIPTION
        Lists all repository variables.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        ```powershell
        Get-GitHubVariableRepositoryList -Owner 'PSModule' -Repository 'Hello-World' -Context (Get-GitHubContext)
        ```

        Output:
        ```powershell
        Name                 : NAME
        Value                : John Doe
        Owner                : octocat
        Repository           : Hello-World
        Environment          :

        Name                 : EMAIL
        Value                : John.Doe@example.com
        Owner                : octocat
        Repository           : Hello-World
        Environment          :
        ```

        Retrieves all variables for the specified repository.

        .OUTPUTS
        GitHubVariable[]

        .NOTES
        An array of GitHubVariable objects representing the environment variables.
        Each object contains Name, Value, CreatedAt, UpdatedAt, Owner, Repository, and Environment properties.

        .NOTES
        [List repository variables](https://docs.github.com/rest/actions/variables#list-repository-variables)
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
            APIEndpoint = "/repos/$Owner/$Repository/actions/variables"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            $_.Response.variables | ForEach-Object {
                [GitHubVariable]::new($_, $Owner, $Repository, $null, $null)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
