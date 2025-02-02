function Get-GitHubCodespace {
    <#
    .SYNOPSIS
        Retrieve GitHub codespace(s).

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
        > Get-GitHubCodespace -Name urban-dollop-pqxgrq55v4c97g4

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#list-codespaces-in-a-repository-for-the-authenticated-user

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#list-codespaces-for-the-authenticated-user

    .LINK
        https://docs.github.com/en/rest/codespaces/organizations?apiVersion=2022-11-28#list-codespaces-for-the-organization

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#get-a-codespace-for-the-authenticated-user

    .LINK
        https://docs.github.com/en/rest/codespaces/organizations?apiVersion=2022-11-28#list-codespaces-for-a-user-in-organization
    #>
    # [CmdletBinding(DefaultParameterSetName = 'Scope', SupportsPaging)]
    [CmdletBinding(DefaultParameterSetName = 'Scope')]
    param (
        [Parameter(ParameterSetName = 'Organization', Mandatory)]
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
        [ValidateSet('Organization', 'User')]
        [string]$Scope = 'User',

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    process {
        $getParams = @{
            APIEndpoint = switch ($PSCmdlet.ParameterSetName) {
                'Organization' {
                    [string]::IsNullOrWhiteSpace($User) ?
                    "/orgs/$Organization/codespaces" :
                    "/orgs/$Organization/members/$User/codespaces"
                    break
                }
                'Repository' {
                    "/repos/$Owner/$Repository/codespaces"
                    break
                }
                'Name' {
                    "/user/codespaces/$Name"
                    break
                }
                'Scope' {
                    $Scope -eq 'Organization' ?
                    "/orgs/$Organization/codespaces" :
                    '/user/codespaces'
                    break
                }
            }
            Context     = $Context
            Method      = 'GET'
        }
        # foreach($_name in 'First','Skip') {
        #     if ($PSBoundParameters.ContainsKey($_name)) {
        #         $getParams[$_name] = $PSBoundParameters[$_name]
        #     }
        # }
        $response = Invoke-GitHubAPI @getParams | Select-Object -ExpandProperty Response
        [bool]$response.PSObject.Properties['codespaces'] ? $response.codespaces : $response
        #| Add-ObjectDetail -TypeName GitHub.Codespace -DefaultProperties name, display_name, location, state, created_at, updated_at, last_used_at
    }
}