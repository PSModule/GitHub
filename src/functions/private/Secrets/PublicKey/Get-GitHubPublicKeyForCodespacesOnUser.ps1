function Get-GitHubPublicKeyForCodespacesOnUser {
    <#
        .SYNOPSIS
        Get public key for the authenticated user.

        .DESCRIPTION
        Gets your public key, which you need to encrypt secrets. You need to encrypt a secret before you can create or update secrets.
        The authenticated user must have Codespaces access to use this endpoint.
        OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubPublicKeyForCodespacesOnUser -Context $GitHubContext

        Outputs:
        ```powershell
        ID          : 3380189982652154440
        Key         : dpr7ea5wmASt3ewAYNR/wPiPd6qakxN0060jdBmun0Y=                    #gitleaks:allow
        Type        : codespaces
        Owner       : octocat
        Repository  :
        Environment :
        ```

        Gets the public key for the current user for codespaces using the provided GitHub context.

        .OUTPUTS
        GitHubPublicKey

        .LINK
        [Get public key for the authenticated user](https://docs.github.com/rest/codespaces/secrets#get-public-key-for-the-authenticated-user)
    #>
    [OutputType([GitHubPublicKey])]
    [CmdletBinding()]
    param (
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/user/codespaces/secrets/public-key'
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubPublicKey]@{
                ID    = $_.Response.key_id
                Key   = $_.Response.key
                Type  = 'codespaces'
                Owner = $Context.UserName
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
