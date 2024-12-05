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
    param(
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $contextObj = Get-GitHubContext -Context $Context
    $gitHubConfig = Get-GitHubConfig
    $tokenExpirationDate = $contextObj.TokenExpirationDate
    $currentDateTime = Get-Date
    $remainingDuration = [datetime]$tokenExpirationDate - $currentDateTime

    # If the remaining time is less that $script:Auth.AccessTokenGracePeriodInHours then the token should be refreshed
    $remainingDuration.TotalHours -lt $gitHubConfig.AccessTokenGracePeriodInHours
}
