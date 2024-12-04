#Requires -Modules @{ ModuleName = 'Context'; RequiredVersion = '4.0.0' }

function Remove-GitHubConfig {
    <#
        .SYNOPSIS
        Remove a GitHub module configuration.

        .DESCRIPTION
        Remove a GitHub module configuration.

        .EXAMPLE
        Remove-GitHubConfig -Name DefaultUser

        Removes the 'DefaultUser' item in the GitHub module configuration.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Set the access token type.
        [Parameter()]
        [string] $Name
    )

    $commandName = $MyInvocation.MyCommand.Name
    Write-Verbose "[$commandName] - Start"

    try {
        if ($PSCmdlet.ShouldProcess('ContextSetting', 'Remove')) {
            Remove-ContextSetting -Name $Name -ID $script:Config.Name
        }
    } catch {
        Write-Error $_
        Write-Error (Get-PSCallStack | Format-Table | Out-String)
        throw 'Failed to connect to GitHub.'
    }

    Write-Verbose "[$commandName] - End"
}
