function Remove-GitHubSecretFromRepository {
    <#
        .SYNOPSIS
        Delete a repository secret.

        .DESCRIPTION
        Deletes a secret in a repository using the secret name. Authenticated users must have collaborator access to a repository to create, update,
        or read secrets. OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Remove-GitHubSecretFromRepository -Owner 'octocat' -Repository 'Hello-World' -Name 'SECRET1' -Context $GitHubContext

        Deletes the specified secret from the specified repository.

        .LINK
        [Delete a repository secret](https://docs.github.com/rest/actions/secrets#delete-a-repository-secret)
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
            Method      = 'DELETE'
            APIEndpoint = "/repos/$Owner/$Repository/actions/secrets/$Name"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("secret [$Name] on [$Owner/$Repository]", 'Delete')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
