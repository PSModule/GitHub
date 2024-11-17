class GitHubContext {
    [string]$Name
    [string]$AuthType
    [string]$SecretType
    [string]$ApiBaseUri = 'https://api.github.com'
    [string]$ApiVersion = '2022-11-28'
    [string]$HostName = 'github.com'
    [int]$ID

    GitHubContext([string]$name, [string]$authType, [string]$secretType, [System.Security.SecureString]$secret, [string]$hostName, [int]$id) {
        $this.Name = $name
        $this.AuthType = $authType
        $this.SecretType = $secretType
        $this.Secret = $secret
        $this.HostName = $hostName
        $this.ID = $id
    }
}
