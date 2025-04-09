class GitHubWebhookDelivery {
    # Unique identifier of the delivery.
    [uint64] $ID

    # Unique identifier for the event (shared with all deliveries for all webhooks that subscribe to this event).
    [string] $GUID

    # Time when the delivery was delivered.
    [System.Nullable[datetime]] $DeliveredAt

    # Whether the delivery is a redelivery.
    [System.Nullable[boolean]] $Redelivery

    # Time spent delivering, in seconds.
    [System.Nullable[double]] $Duration

    # Description of the status of the attempted delivery
    [string] $Status

    # Status code received when delivery was made.
    [uint16] $StatusCode

    # The event that triggered the delivery.
    [string] $Event

    # The type of activity for the event that triggered the delivery.
    [string] $Action

    # The id of the GitHub App installation associated with this event.
    [System.Nullable[uint64]] $InstallationID

    # The id of the repository associated with this event.
    [System.Nullable[uint64]] $RepositoryID

    # Time when the webhook delivery was throttled.
    [System.Nullable[datetime]] $ThrottledAt

    # The URL target of the delivery.
    [string] $Url

    # The request for the delivery.
    [object] $Request

    # The response from the delivery.
    [object] $Response

    # Number of attempts to deliver the webhook.
    [System.Nullable[int]] $Attempts

    GitHubWebhookDelivery() {}

    GitHubWebhookDelivery([PSCustomObject]$Object) {
        $this.ID = $Object.id
        $this.GUID = $Object.guid
        $this.DeliveredAt = $Object.delivered_at
        $this.Redelivery = $Object.redelivery
        $this.Duration = $Object.duration
        $this.Status = $Object.status
        $this.StatusCode = $Object.status_code
        $this.Event = $Object.event
        $this.Action = $Object.action
        $this.InstallationID = $Object.installation.id
        $this.RepositoryID = $Object.repository.id
        $this.ThrottledAt = $Object.throttled_at
        $this.Url = $Object.url
        $this.Request = $Object.request
        $this.Response = $Object.response

    }
}
