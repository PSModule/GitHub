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
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    $Context = Resolve-GitHubContext -Context $Context

    $gitHubConfig = Get-GitHubConfig
    $tokenExpirationDate = $Context.TokenExpirationDate
    $currentDateTime = Get-Date
    $remainingDuration = [datetime]$tokenExpirationDate - $currentDateTime

    # If the remaining time is less that $script:Auth.AccessTokenGracePeriodInHours then the token should be refreshed
    $remainingDuration.TotalHours -lt $gitHubConfig.AccessTokenGracePeriodInHours
}
