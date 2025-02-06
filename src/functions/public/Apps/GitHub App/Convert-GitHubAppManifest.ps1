function Convert-GitHubAppManifest {
    <#
        .SYNOPSIS
        Converts a GitHub App Manifest into a full GitHub App.

        .DESCRIPTION
        Converts a temporary GitHub App Manifest into a full GitHub App by exchanging the provided code for app credentials.
        This function requires authentication and will return key details such as the App ID, Client ID, Private Key, and Webhook Secret.

        .EXAMPLE
        Convert-GitHubAppManifest -Code 'example-code' -Context $GitHubContext

        Converts the GitHub App Manifest associated with 'example-code' using the specified context.
        Returns the App ID, Client ID, Private Key, and Webhook Secret.

        .NOTES
        [GitHub API Docs - Convert a GitHub App Manifest](https://docs.github.com/en/rest/apps/apps#create-a-github-app-from-a-manifest)
    #>

    [CmdletBinding()]
    param(
        # The code received from GitHub to convert the app manifest into an installation.
        [Parameter(Mandatory)]
        [string] $Code,

        # The context to run the command in. Used to get the details for the API call.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/app-manifests/$Code/conversions"
            Context     = $Context
        }

        $response = Invoke-GitHubAPI @inputObject | Select-Object -ExpandProperty Response

        Write-Verbose 'GitHub App converted successfully.'
        Write-Verbose ($response | Format-List | Out-String)

        [PSCustomObject]@{
            AppId         = $response.id
            ClientId      = $response.client_id
            PrivateKey    = $response.pem
            WebhookSecret = $response.webhook_secret
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
