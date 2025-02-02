function Export-GitHubCodespace {
    <#
    .SYNOPSIS
        Exports a codespace.

    .DESCRIPTION
        Triggers an export of the specified codespace and returns a URL and ID where the status of the export can be monitored.
        If changes cannot be pushed to the codespace's repository, they will be pushed to a new or previously-existing fork instead.
        You must authenticate using a personal access token with the codespace scope to use this endpoint.
        GitHub Apps must have write access to the codespaces_lifecycle_admin repository permission to use this endpoint.

    .PARAMETER Name
        The name of the codespace.

    .PARAMETER Wait
        If present will wait for the export to complete.

    .EXAMPLE
        > Export-GitHubCodespace -Name fluffy-disco-v7xgv7j4j52pvw9

    .EXAMPLE
        > Export-GitHubCodespace -Name $ominousSpace.name -Wait

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#export-a-codespace-for-the-authenticated-user
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Name,

        [switch]$Wait,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    process {
        $postParams = @{
            APIEndpoint = "/user/codespaces/$Name/exports"
            Context     = $Context
            Method      = 'POST'
        }
        $export = Invoke-GitHubAPI @postParams | Select-Object -ExpandProperty Response
        if ($Wait.IsPresent) {
            $waitParams = @{
                Context = $Context
                Id      = $export.id
                Name    = $Name
            }
            $export = Wait-GitHubCodespaceExport @waitParams
        }
        $export
    }
}
