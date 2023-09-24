function Invoke-GitHubAPI {
    [CmdletBinding(DefaultParameterSetName = 'Body')]
    param (
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE', 'PUT')]
        [String] $Method = 'GET',

        [Parameter()]
        [string] $APIBaseURI = $script:Config.App.API.BaseURI,

        [Parameter(Mandatory)]
        [string] $APIEndpoint,

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

    $headers = @{}

    if (-not [string]::IsNullOrEmpty($ContentType)) {
        $headers += @{
            'Content-Type' = $ContentType
        }
    }

    if (-not [string]::IsNullOrEmpty($Version)) {
        $headers += @{
            'X-GitHub-Api-Version' = $Version
        }
    }

    if (-not [string]::IsNullOrEmpty($Accept)) {
        $headers += @{
            'Accept' = $Accept
        }
    }

    if (-not [string]::IsNullOrEmpty($AccessToken)) {
        switch -Regex ($AccessToken) {
            '^ghp_' {
                $authorization = "token $AccessToken"  # Classic tokens
            }
            '^github_pat_' {
                $authorization = "token $AccessToken"  # Fine-grained PAT
            }
            '^ghu_' {
                $authorization = "Bearer $AccessToken" # GitHubApp access token
            }
            '^gho_' {
                $authorization = "Bearer $AccessToken" # OAuth app access token
            }
        }

        $headers += @{
            Authorization = $authorization
        }
    }

    $URI = "$APIBaseURI$($APIEndpoint.Replace('\', '/').Replace('//', '/'))"

    $APICall = @{
        Uri     = $URI
        Method  = $Method
        Headers = $Headers
    }

    if ($PSBoundParameters.ContainsKey('Body')) {
        $APICall += @{
            Body = ($Body | ConvertTo-Json -Depth 100)
        }
    }

    if ($PSBoundParameters.ContainsKey('Data')) {
        $APICall += @{
            Body = $Data
        }
    }

    try {
        Write-Verbose ($APICall.GetEnumerator() | Out-String)

        if ($UseWebRequest) {
            return Invoke-WebRequest @APICall
        }

        Invoke-RestMethod @APICall
    } catch {
        Write-Error $_
        throw $_
    }
}
