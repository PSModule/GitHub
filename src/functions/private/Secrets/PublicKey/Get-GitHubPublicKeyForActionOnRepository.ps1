function Get-GitHubPublicKeyForActionOnRepository {
    <#
        .SYNOPSIS
        Get a repository public key.

        .DESCRIPTION
        Gets your public key, which you need to encrypt secrets. You need to encrypt a secret before you can create or update secrets. Anyone with
        read access to the repository can use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need
        the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubPublicKeyForActionOnRepository -Owner 'octocat' -Repository 'hello-world' -Context $GitHubContext

        Outputs:
        ```powershell
        ID          : 3380204578043523366
        Key         : WkwZZ0xWbxZMqWrfUxLgvnALbrfdZSWxrhBcfTKshDY=
        Type        : actions
        Owner       : octocat
        Repository  : hello-world
        Environment :
        ```

        Gets the public key for the 'hellow-world' repository in the 'octocat' organization using the provided GitHub context.

        .OUTPUTS
        GitHubPublicKey

        .LINK
        [Get a repository public key](https://docs.github.com/rest/actions/secrets#get-a-repository-public-key)
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
            APIEndpoint = "/repos/$Owner/$Repository/actions/secrets/public-key"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubPublicKey]@{
                ID         = $_.Response.key_id
                Key        = $_.Response.key
                Type       = 'actions'
                Owner      = $Owner
                Repository = $Repository
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
