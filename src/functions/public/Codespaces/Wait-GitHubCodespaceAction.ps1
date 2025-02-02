function Wait-GitHubCodespaceAction {
    <#
    .SYNOPSIS
        Waits for a codespace action to complete.

    .DESCRIPTION
        Polls using Get-GitHubCodespace every 5 seconds until the codespace state -notmatch 'ing'

    .PARAMETER GetParameters
        Hashtable of parameters to splat for Get-GitHubCodespace polling.

    .EXAMPLE
        > Wait-GitHubCodespaceAction -GetParameters @{ Name='urban-dollop-pqxgrq55v4c97g4' }

    .OUTPUTS
        [PSObject]
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable]$GetParameters
    )
    process {
        # Expected states for happy paths:
        # Shutdown  > Queued > Starting     > Available
        # Available > Queued > ShuttingDown > ShutDown
        #
        # To allow for unexpected results, loop until the state is something other than Queued or *ing
        # All known states:
        # *ings: Awaiting, Exporting, Provisioning, Rebuilding, ShuttingDown, Starting, Updating
        # Other: Archived, Available, Created, Deleted, Failed, Moved, Queued, Shutdown, Unavailable, Unknown
        do {
            Start-Sleep -Seconds 5
            $_codespace = Get-GitHubCodespace @GetParameters
            Write-Debug ($_codespace | Out-String)
        } until($_codespace.state -notmatch 'Queued|ing')
        $_codespace
    }
}
