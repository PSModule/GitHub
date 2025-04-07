class GitHubWebhookDelivery {
    # Unique identifier of the delivery.
    [uint64] $ID

    # Unique identifier for the event (shared with all deliveries for all webhooks that subscribe to this event).
    [string] $GUID

    # Time when the delivery was delivered.
    [Nullable[datetime]] $DeliveredAt

    # Whether the delivery is a redelivery.
    [Nullable[boolean]] $Redelivery

    # Time spent delivering, in seconds.
    [Nullable[double]] $Duration

    # Description of the status of the attempted delivery
    [string] $Status

    # Status code received when delivery was made.
    [uint16] $StatusCode

    # The event that triggered the delivery.
    [string] $Event

    # The type of activity for the event that triggered the delivery.
    [string] $Action

    # The id of the GitHub App installation associated with this event.
    [Nullable[uint64]] $InstallationID

    # The id of the repository associated with this event.
    [Nullable[uint64]] $RepositoryID

    # Time when the webhook delivery was throttled.
    [Nullable[datetime]] $ThrottledAt

    # The URL target of the delivery.
    [string] $URL

    # The request for the delivery.
    [object] $Request

    # The response from the delivery.
    [object] $Response

    # Number of attempts to deliver the webhook.
    [Nullable[int]] $Attempts

    # Simple parameterless constructor
    GitHubWebhookDelivery() {}

    # Creates a context object from a hashtable of key-vaule pairs.
    GitHubWebhookDelivery([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    GitHubWebhookDelivery([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
