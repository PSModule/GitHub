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
            $AccessToken = Get-GitHubConfig -Name AccessToken
            $encryptedString = $AccessToken | ConvertFrom-SecureString
            $secureStringRecovered = $encryptedString | ConvertTo-SecureString
            $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureStringRecovered))
            $headers = @{
                Accept                 = 'application/vnd.github+json; charset=utf-8'
                'X-GitHub-Api-Version' = Get-GitHubConfig -Name ApiVersion
                'Authorization'        = "Bearer $token"
            }

            Remove-HashtableEntry -Hashtable $headers -NullOrEmptyValues

            $ApiBaseUri = Get-GitHubConfig -Name ApiBaseUri
            $ApiEndpoint = '/rate_limit'
            $URI = ("$ApiBaseUri/" -replace '/$', '') + ("/$ApiEndpoint" -replace '^/', '')

            $APICall = @{
                Uri         = $URI
                Method      = 'GET'
                Headers     = $Headers
                ContentType = 'application/vnd.github+json; charset=utf-8'
                InFile      = $UploadFilePath
                OutFile     = $DownloadFilePath
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
            Write-Verbose ($APICall | ConvertTo-Json -Depth 100) -Verbose
            $response = Invoke-WebRequest @APICall

            Write-Verbose ($response | ConvertTo-Json -Depth 100) -Verbose

            $response | Should -Not -BeNullOrEmpty
        }
    }
}
