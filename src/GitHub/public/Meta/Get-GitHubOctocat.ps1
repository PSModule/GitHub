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
        https://docs.github.com/rest/meta/meta#get-octocat
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The words to show in Octocat's speech bubble
        [Parameter()]
        [Alias('Say')]
        [Alias('Saying')]
        [string] $S
    )

    $body = @{
        s = $S
    }

    $inputObject = @{
        APIEndpoint = '/octocat'
        Method      = 'GET'
        Body        = $body
    }

    (Invoke-GitHubAPI @inputObject).Response

}
