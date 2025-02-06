function Test-GitHubSecret {
    <#
        .SYNOPSIS
        Determines whether a GitHub secret exists.

        .DESCRIPTION
        This function checks if a specified secret exists in a GitHub repository, organization, or environment.
        It supports both GitHub Actions and Codespaces secrets.
        Returns $true if the secret exists; otherwise, returns $false.

        .EXAMPLE
        Test-GitHubSecret -Owner PSModule -Repository Demo -Name DEMO_SECRET

        This command checks if the secret "DEMO_SECRET" exists in the "PSModule/Demo" repository.

        .OUTPUTS
        [bool] - Returns $true if the secret exists, otherwise $false.

        .LINK
        https://psmodule.io/GitHub/Functions/Secrets/Test-GitHubSecret/
    #>
    [OutputType([bool])]
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser')]
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

        # The name of the secret.
        [Parameter(Mandatory)]
        [string]$Name,

        # Specifies whether the secret belongs to GitHub Actions or Codespaces.
        [ValidateSet('actions', 'codespaces')]
        [string]$Type = 'actions',

        # GitHub API authentication context.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    process {
        try {
            $secret = Get-GitHubSecret @PSBoundParameters
            [bool]$secret.name
        } catch {
            $false
        }
    }
}
