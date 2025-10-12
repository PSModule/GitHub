function Get-GitHubVariableRepositoryByName {
    <#
        .SYNOPSIS
        Get a repository variable

        .DESCRIPTION
        Gets a specific variable in a repository.
        The authenticated user must have collaborator access to the repository to use this endpoint.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        ```pwsh
        Get-GitHubVariableRepositoryByName -Owner 'PSModule' -Repository 'Hello-World' -Name 'EMAIL' -Context (Get-GitHubContext)
        ```

        Output:
        ```pwsh
        Name                 : EMAIL
        Value                : John.Doe@example.com
        Owner                : octocat
        Repository           : Hello-World
        Environment          :
        ```

        Retrieves the specified variable from the specified repository.

        .NOTES
        [Get a repository variable](https://docs.github.com/rest/actions/variables#get-a-repository-variable)
    #>
    [OutputType([GitHubVariable])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/actions/variables/$Name"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubVariable]::new($_.Response, $Owner, $Repository, $null, $null)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
