function Invoke-GitHubAPI {
    [CmdletBinding(DefaultParameterSetName = 'Body')]
    param (
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE', 'PUT')]
        [String] $Method = 'GET',

        [Parameter()]
        [string] $ApiBaseUri = $script:Config.App.API.BaseURI,

        [Parameter(Mandatory)]
        [string] $ApiEndpoint,

        [Parameter(ParameterSetName = 'Body')]
        [hashtable] $Body,

        [Parameter(ParameterSetName = 'Data')]
        [string] $Data,

        [Parameter()]
        [string] $Accept,

        [Parameter()]
        [string] $AccessToken = $script:Config.User.Auth.AccessToken.Value,

        [Parameter()]
        [string] $ContentType = 'application/vnd.github+json',

        [Parameter()]
        [string] $Version = $script:Config.App.API.Version,

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

    $URI = "$ApiBaseUri/$($ApiEndpoint.TrimStart('/'))"

    $APICall = @{
        Uri     = $URI
        Method  = $Method
        Headers = $Headers
    }

    # Set body from either Body or Data parameter
    if ($PSBoundParameters.ContainsKey('Body')) {
        $APICall['Body'] = ($Body | ConvertTo-Json -Depth 100)
    } elseif ($PSBoundParameters.ContainsKey('Data')) {
        $APICall['Body'] = $Data
    }

    try {
        Write-Verbose ($APICall.GetEnumerator() | Out-String)

        if ($UseWebRequest) {
            return Invoke-WebRequest @APICall
        }

        Invoke-RestMethod @APICall
    } catch {
        $errorMessage = "Error calling GitHub API: $($_.Exception.Message)"
        Write-Error $errorMessage
        throw $_
    }
}
