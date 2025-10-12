function Get-GitHubSecretFromOrganization {
    <#
        .SYNOPSIS
        List repository organization secrets.

        .DESCRIPTION
        Lists all organization secrets shared with a repository without revealing their encrypted values. Authenticated users must have collaborator
        access to a repository to create, update, or read secrets. OAuth app tokens and personal access tokens (classic) need the `repo` scope to use
        this endpoint.

        .EXAMPLE
        ```powershell
        Get-GitHubSecretFromOrganization -Owner 'octocat' -Repository 'helloworld' -Context (Get-GitHubContext)
        ```

        Output:
        ```powershell
        Name                 : SECRET1
        Owner                : octocat
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:22 AM
        UpdatedAt            : 3/17/2025 10:56:22 AM
        Visibility           :
        SelectedRepositories :

        Name                 : SECRET2
        Owner                : octocat
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:39 AM
        UpdatedAt            : 3/17/2025 10:56:39 AM
        Visibility           :
        SelectedRepositories :

        Name                 : TESTSECRET
        Owner                : octocat
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:05 AM
        UpdatedAt            : 3/17/2025 10:56:05 AM
        Visibility           :
        SelectedRepositories :
        ```

        Lists the secrets visible from 'octocat' to the 'helloworld' repository.

        .OUTPUTS
        GitHubSecret[]

        .NOTES
        An array of GitHubSecret objects representing the environment secrets.
        Each object contains Name, CreatedAt, UpdatedAt, Owner, Repository, and Environment properties.

        .NOTES
        [List repository organization secrets](https://docs.github.com/rest/actions/secrets#list-repository-organization-secrets)
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

        # The number of results per page (max 100).
        [Parameter()]
        [System.Nullable[int]] $PerPage,

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
            APIEndpoint = "/repos/$Owner/$Repository/actions/organization-secrets"
            PerPage     = $PerPage
            Context     = $Context
        }

        try {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                $_.Response.secrets | ForEach-Object {
                    [GitHubSecret]::new($_, $Owner, $null, $null, $null)
                }
            }
        } catch {
            return $null
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
