function Get-GitHubAppWebhookDeliveryByList {
    <#
        .SYNOPSIS
        List deliveries for an app webhook

        .DESCRIPTION
        Returns a list of webhook deliveries for the webhook configured for a GitHub App.

        You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app)
        to access this endpoint.

        .EXAMPLE
        Get-GitHubAppWebhookDeliveryByList

        Returns the webhook configuration for the authenticated app.

        .NOTES
        [List deliveries for an app webhook](https://docs.github.com/rest/apps/webhooks#list-deliveries-for-an-app-webhook)
    #>
    [OutputType([GitHubWebhook[]])]
    [CmdletBinding()]
    param(
        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType APP
    }

    process {
        try {
            $body = @{
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = '/app/hook/deliveries'
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                $_.Response | ForEach-Object {
                    [GitHubWebhook](
                        @{
                            ID             = $_.id
                            GUID           = $_.guid
                            DeliveredAt    = $_.delivered_at
                            Redelivery     = $_.redelivery
                            Duration       = $_.duration
                            Status         = $_.status
                            StatusCode     = $_.status_code
                            Event          = $_.event
                            Action         = $_.action
                            InstallationID = $_.installation.id
                            RepositoryID   = $_.repository.id
                            ThrottledAt    = $_.throttled_at
                            URL            = $_.url
                            Request        = $_.request
                            Response       = $_.response
                        }
                    )
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
