function Invoke-GitHubDeviceFlowLogin {
    <#
        .SYNOPSIS
        Starts the GitHub Device Flow login process.

        .DESCRIPTION
        Starts the GitHub Device Flow login process. This will prompt the user to visit a URL and enter a code.

        .EXAMPLE
        Invoke-GitHubDeviceFlowLogin

        This will start the GitHub Device Flow login process.
        The user gets prompted to visit a URL and enter a code.

        .NOTES
        For more info about the Device Flow visit:
        https://docs.github.com/apps/creating-github-apps/writing-code-for-a-github-app/building-a-cli-with-a-github-app
        https://docs.github.com/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#device-flow
    #>
    [OutputType([void])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'Is the CLI part of the module.')]
    [CmdletBinding()]
    param(
        # The Client ID of the GitHub App.
        [Parameter(Mandatory)]
        [string] $ClientID,

        # The scope of the access token, when using OAuth authentication.
        # Provide the list of scopes as space-separated values.
        # For more information on scopes visit:
        # https://docs.github.com/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps
        [Parameter()]
        [string] $Scope,

        # The host to connect to.
        [Parameter(Mandatory)]
        [string] $HostName,

        # The refresh token to use for re-authentication.
        [Parameter()]
        [securestring] $RefreshToken
    )

    do {
        if ($RefreshToken) {
            $tokenResponse = Wait-GitHubAccessToken -ClientID $ClientID -RefreshToken $RefreshToken -HostName $HostName
        } else {
            $deviceCodeResponse = Request-GitHubDeviceCode -ClientID $ClientID -Scope $Scope -HostName $HostName

            $deviceCode = $deviceCodeResponse.device_code
            $interval = $deviceCodeResponse.interval
            $userCode = $deviceCodeResponse.user_code
            $verificationUri = $deviceCodeResponse.verification_uri

            Write-Host '! ' -ForegroundColor DarkYellow -NoNewline
            Write-Host "We added the code to your clipboard: [$userCode]"
            $userCode | Set-Clipboard
            Read-Host 'Press Enter to open github.com in your browser...'
            Start-Process $verificationUri

            $tokenResponse = Wait-GitHubAccessToken -DeviceCode $deviceCode -ClientID $ClientID -Interval $interval -HostName $HostName
        }
    } while ($tokenResponse.error)
    $tokenResponse
}
