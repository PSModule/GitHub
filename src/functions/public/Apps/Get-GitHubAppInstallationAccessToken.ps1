﻿function Get-GitHubAppInstallationAccessToken {
    <#
        .SYNOPSIS
        Create an installation access token for an app

        .DESCRIPTION
        Creates an installation access token that enables a GitHub App to make authenticated API requests for the app's installation on an
        organization or individual account. Installation tokens expire one hour from the time you create them. Using an expired token produces a
        status code of `401 - Unauthorized`, and requires creating a new installation token. By default the installation token has access to all
        repositories that the installation can access.

        Optionally, you can use the `repositories` or `repository_ids` body parameters to specify individual repositories that the installation access
        token can access. If you don't use `repositories` or `repository_ids` to grant access to specific repositories, the installation access token
        will have access to all repositories that the installation was granted access to. The installation access token cannot be granted access to
        repositories that the installation was not granted access to. Up to 500 repositories can be listed in this manner.

        Optionally, use the `permissions` body parameter to specify the permissions that the installation access token should have. If `permissions`
        is not specified, the installation access token will have all of the permissions that were granted to the app. The installation access token
        cannot be granted permissions that the app was not granted.

        When using the repository or permission parameters to reduce the access of the token, the complexity of the token is increased due to both the
        number of permissions in the request and the number of repositories the token will have access to. If the complexity is too large, the token
        will fail to be issued. If this occurs, the error message will indicate the maximum number of repositories that should be requested. For the
        average application requesting 8 permissions, this limit is around 5000 repositories. With fewer permissions requested, more repositories are
        supported.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Get-GitHubAppInstallationAccessToken -InstallationID 12345678

        Gets an installation access token for the installation with the ID `12345678`.

        .NOTES
        [Create an installation access token for an app](https://docs.github.com/rest/apps/apps#create-an-installation-access-token-for-an-app)
    #>
    [CmdletBinding()]
    param (
        # The unique identifier of the installation.
        # Example: '12345678'
        [Parameter(Mandatory)]
        [string] $InstallationID
    )

    $inputObject = @{
        APIEndpoint = "/app/installations/$InstallationID/access_tokens"
        Method      = 'Post'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}