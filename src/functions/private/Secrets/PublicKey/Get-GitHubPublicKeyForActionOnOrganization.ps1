function Get-GitHubPublicKeyForActionOnOrganization {
    <#
        .SYNOPSIS
        Get an organization public key.

        .DESCRIPTION
        Gets your public key, which you need to encrypt secrets. You need to encrypt a secret before you can create or update secrets. The
        authenticated user must have collaborator access to a repository to create, update, or read secrets. OAuth tokens and personal access tokens
        (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic)
        need the `repo` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubPublicKeyForActionOnOrganization -Owner 'octocat' -Context $GitHubContext

        Outputs:
        ```powershell
        ID          : 3380204578043523366
        Key         : hwzclrjNNtZxYby19+0fiG7LazGFZxaM1IEbB25fkwo=                    #gitleaks:allow
        Type        : actions
        Owner       : octocat
        Repository  :
        Environment :
        ```

        Gets the public key for the organization 'octocat' using the provided GitHub context.

        .OUTPUTS
        GitHubPublicKey

        .LINK
        [Get an organization public key](https://docs.github.com/rest/actions/secrets#get-an-organization-public-key)
    #>
    [OutputType([GitHubPublicKey])]
    [CmdletBinding()]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

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
            APIEndpoint = "/orgs/$Owner/actions/secrets/public-key"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubPublicKey]@{
                ID    = $_.Response.key_id
                Key   = $_.Response.key
                Type  = 'actions'
                Owner = $Owner
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
