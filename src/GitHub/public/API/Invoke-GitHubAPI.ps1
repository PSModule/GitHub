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

        # The base URI for the GitHub API. This is usually 'https://api.github.com', but can be adjusted if necessary.
        [Parameter(
            ParameterSetName = 'ApiEndpoint'
        )]
        [string] $ApiBaseUri = (Get-GitHubConfig -Name ApiBaseUri),

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
        [SecureString] $AccessToken = (Get-GitHubConfig -Name AccessToken),

        # The 'Content-Type' header for the API request. The default is 'application/vnd.github+json'.
        [Parameter()]
        [string] $ContentType = 'application/vnd.github+json; charset=utf-8',

        # The GitHub API version to be used. By default, it pulls from a configuration script variable.
        [Parameter()]
        [string] $Version = (Get-GitHubConfig -Name ApiVersion)
    )

    if (Test-GitHubAccessTokenRefreshRequired) {
        Connect-GitHubAccount -Silent
        $AccessToken = (Get-GitHubConfig -Name AccessToken)
    }

    $functionName = $MyInvocation.MyCommand.Name

    $headers = @{
        Accept                 = $Accept
        'X-GitHub-Api-Version' = $Version
    }

    Remove-HashTableEntries -Hashtable $headers -NullOrEmptyValues

    if (-not $URI) {
        $URI = ("$ApiBaseUri/" -replace '/$', '') + ("/$ApiEndpoint" -replace '^/', '')
    }

    # $AccessTokenAsPlainText = ConvertFrom-SecureString $AccessToken -AsPlainText
    # # Swap out this by using the -Authentication Bearer -Token $AccessToken
    # switch -Regex ($AccessTokenAsPlainText) {
    #     '^ghp_|^github_pat_' {
    #         $headers.authorization = "token $AccessTokenAsPlainText"
    #     }
    #     '^ghu_|^gho_' {
    #         $headers.authorization = "Bearer $AccessTokenAsPlainText"
    #     }
    #     default {
    #         $tokenPrefix = $AccessTokenAsPlainText -replace '_.*$', '_*'
    #         $errorMessage = "Unexpected AccessToken format: $tokenPrefix"
    #         Write-Error $errorMessage
    #         throw $errorMessage
    #     }
    # }

    $APICall = @{
        Uri                     = $URI
        Method                  = $Method
        Headers                 = $Headers
        Authentication          = 'Bearer'
        Token                   = $AccessToken
        ContentType             = $ContentType
        HttpVersion             = $HttpVersion
        FollowRelLink           = $FollowRelLink
        StatusCodeVariable      = 'APICallStatusCode'
        ResponseHeadersVariable = 'APICallResponseHeaders'
        InFile                  = $UploadFilePath
        OutFile                 = $DownloadFilePath
    }

    $APICall | Remove-HashTableEntries -NullOrEmptyValues

    if ($Body) {
        # Use body to create the query string for GET requests
        if (($Method -eq 'GET') -or (-not [string]::IsNullOrEmpty($UploadFilePath))) {
            $queryString = $Body | ConvertTo-QueryString
            $APICall.Uri = $APICall.Uri + $queryString
        } elseif ($Body -is [string]) { # Use body to create the form data
            $APICall.Body = $Body
        } else {
            $APICall.Body = $Body | ConvertTo-Json -Depth 100
        }
    }

    Invoke-RestMethod @APICall | ForEach-Object {
        $statusCode = $APICallStatusCode | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        $responseHeaders = $APICallResponseHeaders | ConvertTo-Json -Depth 100 | ConvertFrom-Json
        [pscustomobject]@{
            Request         = $APICall
            Response        = $_
            StatusCode      = $statusCode
            ResponseHeaders = $responseHeaders
        }
    }
}
