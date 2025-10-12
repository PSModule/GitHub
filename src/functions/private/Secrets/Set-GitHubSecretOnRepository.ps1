function Set-GitHubSecretOnRepository {
    <#
        .SYNOPSIS
        Create or update a repository secret.

        .DESCRIPTION
        Creates or updates a repository secret with an encrypted value. Encrypt your secret using
        [LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see
        "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."
        Authenticated users must have collaborator access to a repository to create, update, or read secrets.
        OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        ```powershell
        Set-GitHubSecretOnRepository -Owner 'octocat' -Repository 'Hello-World' -Name 'SECRET1' -Value 'SECRET_VALUE' -Context $GitHubContext
        ```

        Creates a new repository secret named `SECRET1` with the value `SECRET_VALUE` in the specified repository.

        .NOTES
        [Create or update a repository secret](https://docs.github.com/rest/actions/secrets#create-or-update-a-repository-secret)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The name of the secret.
        [Parameter(Mandatory)]
        [string] $Name,

        # The encrypted value of the secret.
        [Parameter(Mandatory)]
        [string] $Value,

        # ID of the key you used to encrypt the secret.
        [Parameter(Mandatory)]
        [string] $KeyID,

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
        $body = @{
            encrypted_value = $Value
            key_id          = $KeyID
        }

        $apiParams = @{
            Method      = 'PUT'
            APIEndpoint = "/repos/$Owner/$Repository/actions/secrets/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("secret [$Name] on [$Owner/$Repository]", 'Set')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
