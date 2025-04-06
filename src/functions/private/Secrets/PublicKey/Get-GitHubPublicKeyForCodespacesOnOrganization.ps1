﻿function Get-GitHubPublicKeyForCodespacesOnOrganization {
    <#
        .SYNOPSIS
        Get an organization public key.

        .DESCRIPTION
        Gets a public key for an organization, which is required in order to encrypt secrets. You need to encrypt the value of a secret before you
        can create or update secrets. OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

        .EXAMPLE
        Get-GitHubPublicKeyForCodespacesOnOrganization -Owner 'octocat' -Context $GitHubContext

        Outputs:
        ```powershell
        ID          : 3380189982652154440
        Key         : XbfD9AIInGE=
        Type        : codespaces
        Owner       : octocat
        Repository  :
        Environment :
        ```

        Gets the public key for the organization 'octocat' using the provided GitHub context.

        .OUTPUTS
        GitHubPublicKey

        .LINK
        [Get an organization public key](https://docs.github.com/rest/codespaces/organization-secrets#get-an-organization-public-key)
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
            APIEndpoint = "/orgs/$Owner/codespaces/secrets/public-key"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            [GitHubPublicKey]@{
                ID    = $_.Response.key_id
                Key   = $_.Response.key
                Type  = 'codespaces'
                Owner = $Owner
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
