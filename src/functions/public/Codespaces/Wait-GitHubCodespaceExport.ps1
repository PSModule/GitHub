function Wait-GitHubCodespaceExport {
    <#
    .SYNOPSIS
        Waits for a codespace export to complete.

    .DESCRIPTION
        Polls using Get-GitHubCodespaceExport every 5 seconds until the export state is -ne `in_progress`

    .PARAMETER Id
        The ID of the export operation.

    .PARAMETER Name
        The name of the codespace.

    .EXAMPLE
        > Wait-GitHubCodespace -Name urban-dollop-pqxgrq55v4c97g4


    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28#export-a-codespace-for-the-authenticated-user
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$Id='latest',

        [Parameter(Mandatory)]
        [string]$Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    process {
        $_export = Get-GitHubCodespaceExport @PSBoundParameters
        while ($_export.state -eq 'in_progress') {
            $_export = Get-GitHubCodespaceExport -Name $Name
            Write-Debug ($_export | Out-String)
            Start-Sleep -Seconds 5
        }
        $_export
    }
}
