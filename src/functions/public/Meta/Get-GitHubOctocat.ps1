filter Get-GitHubOctocat {
    <#
        .SYNOPSIS
        Get Octocat.

        .DESCRIPTION
        Get the octocat as ASCII art.

        .EXAMPLE
        ```pwsh
        Get-GitHubOctocat
        ```

        Get the octocat as ASCII art

        .EXAMPLE
        ```pwsh
        Get-GitHubOctocat -S "Hello world"
        ```

        Get the octocat as ASCII art with a custom saying

        .NOTES
        [Get Octocat](https://docs.github.com/rest/meta/meta#get-octocat)

        .LINK
        https://psmodule.io/GitHub/Functions/Meta/Get-GitHubOctocat
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

        # The words to show in Octocat's speech bubble
        [Parameter()]
        [string] $Saying,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context -Anonymous $Anonymous
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT, Anonymous
    }

    process {
        $body = @{
            s = $Saying
        }

        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = '/octocat'
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
