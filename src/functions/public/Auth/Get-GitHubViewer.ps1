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
        [string[]] $Fields = @('login', 'id', 'databaseId'),

        # Context to run the command in.
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Verbose "[$commandName] - Start"
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
