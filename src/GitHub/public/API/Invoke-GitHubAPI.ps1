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
            '^ghp_' {
                $authorization = "token $AccessToken"  # Classic tokens
                break
            }
            '^github_pat_' {
                $authorization = "token $AccessToken"  # Fine-grained PAT
                break
            }
            '^ghu_' {
                $authorization = "Bearer $AccessToken" # GitHubApp access token
                break
            }
            '^gho_' {
                $authorization = "Bearer $AccessToken" # OAuth app access token
                break
            }
            default {
                $tokenPrefix = $AccessToken.Substring(0, $AccessToken.LastIndexOf('_') + 1)
                $errorMessage = "Unexpected AccessToken format: $tokenPrefix*"
                Write-Error $errorMessage
                throw $errorMessage
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
