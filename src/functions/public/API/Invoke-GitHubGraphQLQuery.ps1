function Invoke-GitHubGraphQLQuery {
    <#
        .SYNOPSIS
        Invoke a GraphQL requests against the GitHub GraphQL API

        .DESCRIPTION
        Use this function to invoke a GraphQL query and mutations against the GitHub GraphQL API with proper error handling.

        .EXAMPLE
        Invoke-GitHubGraphQLQuery -Query $query -Variables $Variables

        .LINK
        https://psmodule.io/GitHub/Functions/API/Invoke-GitHubGraphQLQuery

        .NOTES
        [GitHub GraphQL API documentation](https://docs.github.com/graphql)
    #>
    [CmdletBinding()]
    param(
        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter(Mandatory)]
        [string] $Query,

        # Variables to pass to the GraphQL query.
        [Parameter()]
        [hashtable] $Variables,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            query     = $Query
            variables = $Variables
        }

        $inputObject = @{
            Method      = 'POST'
            APIEndpoint = '/graphql'
            Body        = $body
            Context     = $Context
        }

        try {
            $apiResponse = Invoke-GitHubAPI @inputObject
            $graphQLResponse = $apiResponse.Response
            # Handle GraphQL-specific errors (200 OK with errors in response)
            if ($graphQLResponse.errors) {
                $errorMessages = @()
                $queryLines = $Query -split "`n" | ForEach-Object { $_.Trim() }
                foreach ($errorItem in $graphQLResponse.errors) {
                    $errorMessages += @"
GraphQL Error [$($errorItem.type)]:
Message:    $($errorItem.message)
Path:       $($errorItem.path -join '/')
Locations:
$($errorItem.locations | ForEach-Object { " - [$($_.line):$($_.column)] - $($queryLines[$_.line - 1])" })

Full Error:
$($errorItem | ConvertTo-Json -Depth 10 | Out-String -Stream)

"@

                }
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        [System.Exception]::new("GraphQL errors occurred:`n$($errorMessages -join "`n`n")"),
                        'GraphQLError',
                        [System.Management.Automation.ErrorCategory]::InvalidOperation,
                        $graphQLResponse
                    )
                )
            }

            $graphQLResponse.data
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
