function Get-GitHubSecretRepositoryByName {
    <#
        .SYNOPSIS
        Get a repository secret.

        .DESCRIPTION
        Gets a single repository secret without revealing its encrypted value. The authenticated user must have collaborator access to the repository
        to use this endpoint. OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubSecretRepositoryByName -Owner 'octocat' -Repository 'Hello-World' -Name 'SECRET1' -Context (Get-GitHubContext)

        Output:
        ```powershell
        Name                 : SECRET1
        Owner                : octocat
        Repository           : Hello-World
        Environment          :
        ```

        Retrieves the specified secret from the specified repository.

        .LINK
        [Get a repository secret](https://docs.github.com/rest/actions/secrets#get-a-repository-secret)
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

        # The name of the secret.
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
            APIEndpoint = "/repos/$Owner/$Repository/actions/secrets/$Name"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubSecret]::new($_.Response, $Owner, $Repository, $null)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
