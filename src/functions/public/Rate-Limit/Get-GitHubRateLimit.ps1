filter Get-GitHubRateLimit {
    <#
        .SYNOPSIS
        Get rate limit status for the authenticated user

        .DESCRIPTION
        **Note:** Accessing this endpoint does not count against your REST API rate limit.

        Some categories of endpoints have custom rate limits that are separate from the rate limit governing the other REST API endpoints.
        For this reason, the API response categorizes your rate limit. Under `resources`, you'll see objects relating to different categories:
        * The `core` object provides your rate limit status for all non-search-related resources in the REST API.
        * The `search` object provides your rate limit status for the REST API for searching (excluding code searches). For more information, see "[Search](https://docs.github.com/rest/search)."
        * The `code_search` object provides your rate limit status for the REST API for searching code. For more information, see "[Search code](https://docs.github.com/rest/search/search#search-code)."
        * The `graphql` object provides your rate limit status for the GraphQL API. For more information, see "[Resource limitations](https://docs.github.com/graphql/overview/resource-limitations#rate-limit)."
        * The `integration_manifest` object provides your rate limit status for the `POST /app-manifests/{code}/conversions` operation. For more information, see "[Creating a GitHub App from a manifest](https://docs.github.com/apps/creating-github-apps/setting-up-a-github-app/creating-a-github-app-from-a-manifest#3-you-exchange-the-temporary-code-to-retrieve-the-app-configuration)."
        * The `dependency_snapshots` object provides your rate limit status for submitting snapshots to the dependency graph. For more information, see "[Dependency graph](https://docs.github.com/rest/dependency-graph)."
        * The `code_scanning_upload` object provides your rate limit status for uploading SARIF results to code scanning. For more information, see "[Uploading a SARIF file to GitHub](https://docs.github.com/code-security/code-scanning/integrating-with-code-scanning/uploading-a-sarif-file-to-github)."
        * The `actions_runner_registration` object provides your rate limit status for registering self-hosted runners in GitHub Actions. For more information, see "[Self-hosted runners](https://docs.github.com/rest/actions/self-hosted-runners)."
        * The `source_import` object is no longer in use for any API endpoints, and it will be removed in the next API version. For more information about API versions, see "[API Versions](https://docs.github.com/rest/overview/api-versions)."

        **Note:** The `rate` object is deprecated. If you're writing new API client code or updating existing code, you should use the `core` object
        instead of the `rate` object. The `core` object contains the same information that is present in the `rate` object.

        .EXAMPLE
        Get-GitHubRateLimit

        Gets the rate limit status for the authenticated user.

        .NOTES
        [Get rate limit status for the authenticated user](https://docs.github.com/rest/rate-limit/rate-limit#get-rate-limit-status-for-the-authenticated-user)

    #>
    [OutputType([pscustomobject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/rate_limit'
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response.Resources.PSObject.Properties | ForEach-Object {
                [GitHubRateLimitResource]@{
                    Name      = $_.Name
                    Limit     = $_.Value.limit
                    Used      = $_.Value.used
                    Remaining = $_.Value.remaining
                    Reset     = [DateTime]::UnixEpoch.AddSeconds($_.Value.reset).ToLocalTime()
                }
            }
            if ($_.Response.Rate) {
                [GitHubRateLimitResource]@{
                    Name      = 'rate'
                    Limit     = $_.Response.Rate.limit
                    Used      = $_.Response.Rate.used
                    Remaining = $_.Response.Rate.remaining
                    Reset     = [DateTime]::UnixEpoch.AddSeconds($_.Response.Rate.reset).ToLocalTime()
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
