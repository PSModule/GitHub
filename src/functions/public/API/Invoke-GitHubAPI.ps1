﻿#Requires -Modules @{ ModuleName = 'Web'; RequiredVersion = '1.0.0' }

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
    param(
        # The HTTP method to be used for the API request. It can be one of the following: GET, POST, PUT, DELETE, or PATCH.
        [Parameter()]
        [ValidateSet('GET', 'POST', 'PUT', 'DELETE', 'PATCH')]
        $Method = 'GET',

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
        [Alias('Query')]
        [Object] $Body,

        # The 'Accept' header for the API request. If not provided, the default will be used by GitHub's API.
        [Parameter()]
        [string] $Accept = 'application/vnd.github+json; charset=utf-8',

        # Specifies the HTTP version used for the request.
        [Parameter()]
        [string] $HttpVersion,

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

        # The 'Content-Type' header for the API request. The default is 'application/vnd.github+json'.
        [Parameter()]
        [string] $ContentType = 'application/vnd.github+json; charset=utf-8',

        # The GitHub API version to be used. By default, it pulls from a configuration script variable.
        [Parameter()]
        [string] $ApiVersion,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Write-Debug 'Invoking GitHub API...'
        Write-Debug 'Parameters:'
        Get-FunctionParameter | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        Write-Debug 'Parent function parameters:'
        Get-FunctionParameter -Scope 1 | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
    }

    process {
        $Token = $Context.Token
        Write-Debug "Token :      [$Token]"

        if ([string]::IsNullOrEmpty($HttpVersion)) {
            $HttpVersion = $Context.HttpVersion
        }
        Write-Debug "HttpVersion: [$HttpVersion]"

        if ([string]::IsNullOrEmpty($ApiBaseUri)) {
            $ApiBaseUri = $Context.ApiBaseUri
        }
        Write-Debug "ApiBaseUri:  [$ApiBaseUri]"

        if ([string]::IsNullOrEmpty($ApiVersion)) {
            $ApiVersion = $Context.ApiVersion
        }
        Write-Debug "ApiVersion:  [$ApiVersion]"

        if ([string]::IsNullOrEmpty($TokenType)) {
            $TokenType = $Context.TokenType
        }
        Write-Debug "TokenType :  [$TokenType]"

        switch ($TokenType) {
            'ghu' {
                if (Test-GitHubAccessTokenRefreshRequired -Context $Context) {
                    $Token = Update-GitHubUserAccessToken -Context $Context -PassThru
                }
            }
            'PEM' {
                $JWT = Get-GitHubAppJSONWebToken -ClientId $Context.ClientID -PrivateKey $Token
                $Token = $JWT.Token
            }
        }

        $headers = @{
            Accept                 = $Accept
            'X-GitHub-Api-Version' = $ApiVersion
        }
        $headers | Remove-HashtableEntry -NullOrEmptyValues

        if (-not $URI) {
            $URI = ("$ApiBaseUri" -replace '/$'), ("$ApiEndpoint" -replace '^/') -join '/'
        }

        $APICall = @{
            Uri            = $URI
            Method         = [string]$Method
            Headers        = $Headers
            Authentication = 'Bearer'
            Token          = $Token
            ContentType    = $ContentType
            InFile         = $UploadFilePath
            OutFile        = $DownloadFilePath
            HttpVersion    = [string]$HttpVersion
        }
        $APICall | Remove-HashtableEntry -NullOrEmptyValues

        if ($Body) {
            # Use body to create the query string for certain situations
            if ($Method -eq 'GET') {
                # If body conatins 'per_page' and its is null, set it to $context.PerPage
                if ($Body['per_page'] -eq 0) {
                    Write-Debug "Setting per_page to the default value in context [$($Context.PerPage)]."
                    $Body['per_page'] = $Context.PerPage
                }
                $queryString = $Body | ConvertTo-WebQueryString
                $APICall.Uri = $APICall.Uri + $queryString
            } elseif ($Body -is [string]) {
                # Use body to create the form data
                $APICall.Body = $Body
            } else {
                $APICall.Body = $Body | ConvertTo-Json -Depth 100
            }
        }

        try {
            Write-Debug '----------------------------------'
            Write-Debug 'Request:'
            $APICall | ConvertFrom-HashTable | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
            Write-Debug '----------------------------------'
            do {
                $response = Invoke-WebRequest @APICall

                $headers = @{}
                foreach ($item in $response.Headers.GetEnumerator()) {
                    $headers[$item.Key] = ($item.Value).Trim() -join ', '
                }
                $headers = [pscustomobject]$headers
                $sortedProperties = $headers.PSObject.Properties.Name | Sort-Object
                $headers = $headers | Select-Object $sortedProperties
                Write-Debug '----------------------------------'
                Write-Debug 'Response headers:'
                $headers | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                Write-Debug '---------------------------'
                Write-Debug 'Response:'
                $response | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                Write-Debug '---------------------------'
                switch -Regex ($headers.'Content-Type') {
                    'application/.*json' {
                        $results = $response.Content | ConvertFrom-Json
                    }
                    'text/plain' {
                        $results = $response.Content
                    }
                    'text/html' {
                        $results = $response.Content
                    }
                    'application/octocat-stream' {
                        [byte[]]$byteArray = $response.Content
                        $results = [System.Text.Encoding]::UTF8.GetString($byteArray)
                    }
                    default {
                        if (-not $response.Content) {
                            $results = $null
                            break
                        }
                        Write-Warning "Unknown content type: $($headers.'Content-Type')"
                        Write-Warning 'Please report this issue!'
                        [byte[]]$byteArray = $response.Content
                        $results = [System.Text.Encoding]::UTF8.GetString($byteArray)
                    }
                }
                [pscustomobject]@{
                    Request           = $APICall
                    Response          = $results
                    Headers           = $headers
                    StatusCode        = $response.StatusCode
                    StatusDescription = $response.StatusDescription
                }
                $APICall['Uri'] = $response.RelationLink.next
            } while ($APICall['Uri'])
        } catch {
            $failure = $_
            $headers = @{}
            foreach ($item in $failure.Exception.Response.Headers.GetEnumerator()) {
                $headers[$item.Key] = ($item.Value).Trim() -join ', '
            }
            $headers = [pscustomobject]$headers
            if ($headers.'x-ratelimit-reset') {
                $headers.'x-ratelimit-reset' = [DateTime]::UnixEpoch.AddSeconds($headers.'x-ratelimit-reset').ToString('s')
            }
            if ($headers.'Date') {
                $headers.'Date' = [DateTime]::Parse(($headers.'Date').Replace('UTC', '').Trim()).ToString('s')
            }
            if ($headers.'github-authentication-token-expiration') {
                $headers.'github-authentication-token-expiration' = [DateTime]::Parse(($headers.'github-authentication-token-expiration').Replace('UTC', '').Trim()).ToString('s')
            }
            $sortedProperties = $headers.PSObject.Properties.Name | Sort-Object
            $headers = $headers | Select-Object $sortedProperties
            Write-Debug 'Response headers:'
            $headers | Out-String -Stream | ForEach-Object { Write-Debug $_ }
            Write-Debug '---------------------------'

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

            $errorResult = @"
----------------------------------
Error details:
$($errorResult | Format-Table -AutoSize -HideTableHeaders | Out-String)
----------------------------------
"@
            Write-Error $errorResult
            throw $failure.Exception.Message
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
