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
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser', SupportsShouldProcess)]
    param (
        # The organization name. The name is not case-sensitive.
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string]$Organization,

        # The account owner of the repository. The name is not case-sensitive.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Owner,

        # The name of the repository. The name is not case-sensitive.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Repository,

        # The name of the repository environment.
        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string]$Environment,

        # The name of the secret to delete.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name,

        # Specifies whether the secret is for Actions or Codespaces.
        [ValidateSet('actions', 'codespaces')]
        [string]$Type = 'actions',

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
            Method      = 'DELETE'
            APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                'Environment' {
                    "/repos/$Owner/$Repository/environments/$Environment/secrets/$Name"
                    break
                }
                'Organization' {
                    "/orgs/$Organization/$Type/secrets/$Name"
                    break
                }
                'Repository' {
                    "/repos/$Owner/$Repository/$Type/secrets/$Name"
                    break
                }
                'AuthenticatedUser' {
                    "/user/codespaces/secrets/$Name"
                    break
                }
            }
            Context     = $Context
        }

        if ($PSCmdLet.ShouldProcess(
                "Deleting GitHub $Type secret [$Name]",
                "Are you sure you want to delete $($inputObject.APIEndpoint)?",
                'Delete secret'
            )) {
            Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
