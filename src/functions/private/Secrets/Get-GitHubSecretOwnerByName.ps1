function Get-GitHubSecretOwnerByName {
    <#
        .SYNOPSIS
        Create or update an organization secret.

        .DESCRIPTION
        Creates or updates an organization secret with an encrypted value. Encrypt your secret using
        [LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see
        "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."
        Authenticated users must have collaborator access to a repository to create, update, or read secrets. OAuth tokens and personal access tokens
        (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need
        the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubSecretOwnerByName -Owner 'octocat' -Name 'SECRET_THING' -Context (Get-GitHubContext)

        Output:
        ```powershell
        Name                 : SECRET_THING
        Owner                : octocat
        Repository           :
        Environment          :
        CreatedAt            : 3/17/2025 10:56:39 AM
        UpdatedAt            : 3/17/2025 10:56:39 AM
        Visibility           : selected
        SelectedRepositories : {hello-world, profile-repo}
        ```

        Retrieves the specified secret from the specified organization.

        .LINK
        [Create or update an organization secret](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret)
    #>
    [OutputType([GitHubSecret])]
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
            APIEndpoint = "/orgs/$Owner/actions/secrets/$Name"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response | ForEach-Object {
                $selectedRepositories = @()
                if ($_.visibility -eq 'selected') {
                    $selectedRepositories = Get-GitHubSecretSelectedRepository -Owner $Owner -Name $_.name -Context $Context
                }
                [GitHubSecret]@{
                    Name                 = $_.name
                    CreatedAt            = $_.created_at
                    UpdatedAt            = $_.updated_at
                    Scope                = 'Organization'
                    Owner                = $Owner
                    Visibility           = $_.visibility
                    SelectedRepositories = $selectedRepositories
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
