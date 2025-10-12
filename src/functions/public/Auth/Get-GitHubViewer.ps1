function Get-GitHubViewer {
    <#
        .SYNOPSIS
        Gets the currently authenticated user.

        .DESCRIPTION
        Gets the currently authenticated user.

        .EXAMPLE
        ```powershell
        Get-GithubViewer
        ```

        Gets the currently authenticated user.

        .NOTES
        [GraphQL API - Queries - Viewer](https://docs.github.com/graphql/reference/queries#viewer)

        .LINK
        https://psmodule.io/GitHub/Functions/Auth/Get-GitHubViewer
    #>
    [CmdletBinding()]
    param(
        # The fields to return.
        [Parameter()]
        [string[]] $Fields = @('name', 'login', 'id', 'databaseId'),

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
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
        $data = Invoke-GitHubGraphQLQuery -Query $query -Context $Context

        $data.viewer
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
