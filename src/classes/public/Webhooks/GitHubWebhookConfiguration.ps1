class GitHubWebhookConfiguration {
    # The content type of the webhook
    [string]$ContentType

    # Indicates whether the webhook uses SSL
    [System.Nullable[bool]]$UseSsl

    # The secret token for the webhook
    [string]$Secret

    # The URL of the webhook
    [string]$Url

    GitHubWebhookConfiguration([PSCustomObject] $Object) {
        $this.ContentType = $Object.content_type
        $this.UseSsl = -not [bool]$Object.insecure_ssl
        $this.Secret = $Object.secret
        $this.Url = $Object.url
    }
}
