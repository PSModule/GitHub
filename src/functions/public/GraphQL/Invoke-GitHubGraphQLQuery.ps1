function Invoke-GitHubGraphQLQuery {
    <#
        .SYNOPSIS
        Invoke a GraphQL query against the GitHub GraphQL API

        .DESCRIPTION
        Use this function to invoke a GraphQL query against the GitHub GraphQL API.

        .EXAMPLE
        Invoke-GitHubGraphQLQuery -Query $query -Variables $Variables

        .NOTES
        [GitHub GraphQL API documentation](https://docs.github.com/graphql)
    #>
    [CmdletBinding()]
    param(
        # The GraphQL query to execute.
        [Parameter(Mandatory)]
        [string] $Query,

        # The variables to pass to the query.
        [Parameter()]
        [hashtable] $Variables,

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
        $body = @{
            'query'     = $Query
            'variables' = $Variables
        }

        $inputObject = @{
            Method      = 'Post'
            APIEndpoint = '/graphql'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
