function Test-GitHubCodespace {
    <#
    .SYNOPSIS
        Determines whether a GitHub codespace exists.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER User
        The handle for the GitHub user account.

    .PARAMETER Owner
        The account owner of the repository. The name is not case sensitive.

    .PARAMETER Repository
        The name of the repository. The name is not case sensitive.

    .PARAMETER Name
        The name of the codespace.

    .EXAMPLE
        > Test-GitHubCodespace -Name urban-dollop-pqxgrq55v4c97g4

        False

    .OUTPUTS
        [bool]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#about-github-codespaces

    .LINK
        https://docs.github.com/en/rest/codespaces/organizations?apiVersion=2022-11-28#list-codespaces-for-a-user-in-organization
    #>
    [CmdletBinding(DefaultParameterSetName = 'Scope')]
    [OutputType([bool])]
    param (
        [Parameter(ParameterSetName = 'Organization', Mandatory )]
        [string]$Organization,
        [Parameter(ParameterSetName = 'Organization')]
        [string]$User,

        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Owner,

        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Repository,

        [Parameter(ParameterSetName = 'Name', Mandatory)]
        [string]$Name,

        [Parameter(ParameterSetName = 'Scope')]
        [ValidateSet('Organization','User')]
        [string]$Scope='User',

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    process {
        try {
            $codespace = Get-GitHubCodespace @PSBoundParameters
            [bool]$codespace.id
        } catch {
            $false
            # This part doesn't work as intended because of the error handling in Invoke-GitHubAPI :(
            # if (404 -ne $_.Exception.Response.StatusCode.value__) {
            #     throw
            # }
        }
    }
}
