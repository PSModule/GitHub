function Invoke-GitHubAPI {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE', 'PUT')]
        [String] $Method = 'GET',

        [Parameter()]
        [string] $ApiBaseUri = $script:Config.App.Api.BaseUri,

        [Parameter(Mandatory)]
        [string] $ApiEndpoint,

        [Parameter()]
        [Object] $Body,

        [Parameter()]
        [string] $Accept,

        [Parameter()]
        [string] $AccessToken = $script:Config.User.Auth.AccessToken.Value,

        [Parameter()]
        [string] $ContentType = 'application/vnd.github+json',

        [Parameter()]
        [string] $Version = $script:Config.App.Api.Version,

        [Parameter()]
        [switch] $UseWebRequest
    )

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
        if ($UseWebRequest) {
            return Invoke-WebRequest @APICall
        }
        Invoke-RestMethod @APICall
    } catch {
        $errorMessage = "Error calling GitHub Api: $($_.Exception.Message)"
        Write-Error $errorMessage
        throw $_
    }
}
