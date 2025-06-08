function Get-GitHubPublicKey {
    <#
        .SYNOPSIS
        Gets a public key.

        .DESCRIPTION
        Gets your public key, which you need to encrypt secrets.

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
        [Parameter(Mandatory, ParameterSetName = 'Organization', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the repository environment.
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Environment,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter()]
        [ValidateSet('actions', 'codespaces')]
        [string] $Type = 'actions',

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $scope = @{
            Context = $Context
            Owner   = $Owner
        }
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                switch ($Type) {
                    'actions' {
                        Get-GitHubPublicKeyForActionOnOrganization @scope
                    }
                    'codespaces' {
                        Get-GitHubPublicKeyForCodespacesOnOrganization @scope
                    }
                }
                break
            }
            'Repository' {
                $scope['Repository'] = $Repository
                switch ($Type) {
                    'actions' {
                        Get-GitHubPublicKeyForActionOnRepository @scope
                    }
                    'codespaces' {
                        Get-GitHubPublicKeyForCodespacesOnRepository @scope
                    }
                }
                break
            }
            'Environment' {
                $scope['Repository'] = $Repository
                $scope['Environment'] = $Environment
                switch ($Type) {
                    'actions' {
                        Get-GitHubPublicKeyForActionOnEnvironment @scope
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
                        throw "AuthenticatedUser is not supported for actions. Specify -Type 'codespaces'"
                    }
                    'codespaces' {
                        Get-GitHubPublicKeyForCodespacesOnUser -Context $Context
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
