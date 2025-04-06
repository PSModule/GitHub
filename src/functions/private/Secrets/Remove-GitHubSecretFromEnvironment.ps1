function Remove-GitHubSecretFromEnvironment {
    <#
        .SYNOPSIS
        Delete an environment secret.

        .DESCRIPTION
        Deletes a secret in an environment using the secret name. Authenticated users must have collaborator access to a repository to create, update,
        or read secrets. OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Remove-GitHubSecretFromEnvironment -Owner 'octocat' -Repository 'Hello-World' -Environment 'dev' -Name 'SECRET1' -Context $GitHubContext

        Deletes the specified secret from the specified environment.

        .LINK
        [Delete an environment secret](https://docs.github.com/rest/actions/secrets#delete-an-environment-secret)
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

        # The name of the repository environment.
        [Parameter(Mandatory)]
        [string] $Environment,

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
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Environment/secrets/$Name"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("secret [$Name] on [$Owner/$Repository/$Environment]", 'Delete')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
