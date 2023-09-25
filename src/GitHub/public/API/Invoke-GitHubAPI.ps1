﻿function Invoke-GitHubAPI {
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
    [CmdletBinding()]
    param (
        # The HTTP method to be used for the API request. It can be one of the following: GET, POST, PUT, DELETE, or PATCH.
        [Parameter()]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method = 'GET',

        # The base URI for the GitHub API. This is usually 'https://api.github.com', but can be adjusted if necessary.
        [Parameter()]
        [string] $ApiBaseUri = (Get-GitHubConfig -Name ApiBaseUri -AsPlainText),

        # The specific endpoint for the API call, e.g., '/repos/user/repo/pulls'.
        [Parameter(Mandatory)]
        [string] $ApiEndpoint,

        # The body of the API request. This can be a hashtable or a string. If a hashtable is provided, it will be converted to JSON.
        [Parameter()]
        [Object] $Body,

        # The 'Accept' header for the API request. If not provided, the default will be used by GitHub's API.
        [Parameter()]
        [string] $Accept,

        # Specifies the HTTP version used for the request.
        [Parameter()]
        $HttpVersion = '2.0',

        # Support Pagination Relation Links per RFC5988.
        [Parameter()]
        $FollowRelLink = $true,

        # The secure token used for authentication in the GitHub API. It should be stored as a SecureString to ensure it's kept safe in memory.
        [Parameter()]
        [SecureString] $AccessToken = (Get-GitHubConfig -Name AccessToken),

        # The 'Content-Type' header for the API request. The default is 'application/vnd.github+json'.
        [Parameter()]
        [string] $ContentType = 'application/vnd.github+json',

        # The GitHub API version to be used. By default, it pulls from a configuration script variable.
        [Parameter()]
        [string] $Version = (Get-GitHubConfig -Name ApiVersion -AsPlainText)
    )

    $functionName = $MyInvocation.MyCommand.Name

    $headers = @{

        Accept                 = $Accept
        'X-GitHub-Api-Version' = $Version
    }

    ($headers.GetEnumerator() | Where-Object { -not $_.Value }) | ForEach-Object { $headers.Remove($_.Name) }

    $AccessTokenAsPlainText = ConvertFrom-SecureString $AccessToken -AsPlainText
    # Swap out this by using the -Authentication Bearer -Token $AccessToken
    switch -Regex ($AccessTokenAsPlainText) {
        '^ghp_|^github_pat_' {
            $headers.authorization = "Bearer $AccessTokenAsPlainText"
        }
        '^ghu_|^gho_' {
            $headers.authorization = "Bearer $AccessTokenAsPlainText"
        }
        default {
            $tokenPrefix = $AccessTokenAsPlainText -replace '_.*$', '_*'
            $errorMessage = "Unexpected AccessToken format: $tokenPrefix"
            Write-Error $errorMessage
            throw $errorMessage
        }
    }

    $URI = ("$ApiBaseUri/" -replace '/$', '') + ("/$ApiEndpoint" -replace '^/', '')

    $APICall = @{
        Uri                = $URI
        Method             = $Method
        Headers            = $Headers
        ContentType        = $ContentType
        HttpVersion        = $HttpVersion
        FollowRelLink      = $FollowRelLink
        SessionVariable    = 'Session'
        StatusCodeVariable = 'StatusCode'
        ResponseHeadersVariable = 'ResponseHeaders'
    }



    if ($Body) {
        if ($Body -is [string]) {
            $APICall.Body = $Body
        } else {
            $APICall.Body = $Body | ConvertTo-Json -Depth 100
        }
    }

    try {

        Invoke-RestMethod @APICall | Write-Output

    } catch [System.Net.WebException] {
        Write-Error "[$functionName] - WebException - $($_.Exception.Message)"
        throw $_
    } catch {
        Write-Error "[$functionName] - GeneralException - $($_.Exception.Message)"
        throw $_
    }
}
