function Check-GitHubAccessToken {

    [DateTime]$accessTokenExirationDate = $script:Config.User.Auth.AccessToken.ExpirationDate
    $accessTokenValid = $accessTokenExirationDate -gt (Get-Date)

    if (-not $accessTokenValid) {
        Write-Warning 'Your access token has expired. Refreshing it...'
        Connect-GitHubAccount -Refresh
    }
    $TimeSpan = New-TimeSpan -Start (Get-Date) -End $accessTokenExirationDate
    Write-Host "Your access token will expire in $($TimeSpan.Days)-$($TimeSpan.Hours):$($TimeSpan.Minutes):$($TimeSpan.Seconds)."
}
