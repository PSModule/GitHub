function Test-GitHubAccessTokenRefreshRequired {
    <#
        .SYNOPSIS
        Test if the GitHub access token should be refreshed.

        .DESCRIPTION
        Test if the GitHub access token should be refreshed.

        .EXAMPLE
        Test-GitHubAccessTokenRefreshRequired

        This will test if the GitHub access token should be refreshed.
    #>
    [OutputType([bool])]
    [CmdletBinding()]
    param()

    $tokenType = Get-GitHubConfig -Name 'AccessTokenType' -ErrorAction SilentlyContinue
    if ($tokenType -ne 'ghu_*') {
        Write-Verbose 'The access token is not a user token. No need to refresh.'
        return $false
    }

    $tokenExpirationDate = Get-GitHubConfig -Name 'AccessTokenExpirationDate' -ErrorAction SilentlyContinue
    $currentDateTime = Get-Date
    $remainingDuration = [datetime]$tokenExpirationDate - $currentDateTime

    # If the remaining time is less that $script:Auth.AccessTokenGracePeriodInHours then the token should be refreshed
    $remainingDuration.TotalHours -lt $script:Auth.AccessTokenGracePeriodInHours
}
