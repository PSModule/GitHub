﻿filter Get-GitHubAppByName {
    <#
        .SYNOPSIS
        Get an app

        .DESCRIPTION
        Gets a single GitHub App using the app's slug.

        .EXAMPLE
        Get-GitHubAppByName -AppSlug 'github-actions'

        Gets the GitHub App with the slug 'github-actions'.

        .NOTES
        [Get an app](https://docs.github.com/en/rest/apps/apps?apiVersion=2022-11-28#get-an-app)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The AppSlug is just the URL-friendly name of a GitHub App.
        # You can find this on the settings page for your GitHub App (e.g., https://github.com/settings/apps/<app_slug>).
        # Example: 'github-actions'
        [Parameter(Mandatory)]
        [Alias('Name')]
        [string] $AppSlug,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [GitHubContext] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'Get'
            APIEndpoint = "/apps/$AppSlug"
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
