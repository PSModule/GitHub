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
        [Alias('Say')]
        [Alias('Saying')]
        [string] $S,

        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $body = @{
        s = $S
    }

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/octocat'
        Method      = 'GET'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
