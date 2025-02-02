function Invoke-GitHubRestMethod {
    <#
    .SYNOPSIS
        Executes request against GitHub API.

    .DESCRIPTION
        Private function to call GitHub API.

    .PARAMETER Uri
        A valid Uri

    .PARAMETER Body
        Body used for DELETE, PATCH, POST or PUT methods

    .PARAMETER ContentType
        Specifies the content type of the web request

    .PARAMETER ExpandProperty
        If specified and the property exists in the web response, this property will be expanded priot to output.

    .PARAMETER MaximumRetryCount
        Specifies how many times PowerShell retries a connection when a failure code between 400 and 599, inclusive or 304 is received. Also see RetryIntervalSec parameter for specifying number of retries.

    .PARAMETER Method
        HTTP Method

    .PARAMETER OutFile
        Saves the response body in the specified output file. Enter a path and file name. If you omit the path, the default is the current location. The name is treated as a literal path. Names that contain brackets (`[]`) must be enclosed in single quotes (`'`).

    .PARAMETER QueryParameters
        An IDictionary of query string parameters to add to the Uri via ConvertTo-QueryString.

    .PARAMETER ResponseHeadersVariable
         Creates a variable containing a Response Headers Dictionary. Enter a variable name without the dollar sign (`$`) symbol. The keys of the dictionary contain the field names and values of the Response Header returned by the web server.

    .PARAMETER RetryIntervalSec
        Specifies the interval between retries for the connection when a failure code between 400 and 599, inclusive or 304 is received. Also see MaximumRetryCount parameter for specifying number of retries. The value must be between `1` and `[int]::MaxValue`.

    .PARAMETER Token
        A valid GitHub personal access token.

    .EXAMPLE
        Invoke-GitHubRestMethod -Uri ''

    .LINK
        https://one.mkapps.com/Help/Invoke-GitHubRestMethod.html

    .LINK
        https://docs.github.com/en/rest/guides/using-pagination-in-the-rest-api?apiVersion=2022-11-28#using-link-headers
    #>
    [CmdletBinding(SupportsPaging)]
    param(
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

        [string]$ExpandProperty,

        $Body,
        [string]$ContentType = 'application/vnd.github+json',
        $Headers = @{},

        # Specifies the HTTP version used for the request.
        [Parameter()]
        [string] $HttpVersion,

        [int]$MaximumRetryCount,
        [Alias('UploadFilePath')]
        [string]$InFile,
        [Alias('DownloadFilePath')]
        [string]$OutFile,

        # The full URI for the API request. This is used for custom API calls.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Uri'
        )]
        [string] $URI,

        [Collections.IDictionary]
        $QueryParameters = @{},
        [string]$ResponseHeadersVariable,
        [int]$RetryIntervalSec,

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
        Write-Debug "Token :     [$Token]"

        if ([string]::IsNullOrEmpty($HttpVersion)) {
            $HttpVersion = $Context.HttpVersion
        }
        Write-Debug "HttpVersion: [$HttpVersion]"

        if ([string]::IsNullOrEmpty($ApiBaseUri)) {
            $ApiBaseUri = $Context.ApiBaseUri
        }
        Write-Debug "ApiBaseUri: [$ApiBaseUri]"

        if ([string]::IsNullOrEmpty($ApiVersion)) {
            $ApiVersion = $Context.ApiVersion
        }
        Write-Debug "ApiVersion: [$ApiVersion]"

        if ([string]::IsNullOrEmpty($TokenType)) {
            $TokenType = $Context.TokenType
        }
        Write-Debug "TokenType : [$TokenType]"

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
        if (-not $headers.Contains('Accept')) {
            $headers['Accept'] = 'application/vnd.github+json; charset=utf-8'
        }
        if (-not $headers.Contains('X-GitHub-Api-Version')) {
            $headers['X-GitHub-Api-Version'] = $ApiVersion
        }
        if (-not $URI) {
            $URI = ("$ApiBaseUri" -replace '/$'), ("$ApiEndpoint" -replace '^/') -join '/'
        }

        # SupportsPaging related settings
        if (-not $QueryParameters.Contains('per_page') -or $QueryParameters['per_page'] -lt 1 -or $QueryParameters['per_page'] -gt 100) {
            $QueryParameters['per_page'] = [Math]::Max($Context.PerPage, 100) # Valid range is 1-100
        }
        $_page = [int]($PSCmdlet.PagingParameters.Skip / $QueryParameters['per_page']) + 1
        $_index = ($_page - 1) * $QueryParameters['per_page'] # The number skipped by skipping page-1 pages
        $_max = $PSCmdlet.PagingParameters.Skip + $PSCmdlet.PagingParameters.First

        $irmParams = @{
            Authentication          = 'Bearer'
            ContentType             = $ContentType
            Headers                 = $Headers
            Method                  = $Method
            HttpVersion             = [string]$HttpVersion
            ResponseHeadersVariable = 'ResponseHeaders'
            SkipCertificateCheck    = $true
            StatusCodeVariable      = 'StatusCode'
            Token                   = $Token
            Uri                     = Join-UriAndQueryParameters -Uri $Uri -QueryParameters $QueryParameters
            Verbose                 = $false
        }
        foreach ($name in 'MaximumRetryCount', 'RetryIntervalSec') {
            if ($PSBoundParameters.ContainsKey($name)) {
                $irmParams[$name] = $PSBoundParameters[$name]
            }
        }
        if (-not [string]::IsNullOrWhitespace($InFile)) {
            $irmParams['InFile'] = $InFile
        }
        if (-not [string]::IsNullOrWhitespace($OutFile)) {
            $irmParams['OutFile'] = $OutFile
        }
        if ($Body) {
            # Use body to create the query string for certain situations
            if ($Method -eq 'GET') {
                # If body conatins 'per_page' and its is null, set it to $context.PerPage
                if ($Body['per_page'] -gt 0 -and $Body['per_page'] -le 100) {
                    Write-Debug "Setting per_page to the default value in context [$($Context.PerPage)]."
                    $QueryParameters['per_page'] = $Body['per_page']
                }
            } elseif ($Body -is [string]) {
                # Use body to create the form data
                $irmParams.Body = $Body
            } else {
                $irmParams.Body = $Body | ConvertTo-Json -Depth 100
            }
        }
        Write-Debug '----------------------------------'
        Write-Debug 'Request:'
        $irmParams | ConvertFrom-HashTable | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
        Write-Debug '----------------------------------'
        do {
            try {
                $result = Invoke-RestMethod @irmParams
                (Get-Variable -Name $script:GitHub.Config.HttpResponsesVariable -Scope Global).Value.Add(
                    [PSCustomObject]@{
                        Content    = $result
                        Date       = [datetime]::Now
                        Headers    = $ResponseHeaders
                        StatusCode = $StatusCode
                        Uri        = $URI
                    }
                )
                # 200 = OK, 201 = Created, 202 = Accepted, 204 = No Content
                if (200, 201, 202, 204 -contains $StatusCode) {
                    if ($result) {
                        # Use x-ms-continuationtoken Response Header to retrieve multiple pages iff we haven't received the max results yet
                        $irmParams.Uri = ($ResponseHeaders['Link'] -match 'rel="next"' -and (($_index + $result.Count) -lt $_max)) ?
                            ([Regex]::Match($ResponseHeaders['Link'] , '<(?<next>[^>]*)>; rel="next"').Groups['next'].Value) :
                            $null
                        if (-not [string]::IsNullOrWhiteSpace($ExpandProperty) -and $ExpandProperty -in $result.PSObject.Properties.Name) {
                            $result = $result | Select-Object -ExpandProperty $ExpandProperty
                        }
                        $result |
                        ForEach-Object {
                            $_index++
                            # SupportsPaging enforcement
                            if ($_index -gt $PSCmdlet.PagingParameters.Skip -and $_index -le $_max) {
                                $_
                            }
                        }
                    }
                    else {
                        $irmParams.Uri = $null
                    }
                }
                else {
                    Write-Error "[HTTP $($StatusCode)] $($result)"
                }
            }
            catch {
                $irmParams.Uri = $null
                if (304 -eq $_.Exception.Response.StatusCode.value__) {
                    # 304 = Not Modified
                }
                else {
                    throw
                }
            }
        } while ($null -ne $irmParams.Uri)
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
