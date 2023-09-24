function Invoke-GitHubAPI {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE', 'PUT')]
        [String] $Method = 'GET',

        [Parameter()]
        [string] $ApiBaseUri = $script:Config.App.Api.BaseURI,

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

    # Remove null or empty headers
    $headers.GetEnumerator() | ForEach-Object {
        if ([string]::IsNullOrEmpty($_.Value)) {
            $headers.Remove($_.Key)
        }
    }

    if (-not [string]::IsNullOrEmpty($AccessToken)) {
        switch -Regex ($AccessToken) {
            '^gh[pou]_' {
                $authorization = "token $AccessToken"
            }
            '^ghu_' {
                $authorization = "Bearer $AccessToken" # GitHubApp access token
            }
        }

        $headers['Authorization'] = $authorization
    }

    # Avoid replacing 'https://' slashes while ensuring correct URL formation
    $URI = "$ApiBaseUri".TrimEnd('/') + "/$ApiEndpoint".TrimStart('/')

    $APICall = @{
        Uri     = $URI
        Method  = $Method
        Headers = $Headers
    }

    # Set body depending on the type of Body (string or hashtable)
    if ($Body -is [string]) {
        $APICall['Body'] = $Body
    } elseif ($Body -is [hashtable]) {
        $APICall['Body'] = ($Body | ConvertTo-Json -Depth 100)
    }

    try {
        Write-Verbose ($APICall.GetEnumerator() | Out-String)

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
