function Get-GitHubSecretRepositoryList {
    <#
        .SYNOPSIS
        List repository secrets.

        .DESCRIPTION
        Lists all secrets available in a repository without revealing their encrypted values. Authenticated users must have collaborator access to a
        repository to create, update, or read secrets. OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this
        endpoint.

        .EXAMPLE
        ```pwsh
        Get-GitHubSecretRepositoryList -Owner 'octocat' -Repository 'Hello-World' -Context (Get-GitHubContext)
        ```

        Output:
        ```pwsh
        Name                 : SECRET1
        Owner                : octocat
        Repository           : Hello-World
        Environment          :

        Name                 : SECRET2
        Owner                : octocat
        Repository           : Hello-World
        Environment          :
        ```

        Retrieves all secrets for the specified repository.

        .OUTPUTS
        GitHubSecret[]

        .NOTES
        An array of GitHubSecret objects representing the environment secrets.
        Each object contains Name, CreatedAt, UpdatedAt, Owner, Repository, and Environment properties.

        .NOTES
        [List repository secrets](https://docs.github.com/rest/actions/secrets#list-repository-secrets)
    #>
    [OutputType([GitHubSecret[]])]
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
            APIEndpoint = "/repos/$Owner/$Repository/actions/secrets"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            $_.Response.secrets | ForEach-Object {
                [GitHubSecret]::new($_, $Owner, $Repository, $null, $null)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
