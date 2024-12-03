filter Invoke-GitHubAPI {
    <#
        .SYNOPSIS
        Calls the GitHub API using the provided parameters.

        .DESCRIPTION
        This function is a wrapper around Invoke-RestMethod tailored for calling GitHub's API.
        It automatically handles the endpoint URI construction, headers, and token authentication.

        .EXAMPLE
        Invoke-GitHubAPI -ApiEndpoint '/repos/user/repo/pulls' -Method GET

        Gets all open pull requests for the specified repository.

        .EXAMPLE
        Invoke-GitHubAPI -ApiEndpoint '/repos/user/repo/pulls' -Method GET -Body @{ state = 'open' }

        Gets all open pull requests for the specified repository, filtered by the 'state' parameter.

        .EXAMPLE
        Invoke-GitHubAPI -ApiEndpoint '/repos/user/repo/pulls' -Method GET -Body @{ state = 'open' } -Accept 'application/vnd.github.v3+json'

        Gets all open pull requests for the specified repository, filtered by the 'state' parameter, and using the specified 'Accept' header.
    #>
    [CmdletBinding(DefaultParameterSetName = 'ApiEndpoint')]
    param (
        # The HTTP method to be used for the API request. It can be one of the following: GET, POST, PUT, DELETE, or PATCH.
        [Parameter()]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method = 'GET',

        # The base URI for the GitHub API. This is usually `https://api.github.com`, but can be adjusted if necessary.
        [Parameter(
            ParameterSetName = 'ApiEndpoint'
        )]
        [string] $ApiBaseUri,

        # The specific endpoint for the API call, e.g., '/repos/user/repo/pulls'.
        [Parameter(
            Mandatory,
            ParameterSetName = 'ApiEndpoint'
        )]
        [string] $ApiEndpoint,

        # The body of the API request. This can be a hashtable or a string. If a hashtable is provided, it will be converted to JSON.
        [Parameter()]
        [Object] $Body,

        # The 'Accept' header for the API request. If not provided, the default will be used by GitHub's API.
        [Parameter()]
        [string] $Accept = 'application/vnd.github+json; charset=utf-8',

        # Specifies the HTTP version used for the request.
        [Parameter()]
        [version] $HttpVersion = '2.0',

        # Support Pagination Relation Links per RFC5988.
        [Parameter()]
        [bool] $FollowRelLink = $true,

        # The file path to be used for the API request. This is used for uploading files.
        [Parameter()]
        [string] $UploadFilePath,

        # The file path to be used for the API response. This is used for downloading files.
        [Parameter()]
        [string] $DownloadFilePath,

        # The full URI for the API request. This is used for custom API calls.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Uri'
        )]
        [string] $URI,

        # The secure token used for authentication in the GitHub API. It should be stored as a SecureString to ensure it's kept safe in memory.
        [Parameter()]
        [SecureString] $Token,

        # The 'Content-Type' header for the API request. The default is 'application/vnd.github+json'.
        [Parameter()]
        [string] $ContentType = 'application/vnd.github+json; charset=utf-8',

        # The GitHub API version to be used. By default, it pulls from a configuration script variable.
        [Parameter()]
        [string] $ApiVersion,

        # The context to use for the API call. This is used to retrieve the necessary configuration settings.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    Write-Verbose 'Invoking GitHub API...'
    $PSBoundParameters.GetEnumerator() | ForEach-Object {
        Write-Verbose " - $($_.Key): $($_.Value)"
    }

    $contextObj = Get-GitHubContext -Name $Context
    Write-Verbose "Using GitHub context: $Context"
    if (-not $contextObj) {
        throw 'Log in using Connect-GitHub before running this command.'
    }

    if ([string]::IsNullOrEmpty($ApiBaseUri)) {
        Write-Verbose 'Using default API base URI from context.'
        Write-Verbose $($contextObj.ApiBaseUri)
        $ApiBaseUri = $contextObj.ApiBaseUri
    }
    Write-Verbose "ApiBaseUri: $ApiBaseUri"

    if ([string]::IsNullOrEmpty($ApiVersion)) {
        Write-Verbose 'Using default API version from context.'
        Write-Verbose $($contextObj.ApiVersion)
        $ApiVersion = $contextObj.ApiVersion
    }
    Write-Verbose "ApiVersion: $ApiVersion"

    if ([string]::IsNullOrEmpty($TokenType)) {
        Write-Verbose 'Using default token type from context.'
        Write-Verbose $($contextObj.TokenType)
        $TokenType = $contextObj.TokenType
    }
    Write-Verbose "TokenType:  $TokenType"

    if ([string]::IsNullOrEmpty($Token)) {
        Write-Verbose 'Using default token from context.'
        Write-Verbose $($contextObj.Token)
        $Token = $contextObj.Token
    }
    Write-Verbose "Token:     $Token"

    switch ($tokenType) {
        'ghu' {
            if (Test-GitHubAccessTokenRefreshRequired -Context $Context) {
                Connect-GitHubAccount -Silent
                $Token = (Get-GitHubContextSetting -Name 'Token' -Context $Context)
            }
        }
        'PEM' {
            $ClientID = (Get-GitHubContextSetting -Name 'ClientID' -Context $Context)
            $JWT = Get-GitHubAppJSONWebToken -ClientId $ClientID -PrivateKey $Token
            $Token = $JWT.Token
        }
    }

    $headers = @{
        Accept                 = $Accept
        'X-GitHub-Api-Version' = $ApiVersion
    }

    Remove-HashtableEntry -Hashtable $headers -NullOrEmptyValues

    if (-not $URI) {
        $URI = ("$ApiBaseUri/" -replace '/$', '') + ("/$ApiEndpoint" -replace '^/', '')
    }

    $APICall = @{
        Uri                     = $URI
        Method                  = $Method
        Headers                 = $Headers
        Authentication          = 'Bearer'
        Token                   = $Token
        ContentType             = $ContentType
        FollowRelLink           = $FollowRelLink
        InFile                  = $UploadFilePath
        OutFile                 = $DownloadFilePath
        HttpVersion             = $HttpVersion
    }

    $APICall | Remove-HashtableEntry -NullOrEmptyValues

    if ($Body) {
        # Use body to create the query string for certain situations
        if ($Method -eq 'GET') {
            $queryString = $Body | ConvertTo-QueryString
            $APICall.Uri = $APICall.Uri + $queryString
        } elseif ($Body -is [string]) {
            # Use body to create the form data
            $APICall.Body = $Body
        } else {
            $APICall.Body = $Body | ConvertTo-Json -Depth 100
        }
    }

    try {
        Write-Verbose "----------------------------------"
        Write-Verbose "Request:"
        $APICall | ConvertFrom-HashTable | Format-List | Out-String -Stream | ForEach-Object { Write-Verbose $_ }
        Write-Verbose "----------------------------------"
        Invoke-RestMethod @APICall | ForEach-Object {
            [pscustomobject]@{
                Request         = $APICall
                Response        = $_
            }
        }
    } catch {
        $failure = $_
        $headers = @{}
        foreach ($item in $failure.Exception.Response.Headers) {
            $headers[$item.Key] = ($item.Value).Trim() -join ", "
        }
        $headers = [pscustomobject]$headers
        # Sort properties by name and display the object
        $sortedProperties = $headers.PSObject.Properties.Name | Sort-Object
        $headers = $headers | Select-Object $sortedProperties

        $errordetails = $failure.ErrorDetails | ConvertFrom-Json -AsHashtable
        $errorResult = [ordered]@{
            Message     = $errordetails.message
            Information = $errordetails.documentation_url
            Status      = $failure.Exception.Message
            StatusCode  = $errordetails.status
        }
        $APICall.HttpVersion = $APICall.HttpVersion.ToString()
        $APICall.Headers = $APICall.Headers | ConvertTo-Json
        $APICall.Method = $APICall.Method.ToString()

        Write-Error "----------------------------------"
        Write-Error "Error details:"
        $errorResult | Format-Table -AutoSize -HideTableHeaders | Out-String -Stream | ForEach-Object { Write-Error $_ }
        Write-Error "----------------------------------"
        Write-Debug "Response headers:"
        $headers | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        Write-Debug "---------------------------"
        throw $failure.Exception.Message
    }
}