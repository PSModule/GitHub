[CmdletBinding()]
Param(
    # Path to the module to test.
    [Parameter()]
    [string] $Path
)

Write-Verbose "Path to the module: [$Path]" -Verbose

Describe 'GitHub' {
    Context 'Private function: Remove-HashtableEntry' {
        It 'Remove-HashtableEntry -Hashtable $headers -NullOrEmptyValues' {
            $headers = @{
                Accept                 = 'application/vnd.github+json; charset=utf-8'
                'X-GitHub-Api-Version' = '2022-11-28'
            }

            { Remove-HashtableEntry -Hashtable $headers -NullOrEmptyValues } | Should -Not -Throw
        }
        It '$APICall | Remove-HashtableEntry -NullOrEmptyValues' {
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

            #If PSversion is higher than 7.1 use HttpVersion
            if ($PSVersionTable.PSVersion -ge [version]'7.3') {
                $APICall['HttpVersion'] = $HttpVersion
            }

            $APICall | Remove-HashtableEntry -NullOrEmptyValues
        }
    }
    Context 'Invoke-GitHubAPI' {
        It 'Invoke-GitHubAPI function exists' {
            Get-Command Invoke-GitHubAPI | Should -Not -BeNullOrEmpty
        }

        It 'Can be called directly to get ratelimits' {
            $inputObject = @{
                APIEndpoint = '/rate_limit'
                Method      = 'GET'
            }

            $response = Invoke-GitHubAPI @inputObject

            $response | Should -Not -BeNullOrEmpty
            $response.Response.rate | Should -Not -BeNullOrEmpty
            $response.Response.resources.core | Should -Not -BeNullOrEmpty
        }
    }
}
