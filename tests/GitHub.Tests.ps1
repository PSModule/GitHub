[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

BeforeAll {
    Connect-GitHub
}

Describe 'GitHub' {
    Context 'Invoke-GitHubAPI' {
        It 'Invoke-GitHubAPI function exists' {
            Get-Command Invoke-GitHubAPI | Should -Not -BeNullOrEmpty
        }

        It 'Can be called directly to get ratelimits' {
            $ApiBaseUri = Get-GitHubConfig -Name ApiBaseUri
            $ApiEndpoint = '/rate_limit'
            $Method = 'GET'
            $headers = @{
                Accept                 = $Accept
                'X-GitHub-Api-Version' = $Version
            }

            Remove-HashtableEntry -Hashtable $headers -NullOrEmptyValues

            $URI = ("$ApiBaseUri/" -replace '/$', '') + ("/$ApiEndpoint" -replace '^/', '')

            $APICallStatusCode = $null
            $APICallResponseHeaders = $null

            $APICall = @{
                Uri                     = $URI
                Method                  = $Method
                Headers                 = $Headers
                Authentication          = 'Bearer'
                Token                   = $AccessToken
                ContentType             = $ContentType
                FollowRelLink           = $FollowRelLink
                StatusCodeVariable      = 'APICallStatusCode'
                ResponseHeadersVariable = 'APICallResponseHeaders'
                InFile                  = $UploadFilePath
                OutFile                 = $DownloadFilePath
            }

            $currentVersion = $PSVersionTable.PSVersion
            $LaterThanSevenThree = $currentVersion -ge [version]'7.3'

            Write-Verbose "currentVersion:      $currentVersion" -Verbose
            Write-Verbose "LaterThanSevenThree: $LaterThanSevenThree" -Verbose

            #If PSversion is higher than 7.1 use HttpVersion
            if ($PSVersionTable.PSVersion -ge [version]'7.3') {
                $APICall['HttpVersion'] = $HttpVersion
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

            Invoke-RestMethod @APICall

            $response | Should -Not -BeNullOrEmpty
            $response.Response.rate | Should -Not -BeNullOrEmpty
            $response.Response.resources.core | Should -Not -BeNullOrEmpty
        }
    }
}
