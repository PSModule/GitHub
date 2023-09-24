function Invoke-GitHubAPI {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method = 'GET',

        [Parameter()]
        [string] $ApiBaseUri = $script:Config.App.Api.BaseUri,

        [Parameter(Mandatory)]
        [string] $ApiEndpoint,

        [Parameter()]
        [Object] $Body,

        [Parameter()]
        [string] $Accept,

        [Parameter()]
        [SecureString] $SecureToken = $script:Config.User.Auth.AccessToken.Value,

        [Parameter()]
        [string] $ContentType = 'application/vnd.github+json',

        [Parameter()]
        [string] $Version = $script:Config.App.Api.Version
    )

    # Decrypting the secure token
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureToken)
    $AccessToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)  # Clear out the plain text from memory

    $headers = @{
        'Content-Type'         = $ContentType
        'X-GitHub-Api-Version' = $Version
        'Accept'               = $Accept
    }

    # Filter out null or empty headers
    $headers = $headers.GetEnumerator() | Where-Object { -not [string]::IsNullOrEmpty($_.Value) } | ForEach-Object {
        @{ $_.Key = $_.Value }
    }

    if (-not [string]::IsNullOrEmpty($AccessToken)) {
        switch -Regex ($AccessToken) {
            '^ghp_|^github_pat_' {
                $authorization = "token $AccessToken"
            }
            '^ghu_|^gho_' {
                $authorization = "Bearer $AccessToken"
            }
            default {
                $tokenPrefix = $AccessToken -replace '_.*$', '_*'
                $errorMessage = "Unexpected AccessToken format: $tokenPrefix"
                Write-Error $errorMessage
                throw $errorMessage
            }
        }
        $headers['Authorization'] = $authorization
    }

    $URI = ("$ApiBaseUri/" -replace '/$', '') + ("/$ApiEndpoint" -replace '^/', '')

    $APICall = @{
        Uri     = $URI
        Method  = $Method
        Headers = $Headers
    }

    if ($Body) {
        if ($Body -is [string]) {
            $APICall['Body'] = $Body
        } else {
            $APICall['Body'] = $Body | ConvertTo-Json -Depth 100
        }
    }

    try {
        Invoke-RestMethod @APICall
    } catch [System.Net.WebException] {
        Write-Error "[Invoke-GitHubAPI] - WebException - $($_.Exception.Message)"
        throw $_
    } catch {
        Write-Error "[Invoke-GitHubAPI] - GeneralException - $($_.Exception.Message)"
        throw $_
    }
}
