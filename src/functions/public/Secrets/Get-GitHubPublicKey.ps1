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
        Get-GitHubPublicKey -Organization 'octocat'

        Gets a public key for the 'octocat' organization.

        .EXAMPLE
        Get-GitHubPublicKey -Owner 'octocat' -Repository 'hello-world' -Type 'codespaces'

        Gets a public key for the 'hello-world' repository in the 'octocat' organization for codespaces.

        .OUTPUTS
        GitHubPublicKey

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Get-GitHubPublicKey/
    #>
    [OutputType([GitHubPublicKey])]
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string] $Repository,

        # The name of the repository environment.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string] $Environment,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter()]
        [ValidateSet('actions', 'codespaces')]
        [string] $Type = 'actions',

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
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                switch ($Type) {
                    'actions' {
                        Get-GitHubPublicKeyForActionOnOrganization -Owner $Owner -Context $Context
                    }
                    'codespaces' {
                        Get-GitHubPublicKeyForCodespacesOnOrganization -Owner $Owner -Context $Context
                    }
                }
                break
            }
            'Repository' {
                switch ($Type) {
                    'actions' {
                        Get-GitHubPublicKeyForActionOnRepository -Owner $Owner -Repository $Repository -Context $Context
                    }
                    'codespaces' {
                        Get-GitHubPublicKeyForCodespacesOnRepository -Owner $Owner -Repository $Repository -Context $Context
                    }
                }
                break
            }
            'Environment' {
                switch ($Type) {
                    'actions' {
                        Get-GitHubPublicKeyForActionOnEnvironment -Owner $Owner -Repository $Repository -Environment $Environment -Context $Context
                    }
                    'codespaces' {
                        throw 'Environment is not supported for codespaces.'
                    }
                }
                break
            }
            'AuthenticatedUser' {
                switch ($Type) {
                    'actions' {
                        throw 'AuthenticatedUser is not supported for actions.'
                    }
                    'codespaces' {
                        Get-GitHubPublicKeyForCodespacesOnUser
                    }
                }
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
