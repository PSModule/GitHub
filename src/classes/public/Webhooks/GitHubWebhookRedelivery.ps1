class GitHubWebhookRedelivery : GitHubWebhook {
    # Number of attempts to deliver the webhook.
    [int] $Attempts

    # Simple parameterless constructor
    GitHubWebhookRedelivery() {}

    # Creates a context object from a hashtable of key-vaule pairs.
    GitHubWebhookRedelivery([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    GitHubWebhookRedelivery([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }
}
