function Invoke-GitHubGraphQL {
    <#
        .SYNOPSIS
        Invoke a GraphQL requests against the GitHub GraphQL API

        .DESCRIPTION
        Use this function to invoke a GraphQL query and mutations against the GitHub GraphQL API with proper error handling.

        .EXAMPLE
        Invoke-GitHubGraphQL -Query $query -Variables $Variables

        .EXAMPLE
        Invoke-GitHubGraphQL -Mutation $mutation -Variables $Variables

        .LINK
        https://psmodule.io/GitHub/Functions/Gr

        .LINK
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
                $errorMessages = $graphQLResponse.errors | ForEach-Object {
                    "GraphQL Error [$($_.type)]: $($_.message)`nPath: $($_.path -join '/')`nLocations: $($_.locations.line):$($_.locations.column)"
                }
                throw "GraphQL errors occurred:`n$($errorMessages -join "`n`n")"
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
