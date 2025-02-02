function Get-GitHubCodespaceDevContainer {
    <#
    .SYNOPSIS
        List devcontainer configurations in a repository for the authenticated user.

    .DESCRIPTION
        Lists the devcontainer.json files associated with a specified repository and the authenticated user.
        These files specify launchpoint configurations for codespaces created within the repository.
        You must authenticate using an access token with the codespace scope to use this endpoint.
        GitHub Apps must have read access to the codespaces_metadata repository permission to use this endpoint.

    .PARAMETER Owner
        The account owner of the repository. The name is not case sensitive.

    .PARAMETER Repository
        The name of the repository. The name is not case sensitive.

    .EXAMPLE
        > Get-GitHubCodespaceDevContainer -Owner PSModule -Repository Sodium

        path                            name   display_name
        ----                            ----   ------------
        .devcontainer/devcontainer.json Debian Debian

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#list-devcontainer-configurations-in-a-repository-for-the-authenticated-user
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
        APIEndpoint = "/repos/$Owner/$Repository/codespaces/devcontainers"
        ContentType = 'application/vnd.github+json'
        Method      = 'GET'
    }
    # foreach($_name in 'First','Skip') {
    #     if ($PSBoundParameters.ContainsKey($_name)) {
    #         $getParams[$_name] = $PSBoundParameters[$_name]
    #     }
    # }
    $response = Invoke-GitHubAPI @getParams | Select-Object -ExpandProperty Response
    [bool]$response.PSObject.Properties['devcontainers'] ? $response.devcontainers : $response
}
