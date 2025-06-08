function Get-GitHubSecretSelectedRepository {
    <#
        .SYNOPSIS
        List selected repositories for an organization secret.

        .DESCRIPTION
        Lists all repositories that have been selected when the `visibility`for repository access to a secret is set to `selected`. Authenticated
        users must have collaborator access to a repository to create, update, or read secrets. OAuth app tokens and personal access tokens (classic)
        need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

        .EXAMPLE
        Get-GitHubSecretSelectedRepository -Owner 'octocat' -Name 'hello-world'

        Outputs:
        ```powershell
        Name        : hello-world
        NodeID      : m_MDXNcwMAwMMA
        ID          : 123456789
        Description : A test repo for hello-world.
        Owner       : octocat
        Url         : https://github.com/octocat/hello-world
        CreatedAt   :
        UpdatedAt   :

        Name        : hello-world2
        NodeID      : n_NEYOdxNBxNNB
        ID          : 987654321
        Description : A test repo for hello-world.
        Owner       : octocat
        Url         : https://github.com/octocat/hello-world2
        CreatedAt   :
        UpdatedAt   :
        ```

        Gets the repositories that have been selected for the secret `hello-world` in the organization `octocat`.

        .OUTPUTS
        GitHubRepository

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/SelectedRepository/Get-GitHubSecretSelectedRepository

        .NOTES
        [List selected repositories for an organization secret](https://docs.github.com/rest/actions/Secrets#list-selected-repositories-for-an-organization-Secret)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long links'
    )]
    [OutputType([GitHubRepository])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the secret.
        [Parameter(Mandatory)]
        [string] $Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Owner/actions/secrets/$Name/repositories"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response.repositories | ForEach-Object {
                [GitHubRepository]::New($_)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
