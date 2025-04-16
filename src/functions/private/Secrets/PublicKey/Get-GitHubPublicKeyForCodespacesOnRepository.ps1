function Get-GitHubPublicKeyForCodespacesOnRepository {
    <#
        .SYNOPSIS
        Get a repository public key.

        .DESCRIPTION
        Gets your public key, which you need to encrypt secrets. You need to encrypt a secret before you can create or update secrets. If the
        repository is private, OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubPublicKeyForCodespacesOnRepository -Owner 'octocat' -Repository 'hello-world' -Context $GitHubContext

        Outputs:
        ```powershell
        ID          : 3380189982652154440
        Key         : xPliIrAsVlPub63sB1cnvx/CKt5FGb5rjlbF7uHC+hM=                    #gitleaks:allow
        Type        : codespaces
        Owner       : octocat
        Repository  : hello-world
        Environment :
        ```

        Gets the public key for the 'hellow-world' repository in the 'octocat' organization using the provided GitHub context.

        .OUTPUTS
        GitHubPublicKey

        .LINK
        [Get a repository public key](https://docs.github.com/rest/codespaces/repository-secrets#get-a-repository-public-key)
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
            APIEndpoint = "/repos/$Owner/$Repository/codespaces/secrets/public-key"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubPublicKey]::new($_.Response, 'codespaces', $Owner, $Repository, $null)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
