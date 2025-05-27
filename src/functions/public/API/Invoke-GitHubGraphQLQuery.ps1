function Invoke-GitHubGraphQLQuery {
    <#
        .SYNOPSIS
        Invoke a GraphQL requests against the GitHub GraphQL API

        .DESCRIPTION
        Use this function to invoke a GraphQL query and mutations against the GitHub GraphQL API with proper error handling.

        .EXAMPLE
        Invoke-GitHubGraphQLQuery -Query $query -Variables $Variables        .LINK
        https://psmodule.io/GitHub/Functions/API/Invoke-GitHubGraphQLQuery/

                https://psmodule.io/GitHub/Functions/API/Invoke-GitHubGraphQLQuery

        .NOTES
        [GitHub GraphQL API documentation](https://docs.github.com/graphql)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Query,

        [Parameter()]
        [hashtable] $Variables,

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
                $queryLines = $Query -split "`n"
                $errorMessages = @()
                $graphQLResponse.errors | ForEach-Object {
                    $lineNum = $_.locations.line
                    $lineText = if ($lineNum -and ($lineNum -le $queryLines.Count)) { $queryLines[$lineNum - 1].Trim() } else { '' }
                    $errorMessages += @"
GraphQL Error [$($_.type)]:
Message:    $($_.message)
Path:       $($_.path -join '/')
Location:   $($_.locations.line):$($_.locations.column)
Query Line: $lineText
Extensions: $($_.extensions | Out-String)

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
