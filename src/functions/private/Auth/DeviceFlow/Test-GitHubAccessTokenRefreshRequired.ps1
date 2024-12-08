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
    $tokenExpirationDate = $Context.TokenExpirationDate
    $currentDateTime = Get-Date
    $remainingDuration = [datetime]$tokenExpirationDate - $currentDateTime

    $remainingDuration.TotalHours -lt $script:GitHub.Config.AccessTokenGracePeriodInHours
}
