function Set-GitHubSecretOnOwner {
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
        Set-GitHubSecretOnOwner -Owner 'octocat' -Name 'HOST_NAME' -Value 'test_value' -Context $GitHubContext

        Creates a new organization secret named `HOST_NAME` with the value `test_value` in the specified organization.

        .NOTES
        [Create or update an organization secret](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the secret.
        [Parameter(Mandatory)]
        [string] $Name,

        # The encrypted value of the secret.
        [Parameter(Mandatory)]
        [string] $Value,

        # ID of the key you used to encrypt the secret.
        [Parameter(Mandatory)]
        [string] $KeyID,

        # The visibility of the secret. Can be `private`, `selected`, or `all`.
        # `private` - The secret is only available to the organization.
        # `selected` - The secret is available to selected repositories.
        # `all` - The secret is available to all repositories in the organization.
        [Parameter()]
        [ValidateSet('private', 'selected', 'all')]
        [string] $Visibility = 'private',

        # The IDs of the repositories to which the secret is available.
        # This parameter is only used when the `-Visibility` parameter is set to `selected`.
        # The IDs can be obtained from the `Get-GitHubRepository` function.
        [Parameter()]
        [UInt64[]] $SelectedRepositories,

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
            visibility      = $Visibility
        }

        if ($Visibility -eq 'selected') {
            if (-not $SelectedRepositories) {
                throw 'You must specify the -SelectedRepositories parameter when using the -Visibility selected switch.'
            }
            $body['selected_repository_ids'] = $SelectedRepositories
        }

        $apiParams = @{
            Method      = 'PUT'
            APIEndpoint = "/orgs/$Owner/actions/secrets/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("secret [$Name] on [$Owner]", 'Set')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
