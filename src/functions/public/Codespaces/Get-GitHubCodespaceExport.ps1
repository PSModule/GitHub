function Get-GitHubCodespaceExport {
    <#
    .SYNOPSIS
        Get details about a codespace export.

    .DESCRIPTION
        Gets information about an export of a codespace.
        You must authenticate using a personal access token with the codespace scope to use this endpoint.
        GitHub Apps must have read access to the codespaces_lifecycle_admin repository permission to use this endpoint.

    .PARAMETER Id
        The ID of the export operation, or latest. For future use.  Only latest is supported now.

    .PARAMETER Name
        The name of the codespace.

     .EXAMPLE
        > Get-GitHubCodespaceExport -Name urban-dollop-pqxgrq55v4c97g4

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#get-details-about-a-codespace-export
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Id = 'latest',

        [Parameter(Mandatory)]
        [string]$Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    process {
        $getParams = @{
            APIEndpoint = "/user/codespaces/$Name/exports/$Id"
            Context     = $Context
            Method      = 'GET'
        }
        Invoke-GitHubAPI @getParams | Select-Object -ExpandProperty Response
    }
}
