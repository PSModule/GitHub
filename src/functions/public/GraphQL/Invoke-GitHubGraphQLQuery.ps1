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
    param(
        # The GraphQL query to execute.
        [string] $Query,

        # The variables to pass to the query.
        [hashtable] $Variables,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/graphql'
        Method      = 'Post'
        Body        = @{
            'query'     = $query
            'variables' = $variables
        } | ConvertTo-Json
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
