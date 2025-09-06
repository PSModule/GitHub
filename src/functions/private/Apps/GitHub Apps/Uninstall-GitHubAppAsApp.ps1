function Uninstall-GitHubAppAsApp {
    <#
        .SYNOPSIS
        Delete an installation for the authenticated app.

        .DESCRIPTION
        Deletes a GitHub App installation using the authenticated App context.

        .EXAMPLE
        Uninstall-GitHubAppAsApp -ID 123456 -Context $appContext

        Deletes the installation with ID 123456 for the authenticated app.

        .NOTES
        [Delete an installation for the authenticated app](https://docs.github.com/rest/apps/installations#delete-an-installation-for-the-authenticated-app)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Contains a long link.'
    )]
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        # The installation ID to remove.
        [Parameter(Mandatory)]
        [Alias('InstallationID')]
        [ValidateRange(1, [UInt64]::MaxValue)]
        [UInt64] $ID,

        # The context to run the command in.
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        Write-Verbose "Uninstalling GitHub App Installation: $ID"

        $apiParams = @{
            Method      = 'DELETE'
            APIEndpoint = "/app/installations/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("GitHub App Installation: $ID", 'Uninstall')) {
            $null = Invoke-GitHubAPI @apiParams
            Write-Verbose "Successfully removed installation: $ID"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
