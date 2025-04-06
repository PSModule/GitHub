function Remove-GitHubSecret {
    <#
        .SYNOPSIS
        Deletes a secret from GitHub.

        .DESCRIPTION
        Removes a secret from a specified GitHub repository, environment, organization, or authenticated user.
        Supports both Actions and Codespaces secrets and requires appropriate authentication.

        .EXAMPLE
        Remove-GitHubSecret -Owner PSModule -Repository Demo -Type actions -Name TEST

        Deletes the secret named 'TEST' from the 'Demo' repository in the 'PSModule' organization.

        .EXAMPLE
        Remove-GitHubSecret -Organization MyOrg -Type actions -Name API_KEY

        Deletes the secret 'API_KEY' from the organization 'MyOrg'.

        .EXAMPLE
        Remove-GitHubSecret -Owner MyUser -Repository MyRepo -Environment Production -Name DB_PASSWORD

        Deletes the 'DB_PASSWORD' secret from the 'Production' environment in the 'MyRepo' repository.

        .NOTES
        Supports authentication using GitHub App tokens (IAT), Personal Access Tokens (PAT), or User Access Tokens (UAT).

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Remove-GitHubSecret/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSShouldProcess', '', Scope = 'Function',
        Justification = 'This check is performed in the private functions.'
    )]
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Organization', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory, ParameterSetName = 'Repository', ValueFromPipelineByPropertyName)]
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Repository,

        # The name of the environment.
        [Parameter(Mandatory, ParameterSetName = 'Environment', ValueFromPipelineByPropertyName)]
        [string] $Environment,

        # The name of the secret.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $Name,

        # # Specifies whether the secret is for Actions or Codespaces.
        # [ValidateSet('actions', 'codespaces')]
        # [string] $Type = 'actions',

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
        $params = @{
            Owner   = $Owner
            Name    = $Name
            Context = $Context
        }
        Write-Debug "ParameterSet: $($PSCmdlet.ParameterSetName)"
        switch ($PSCmdlet.ParameterSetName) {
            'Organization' {
                Remove-GitHubSecretFromOwner @params
                break
            }
            'Repository' {
                Remove-GitHubSecretFromRepository @params -Repository $Repository
                break
            }
            'Environment' {
                Remove-GitHubSecretFromEnvironment @params -Repository $Repository -Environment $Environment
                break
            }
            'AuthenticatedUser' {
                break
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
