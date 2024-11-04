filter Get-GitHubAppInstallation {
    <#
        .SYNOPSIS
        List installations for the authenticated app

        .DESCRIPTION
        The permissions the installation has are included under the `permissions` key.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.


        .EXAMPLE
        An example

        .NOTES
        [List installations for the authenticated app](https://docs.github.com/rest/apps/apps#list-installations-for-the-authenticated-app)
    #>
    [CmdletBinding()]
    param()

    $inputObject = @{
        APIEndpoint = '/app/installations'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
