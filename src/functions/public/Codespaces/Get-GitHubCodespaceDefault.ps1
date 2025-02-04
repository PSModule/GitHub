function Get-GitHubCodespaceDefault {
    <#
    .SYNOPSIS
        Get default attributes for creating a new codespace.

    .DESCRIPTION
        Gets the default attributes for codespaces created by the user with the repository.
        You must authenticate using an access token with the codespace scope to use this endpoint.
        GitHub Apps must have write access to the codespaces repository permission to use this endpoint.

    .PARAMETER Owner
        The account owner of the repository. The name is not case sensitive.

    .PARAMETER Repository
        The name of the repository. The name is not case sensitive.

    .EXAMPLE
        > Get-GitHubCodespaceDefault -Owner PSModule -Repository Sodium

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#get-default-attributes-for-a-codespace
    #>
    # [CmdletBinding(SupportsPaging)]
    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Owner,

        [Parameter(ParameterSetName = 'Repository', Mandatory)]
        [string]$Repository,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    $getParams = @{
        ApiEndpoint         = "/repos/$Owner/$Repository/codespaces/new"
    }
    # foreach($_name in 'First','Skip') {
    #     if ($PSBoundParameters.ContainsKey($_name)) {
    #         $getParams[$_name] = $PSBoundParameters[$_name]
    #     }
    # }
    $response = Invoke-GitHubAPI @getParams | Select-Object -ExpandProperty Response
    [bool]$response.PSObject.Properties['billable_owner'] ? $response.billable_owner : $response
    # | Add-ObjectDetail -DefaultProperties login,type,site_admin
}
