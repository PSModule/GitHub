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
        # The fields to return.
        [Parameter()]
        [string[]] $Fields = @('login', 'id', 'databaseId'),

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
    }

    process {
        $query = @"
query {
  viewer {
    $($Fields -join "`n")
  }
}
"@
        $results = Invoke-GitHubGraphQLQuery -Query $query -Context $Context

        return $results.data.viewer
    }

    end {
        Write-Verbose "[$commandName] - End"
    }
}
