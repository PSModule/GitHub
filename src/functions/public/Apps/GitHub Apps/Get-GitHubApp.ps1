filter Get-GitHubApp {
    <#
        .SYNOPSIS
        Get the authenticated app or a specific app by its slug.

        .DESCRIPTION
        Returns a GitHub App associated with the authentication credentials used or the provided app-slug.

        .EXAMPLE
        Get-GitHubApp

        Get the authenticated app.

        .EXAMPLE
        Get-GitHubApp -AppSlug 'github-actions'

        Get the GitHub App with the slug 'github-actions'.

        .NOTES
        [Get an app](https://docs.github.com/en/rest/apps/apps?apiVersion=2022-11-28#get-an-app)
        [Get the authenticated app | GitHub Docs](https://docs.github.com/rest/apps/apps#get-the-authenticated-app)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The AppSlug is just the URL-friendly name of a GitHub App.
        # You can find this on the settings page for your GitHub App (e.g., <https://github.com/settings/apps/{app_slug}>).
        # Example: 'github-actions'
        [Parameter(
            Mandatory,
            ParameterSetName = 'BySlug'
        )]
        [Alias('Name')]
        [string] $AppSlug,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    switch ($PSCmdlet.ParameterSetName) {
        'BySlug' {
            Get-GitHubAppByName -AppSlug $AppSlug -Context $Context
        }
        default {
            Get-GitHubAuthenticatedApp -Context $Context
        }
    }
}
