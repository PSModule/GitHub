function Remove-GitHubSecretFromOwner {
    <#
        .SYNOPSIS
        Delete an organization secret.

        .DESCRIPTION
        Deletes a secret in an organization using the secret name. Authenticated users must have collaborator access to a repository to create,
        update, or read secrets. OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository
        is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        ```powershell
        Remove-GitHubSecretFromOwner -Owner 'octocat' -Name 'HOST_NAME' -Context $GitHubContext
        ```

        Deletes the specified secret from the specified organization.

        .NOTES
        [Delete an organization secret](https://docs.github.com/rest/actions/secrets#delete-an-organization-secret)
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
            Method      = 'DELETE'
            APIEndpoint = "/orgs/$Owner/actions/secrets/$Name"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("secret [$Name] on [$Owner]", 'Delete')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
