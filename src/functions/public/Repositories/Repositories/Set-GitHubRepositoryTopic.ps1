filter Set-GitHubRepositoryTopic {
    <#
        .SYNOPSIS
        Replace all repository topics

        .DESCRIPTION
        Replace all repository topics

        .EXAMPLE
        ```pwsh
        Set-GitHubRepositoryTopic -Owner 'octocat' -Name 'hello-world' -Topic 'octocat', 'octo', 'octocat/hello-world'
        ```

        Replaces all topics for the repository 'octocat/hello-world' with the topics 'octocat', 'octo', 'octocat/hello-world'.

        .NOTES
        [Replace all repository topics](https://docs.github.com/rest/repos/repos#replace-all-repository-topics)

        .LINK
        https://psmodule.io/GitHub/Functions/Repositories/Repositories/Set-GitHubRepositoryTopic
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Name,

        # The number of results per page (max 100).
        [Parameter()]
        [string[]] $Topic = @(),

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
            names = $Topic | ForEach-Object { $_.ToLower() }
        }

        $apiParams = @{
            Method      = 'PUT'
            APIEndpoint = "/repos/$Owner/$Name/topics"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("topics for repo [$Owner/$Name]", 'Set')) {
            Invoke-GitHubAPI @apiParams | ForEach-Object {
                Write-Output $_.Response.names
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}

#SkipTest:FunctionTest:Will add a test for this function in a future PR
