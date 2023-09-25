function Get-GitHubOctocat {
    <#
        .SYNOPSIS
        Get the octocat as ASCII art

        .DESCRIPTION
        Get the octocat as ASCII art

        .EXAMPLE
        Get-GitHubOctocat

        Get the octocat as ASCII art

        .EXAMPLE
        Get-GitHubOctocat -S 'The glass is never half empty. It's just twice as big as it needs to be.'

        Get the octocat as ASCII art with a custom saying

        .NOTES
        https://docs.github.com/en/rest/meta/meta?apiVersion=2022-11-28#get-octocat
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The words to show in Octocat's speech bubble
        [Parameter()]
        [Alias('Say')]
        [Alias('Saying')]
        [string]
        $S = "The glass is never half empty. Its just twice as big as it needs to be."
    )

    # $query = [System.Web.HttpUtility]::UrlEncode($S)
    # $query = [System.Uri]::EscapeDataString($S)


    $body = @{
        s = $S
    }

    $inputObject = @{
        APIEndpoint = "/octocat?s=$query"
        Method      = 'GET'
        Body        = $body
    }

    $response = Invoke-GitHubAPI @inputObject

    $response
}
