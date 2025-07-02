filter Get-GitHubAppInstallationRequest {
    <#
        .SYNOPSIS
        List installation requests for the authenticated app.

        .DESCRIPTION
        Lists all the pending installation requests for the authenticated GitHub App.

        .EXAMPLE
        Get-GitHubAppInstallationRequest

        Lists all the pending installation requests for the authenticated GitHub App.

        .NOTES
        [List installation requests for the authenticated app](https://docs.github.com/rest/apps/apps#list-installation-requests-for-the-authenticated-app)

        .LINK
        https://psmodule.io/GitHub/Functions/Apps/GitHub%20App/Get-GitHubAppInstallationRequest
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Justification = 'Contains a long link.'
    )]
    [OutputType([GitHubAppInstallationRequest])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/app/installation-requests'
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response | ForEach-Object {
                [GitHubAppInstallationRequest]::new($_)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
