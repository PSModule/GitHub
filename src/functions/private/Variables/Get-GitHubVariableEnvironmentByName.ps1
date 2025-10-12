function Get-GitHubVariableEnvironmentByName {
    <#
        .SYNOPSIS
        Retrieves a specific variable from a GitHub repository.

        .DESCRIPTION
        Gets a specific variable in an environment of a repository on GitHub.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        ```pwsh
        Get-GitHubVariableEnvironmentByName -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'NAME' -Context $GitHubContext
        ```

        Output:
        ```pwsh
        Name                 : NAME
        Value                : John Doe
        Owner                : octocat
        Repository           : Hello-World
        Environment          : dev
        ```

        Retrieves the specified variable from the specified environment.

        .OUTPUTS
        GitHubVariable

        .NOTES
        Returns an GitHubVariable object containing details about the environment variable,
        including its name, value, associated repository, and environment details.

        .NOTES
        [Get an environment variable](https://docs.github.com/rest/actions/variables#get-an-environment-variable)
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

        # The name of the environment.
        [Parameter(Mandatory)]
        [string] $Environment,

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
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Environment/variables/$Name"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubVariable]::new($_.Response, $Owner, $Repository, $Environment, $null)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
