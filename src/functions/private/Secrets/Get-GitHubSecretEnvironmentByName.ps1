function Get-GitHubSecretEnvironmentByName {
    <#
        .SYNOPSIS
        Get an environment secret.

        .DESCRIPTION
        Gets a single environment secret without revealing its encrypted value. Authenticated users must have collaborator access to a repository to
        create, update, or read secrets. OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubSecretEnvironmentByName -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'SECRET1' -Context $GitHubContext

        Output:
        ```powershell
        Name                 : SECRET1
        Owner                : octocat
        Repository           : Hello-World
        Environment          : dev
        ```

        Retrieves the specified secret from the specified environment.

        .OUTPUTS
        GitHubSecret

        .NOTES
        Returns an GitHubSecret object containing details about the environment Secret,
        including its name, associated repository, and environment details.

        .NOTES
        [Get an environment secret](https://docs.github.com/rest/actions/secrets#get-an-environment-secret)
    #>
    [OutputType([GitHubSecret])]
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

        # The name of the Secret.
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
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Environment/secrets/$Name"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            [GitHubSecret]::new($_.Response, $Owner, $Repository, $Environment, $null)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
