#Requires -Modules @{ ModuleName = 'Uri'; RequiredVersion = '1.1.0' }
#Requires -Modules @{ ModuleName = 'Hashtable'; RequiredVersion = '1.1.5' }

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

        .LINK
        https://psmodule.io/GitHub/Functions/API/Invoke-GitHubAPI
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
        [object] $Body,

        # The 'Accept' header for the API request. If not provided, the default will be used by GitHub's API.
        [Parameter()]
        [string] $Accept = 'application/vnd.github+json; charset=utf-8',

        # Specifies the HTTP version used for the request.
        [Parameter()]
        [string] $HttpVersion,

        # The file path to be used for the API request. This is used for uploading files.
        [Parameter()]
        [string] $UploadFilePath,

        # The full URI for the API request. This is used for custom API calls.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Uri'
        )]
        [string] $Uri,

        # The 'Content-Type' header for the API request. The default is 'application/vnd.github+json'.
        [Parameter()]
        [string] $ContentType = 'application/vnd.github+json; charset=utf-8',

        # The GitHub API version to be used. By default, it pulls from a configuration script variable.
        [Parameter()]
        [string] $ApiVersion,

        # Specifies how many times PowerShell retries a connection when a failure code between 400 and 599, inclusive or 304 is received.
        [Parameter()]
        [System.Nullable[int]] $RetryCount,

        # Specifies the interval between retries for the connection when a failure code between 400 and 599, inclusive or 304 is received.
        # When the failure code is 429 and the response includes the Retry-After property in its headers, the cmdlet uses that value for the retry
        # interval, even if this parameter is specified.
        [Parameter()]
        [System.Nullable[int]] $RetryInterval,

        # The number of results per page for paginated GitHub API responses.
        [Parameter()]
        [System.Nullable[int]] $PerPage,

        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $debug = $DebugPreference -eq 'Continue'
        $Context = Resolve-GitHubContext -Context $Context
        if ($debug) {
            Write-Debug 'Invoking GitHub API...'
            Write-Debug 'Parent function parameters:'
            Get-FunctionParameter -Scope 1 | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
            Write-Debug 'Parameters:'
            Get-FunctionParameter | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        }
    }

    process {
        $Token = $Context.Token

        $HttpVersion = Resolve-GitHubContextSetting -Name 'HttpVersion' -Value $HttpVersion -Context $Context
        $ApiBaseUri = Resolve-GitHubContextSetting -Name 'ApiBaseUri' -Value $ApiBaseUri -Context $Context
        $ApiVersion = Resolve-GitHubContextSetting -Name 'ApiVersion' -Value $ApiVersion -Context $Context
        $RetryCount = Resolve-GitHubContextSetting -Name 'RetryCount' -Value $RetryCount -Context $Context
        $RetryInterval = Resolve-GitHubContextSetting -Name 'RetryInterval' -Value $RetryInterval -Context $Context
        $TokenType = Resolve-GitHubContextSetting -Name 'TokenType' -Value $TokenType -Context $Context
        if ($debug) {
            [pscustomobject]@{
                Token       = $Token
                HttpVersion = $HttpVersion
                ApiBaseUri  = $ApiBaseUri
                ApiVersion  = $ApiVersion
                TokenType   = $TokenType
            } | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        }
        $jwt = $null
        switch ($TokenType) {
            'ghu' {
                if (Test-GitHubAccessTokenRefreshRequired -Context $Context) {
                    $Token = Update-GitHubUserAccessToken -Context $Context -PassThru
                }
            }
            'PEM' {
                $jwt = Get-GitHubAppJSONWebToken -ClientId $Context.ClientID -PrivateKey $Context.Token
                $Token = $jwt.Token
            }
        }

        $headers = @{
            Accept                 = $Accept
            'X-GitHub-Api-Version' = $ApiVersion
            'User-Agent'           = "PSModule.GitHub $($script:PSModuleInfo.ModuleVersion)"
        }
        $headers | Remove-HashtableEntry -NullOrEmptyValues

        if (-not $Uri) {
            $Uri = New-Uri -BaseUri $ApiBaseUri -Path $ApiEndpoint -AsString
            $Uri = $Uri -replace '//$', '/'
        }

        $APICall = @{
            Uri               = $Uri
            Method            = [string]$Method
            Headers           = $Headers
            ContentType       = $ContentType
            InFile            = $UploadFilePath
            HttpVersion       = [string]$HttpVersion
            MaximumRetryCount = $RetryCount
            RetryIntervalSec  = $RetryInterval
        }
        $APICall | Remove-HashtableEntry -NullOrEmptyValues

        if (-not $Anonymous -and $Context -ne 'Anonymous' -and -not [string]::IsNullOrEmpty($Context)) {
            $APICall['Authentication'] = 'Bearer'
            $APICall['Token'] = $Token
        }

        if ($Method -eq 'GET') {
            if (-not $Body) {
                $Body = @{}
            }
            $Body['per_page'] = Resolve-GitHubContextSetting -Name 'PerPage' -Value $PerPage -Context $Context
            $APICall.Uri = New-Uri -BaseUri $Uri -Query $Body -AsString
        } elseif (($Method -eq 'POST') -and -not [string]::IsNullOrEmpty($UploadFilePath)) {
            $APICall.Uri = New-Uri -BaseUri $Uri -Query $Body -AsString
        } elseif ($Body) {
            if ($Body -is [hashtable]) {
                $APICall.Body = $Body | ConvertTo-Json -Depth 100
            } else {
                $APICall.Body = $Body
            }
        }

        try {
            if ($debug) {
                Write-Debug '----------------------------------'
                Write-Debug 'Request:'
                [pscustomobject]$APICall | Select-Object -ExcludeProperty Body, Headers | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                Write-Debug '----------------------------------'
                Write-Debug 'Request headers:'
                $APICall.Headers | Select-Object * | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                Write-Debug '----------------------------------'
                Write-Debug 'Request body:'
                $APICall.Body | Out-String -Stream | ForEach-Object {
                    $bodyContent = $_
                    $bodyContent = $bodyContent -split '\n'
                    foreach ($item in $bodyContent) { Write-Debug $item }
                }
                Write-Debug '----------------------------------'
            }
            do {
                switch ($TokenType) {
                    'ghu' {
                        if (Test-GitHubAccessTokenRefreshRequired -Context $Context) {
                            $Token = Update-GitHubUserAccessToken -Context $Context -PassThru
                        }
                    }
                    'PEM' {
                        if ($jwt.ExpiresAt -lt (Get-Date)) {
                            $jwt = Get-GitHubAppJSONWebToken -ClientId $Context.ClientID -PrivateKey $Context.Token
                            $Token = $jwt.Token
                            $APICall['Token'] = $Token
                        }
                    }
                }
                $response = Invoke-WebRequest @APICall -ProgressAction 'SilentlyContinue'

                $headers = @{}
                foreach ($item in $response.Headers.GetEnumerator()) {
                    $headers[$item.Key] = ($item.Value).Trim() -join ', '
                }
                $headers = [pscustomobject]$headers
                $sortedProperties = $headers.PSObject.Properties.Name | Sort-Object
                $headers = $headers | Select-Object $sortedProperties
                if ($headers.'x-ratelimit-reset') {
                    $headers.'x-ratelimit-reset' = [DateTime]::UnixEpoch.AddSeconds(
                        $headers.'x-ratelimit-reset'
                    ).ToLocalTime().ToString('s')
                }
                if ($headers.'Date') {
                    $headers.'Date' = [DateTime]::Parse(
                        ($headers.'Date').Replace('UTC', '').Trim()
                    ).ToLocalTime().ToString('s')
                }
                if ($headers.'github-authentication-token-expiration') {
                    $headers.'github-authentication-token-expiration' = [DateTime]::Parse(
                        ($headers.'github-authentication-token-expiration').Replace('UTC', '').Trim()
                    ).ToLocalTime().ToString('s')
                }
                if ($debug) {
                    Write-Debug '----------------------------------'
                    Write-Debug 'Response:'
                    $response | Select-Object -ExcludeProperty Content, Headers | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                    Write-Debug '---------------------------'
                    Write-Debug 'Response headers:'
                    $headers | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                    Write-Debug '---------------------------'
                }
                switch -Regex ($headers.'Content-Type') {
                    'application/.*json' {
                        $results = $response.Content | ConvertFrom-Json
                    }
                    'application/octocat-stream' {
                        [byte[]]$byteArray = $response.Content
                        $results = [System.Text.Encoding]::UTF8.GetString($byteArray)
                    }
                    default {
                        $results = $response.Content
                    }
                }

                if ($debug) {
                    Write-Debug 'Response content:'
                    $results | ConvertTo-Json -Depth 5 -WarningAction SilentlyContinue | Out-String -Stream | ForEach-Object {
                        $content = $_
                        $content = $content -split '\n'
                        foreach ($item in $content) {
                            Write-Debug $item
                        }
                    }
                    Write-Debug '---------------------------'
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
            if ($debug) {
                Write-Debug '----------------------------------'
                Write-Debug 'Failure:'
                $failure | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                Write-Debug '----------------------------------'
            }
            $headers = @{}
            foreach ($item in $failure.Exception.Response.Headers.GetEnumerator()) {
                $headers[$item.Key] = ($item.Value).Trim() -join ', '
            }
            $headers = [pscustomobject]$headers
            if ($headers.'x-ratelimit-reset') {
                $headers.'x-ratelimit-reset' = [DateTime]::UnixEpoch.AddSeconds(
                    $headers.'x-ratelimit-reset'
                ).ToLocalTime().ToString('s')
            }
            if ($headers.'Date') {
                $headers.'Date' = [DateTime]::Parse(
                    ($headers.'Date').Replace('UTC', '').Trim()
                ).ToLocalTime().ToString('s')
            }
            if ($headers.'github-authentication-token-expiration') {
                $headers.'github-authentication-token-expiration' = [DateTime]::Parse(
                    ($headers.'github-authentication-token-expiration').Replace('UTC', '').Trim()
                ).ToLocalTime().ToString('s')
            }
            $sortedProperties = $headers.PSObject.Properties.Name | Sort-Object
            $headers = $headers | Select-Object $sortedProperties
            if ($debug) {
                Write-Debug 'Response headers:'
                $headers | Out-String -Stream | ForEach-Object { Write-Debug $_ }
                Write-Debug '---------------------------'
            }

            $errordetails = $failure.ErrorDetails | ConvertFrom-Json -AsHashtable
            $errors = $errordetails.errors
            $errorResult = [pscustomobject]@{
                Message     = $errordetails.message
                Resource    = $errors.resource
                Code        = $errors.code
                Details     = $errors.message
                Information = $errordetails.documentation_url
                Status      = $failure.Exception.Message
                StatusCode  = $errordetails.status
                ErrorTime   = Get-Date -Format 's'
            }

            $exception = @"
----------------------------------
Request:
$([pscustomobject]$APICall | Select-Object -ExcludeProperty Body, Headers | Format-List | Out-String -Stream)
----------------------------------
Request headers:
$($APICall.Headers | Select-Object * | Out-String -Stream)
----------------------------------
Request body:
$($APICall.Body | ConvertTo-Json -Depth 10 | Out-String -Stream | ForEach-Object {
    $content = $_
    $content -split '\n'
    $content | ForEach-Object { $_.Trim() }
})
----------------------------------
Response headers:
$($headers | Format-List | Out-String)
----------------------------------
Error:
$($errorResult | Format-List | Out-String)
----------------------------------

"@
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    [System.Exception]::new($exception),
                    'GitHubAPIError',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $errorResult
                )
            )
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
