function Remove-GitHubAppInstallation {
    <#
        .SYNOPSIS
        Delete an installation for the authenticated app.

        .DESCRIPTION
        Uninstalls a GitHub App on a user, organization, or enterprise account. If you
        prefer to temporarily suspend an app's access to your account's resources, then
        we recommend the "Suspend an app installation" endpoint.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Remove-GitHubAppInstallation -ID 123456

        Delete the installation with ID 123456 for the authenticated app.

        .OUTPUTS
        None

        .NOTES
        [Delete an installation for the authenticated app](https://docs.github.com/rest/apps/apps#delete-an-installation-for-the-authenticated-app)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The unique identifier of the installation.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string] $ID,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        $apiParams = @{
            Method      = 'DELETE'
            APIEndpoint = "/app/installations/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("Installation ID: $ID", 'Delete GitHub App Installation')) {
            $null = Invoke-GitHubAPI @apiParams
            Write-Verbose "Successfully deleted installation with ID: $ID"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
