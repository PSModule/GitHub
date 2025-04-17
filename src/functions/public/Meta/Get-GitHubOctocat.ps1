filter Get-GitHubOctocat {
    <#
        .SYNOPSIS
        Get Octocat.

        .DESCRIPTION
        Get the octocat as ASCII art.

        .EXAMPLE
        Get-GitHubOctocat

        Get the octocat as ASCII art

        .EXAMPLE
        Get-GitHubOctocat -S "Hello world"

        Get the octocat as ASCII art with a custom saying

        .NOTES
        [Get Octocat](https://docs.github.com/rest/meta/meta#get-octocat)
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The words to show in Octocat's speech bubble
        [Parameter()]
        [string] $Saying,

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
            s = $Saying
        }

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/octocat'
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
