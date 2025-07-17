class GitHubJWTComponent {
    static [string] ToBase64UrlString([hashtable] $Data) {
        return [GitHubJWTComponent]::ConvertToBase64UrlFormat(
            [System.Convert]::ToBase64String(
                [System.Text.Encoding]::UTF8.GetBytes(
                    (ConvertTo-Json -InputObject $Data)
                )
            )
        )
    }

    static [string] ConvertToBase64UrlFormat([string] $Base64String) {
        return $Base64String.TrimEnd('=').Replace('+', '-').Replace('/', '_')
    }
}
