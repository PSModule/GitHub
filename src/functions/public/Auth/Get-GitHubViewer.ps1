function Get-GitHubViewer {
    <#
        .SYNOPSIS
        Gets the currently authenticated user.

        .DESCRIPTION
        Gets the currently authenticated user.

        .EXAMPLE
        Get-GithubViewer

        Gets the currently authenticated user.

        .NOTES
        [GraphQL API - Queries - Viewer](https://docs.github.com/en/graphql/reference/queries#viewer)
    #>
    [CmdletBinding()]
    param(
        [string[]] $Fields = @('login', 'id', 'databaseId')
    )

    $query = @"
query {
  viewer {
    $($Fields -join "`n")
  }
}
"@
    $results = Invoke-GitHubGraphQLQuery -Query $query
    return $results.data.viewer
}
