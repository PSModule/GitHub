function Get-GitHubPublicKey {
    <#
        .SYNOPSIS
        Gets a public key.

        .DESCRIPTION
        Gets your public key, which you need to encrypt secrets. You need to encrypt a secret before you can create or update secrets.

        .EXAMPLE
        Get-GitHubPublicKey

        Gets a public key for the authenticated user.

        .EXAMPLE
        Get-GitHubPublicKey -Organization 'PSModule'

        Gets a public key for the 'PSModule' organization.

        .EXAMPLE
        Get-GitHubPublicKey -Owner 'PSModule' -Repository 'GitHub' -Type 'codespaces'

        Gets a public key for the 'GitHub' repository in the 'PSModule' organization for codespaces.

        .OUTPUTS
        [PSObject[]]

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Get-GitHubPublicKey/
    #>
    [OutputType([psobject[]])]
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string] $Repository,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter()]
        [ValidateSet('actions', 'codespaces')]
        [string] $Type = 'actions',

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                $APIEndpoint = "/orgs/$Owner/$Type/secrets/public-key"
                break
            }
            'Repository' {
                $APIEndpoint = "/repos/$Owner/$Repository/$Type/secrets/public-key"
                break
            }
            'AuthenticatedUser' {
                $APIEndpoint = '/user/codespaces/secrets/public-key'
                break
            }
        }

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = $APIEndpoint
            Context     = $Context
            AuthType    = $AuthType
        }
        Invoke-GitHubAPI @inputObject | Select-Object -ExpandProperty Response
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
