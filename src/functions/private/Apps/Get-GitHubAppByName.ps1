filter Get-GitHubAppByName {
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
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Context     = $Context
            APIEndpoint = "/apps/$AppSlug"
            Method      = 'GET'
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }
    end {
        Write-Verbose "[$commandName] - End"
    }
}
