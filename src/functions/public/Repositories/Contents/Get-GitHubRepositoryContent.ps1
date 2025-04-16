function Get-GitHubRepositoryContent {
    <#
        .SYNOPSIS
        Retrieves the contents of a file or directory from a GitHub repository.

        .DESCRIPTION
        This function calls the GitHub API endpoint that returns the contents of a repository.
        You can specify a file or directory path using -Path. If you leave -Path empty,
        the function will return the repository's root directory contents.

        Optionally, you can supply a specific commit, branch, or tag via -Ref.
        The function relies on the provided GitHub context for authentication and configuration.

        .EXAMPLE
        Get-GitHubRepositoryContent -Owner "octocat" -Repo "Hello-World" -Path "README.md" -Ref "main"

        Output:
        ```powershell
        {
            "name": "README.md",
            "path": "README.md",
            "sha": "123abc456def",
            "size": 1256,
            "url": "https://api.github.com/repos/octocat/Hello-World/contents/README.md",
            "type": "file"
        }
        ```

        Retrieves the README.md file from the main branch of the repository.

        .OUTPUTS
        System.Object

        .NOTES
        The response object containing details about the repository contents.

        .LINK
        https://psmodule.io/GitHub/Functions/Get-GitHubRepositoryContent/
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The GitHub account owner.
        [Parameter(Mandatory)]
        [Alias('Organization')]
        [Alias('User')]
        [string] $Owner,

        # The name of the repository.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The file or directory path in the repository.
        [Parameter()]
        [string] $Path,

        # Optional reference (commit, branch, or tag) to get content from.
        [Parameter()]
        [string] $Ref,

        # The GitHub context for the API call.
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
        # Build the query parameters (only ref is supported here).
        $body = @{
            ref = $Ref
        }

        # Prepare the input for the GitHub API call.
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/contents/$Path"
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
