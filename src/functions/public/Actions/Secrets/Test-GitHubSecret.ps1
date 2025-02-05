function Test-GitHubSecret {
    <#
    .SYNOPSIS
        Determines whether a GitHub secret exists.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER Owner
        The account owner of the repository. The name is not case sensitive.

    .PARAMETER Repository
        The name of the repository. The name is not case sensitive.

    .PARAMETER Environment
        The name of the repository environment.

    .PARAMETER Name
        The name of the secret.

    .PARAMETER Type
        actions / codespaces

    .EXAMPLE
        > Test-GitHubSecret -Owner PSModule -Repository Demo -Name DEMO_SECRET

        False

    .OUTPUTS
        [bool]

    .LINK
        https://docs.github.com/en/rest/actions/secrets?apiVersion=2022-11-28#about-secrets-in-github-actions
    #>
    [CmdletBinding(DefaultParameterSetName = 'AuthenticatedUser')]
    [OutputType([bool])]
    param (
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
        [string]$Organization,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Owner,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Repository,

        [Parameter(ParameterSetName = 'Environment', Mandatory)]
        [string]$Environment,

        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('actions', 'codespaces')]
        [string]$Type = 'actions',

        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    process {
        try {
            $secret = Get-GitHubSecret @PSBoundParameters
            [bool]$secret.name
        } catch {
            $false
            # This part doesn't work as intended because of the error handling in Invoke-GitHubAPI :(
            # if (404 -ne $_.Exception.Response.StatusCode.value__) {
            #     throw
            # }
        }
    }
}
