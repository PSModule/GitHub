function Get-GitHubPublicKeyForActionOnEnvironment {
    <#
        .SYNOPSIS
        Get an environment public key.

        .DESCRIPTION
        Get the public key for an environment, which you need to encrypt environment secrets. You need to encrypt a secret before you can create or
        update secrets. Anyone with read access to the repository can use this endpoint. If the repository is private, OAuth tokens and personal
        access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubPublicKeyForActionOnEnvironment -Owner 'octocat' -Repository 'hello-world' -Environment 'prod' -Context $GitHubContext

        Outputs:
        ```powershell
        ID          : 3380204578043523366
        Key         : ypK8XbFOtcXsCaqJOfdWjpCNumPmF3sfAbbv7x+3uSE=                    #gitleaks:allow
        Type        : actions
        Owner       : octocat
        Repository  : hello-world
        Environment : prod
        ```

        Gets the public key for the 'prod' environment in the 'octocat/hello-world' repository using the provided GitHub context.

        .OUTPUTS
        GitHubPublicKey

        .NOTES
        [Get an environment public key](https://docs.github.com/rest/actions/secrets#get-an-environment-public-key)
    #>
    [OutputType([GitHubPublicKey])]
    [CmdletBinding()]
    param (
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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Environment/secrets/public-key"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubPublicKey]::new($_.Response, 'actions', $Owner, $Repository, $Environment)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
