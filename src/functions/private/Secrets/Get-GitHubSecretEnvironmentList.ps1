function Get-GitHubSecretEnvironmentList {
    <#
        .SYNOPSIS
        List environment secrets.

        .DESCRIPTION
        Lists all secrets available in an environment without revealing their encrypted values. Authenticated users must have collaborator access to a
        repository to create, update, or read secrets. OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this
        endpoint.

        .EXAMPLE
        ```pwsh
        Get-GitHubSecretEnvironmentList -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Context $GitHubContext
        ```

        Output:
        ```pwsh
        Name                 : SECRET1
        Owner                : octocat
        Repository           : Hello-World
        Environment          : dev

        Name                 : SECRET2
        Owner                : octocat
        Repository           : Hello-World
        Environment          : dev
        ```

        Retrieves all secrets for the specified environment.

        .OUTPUTS
        GitHubSecret[]

        .NOTES
        An array of GitHubSecret objects representing the environment secrets.
        Each object contains Name, CreatedAt, UpdatedAt, Owner, Repository, and Environment properties.

        .NOTES
        [List environment secrets](https://docs.github.com/rest/actions/secrets#list-environment-secrets)
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
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Environment/secrets"
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            $_.Response.secrets | ForEach-Object {
                [GitHubSecret]::new($_, $Owner, $Repository, $Environment, $null)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
