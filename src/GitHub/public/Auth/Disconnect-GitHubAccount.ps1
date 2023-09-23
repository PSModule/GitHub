function Disconnect-GitHubAccount {
    [OutputType([void])]
    [CmdletBinding()]
    param ()

    $user = Get-GitHubUser
    Reset-GitHubConfig

    Write-Host "✓ " -ForegroundColor Green -NoNewline
    Write-Host "Logged out of account $($user.name) (@$($user.login))!"
}
