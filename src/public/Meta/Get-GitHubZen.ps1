filter Get-GitHubZen {
    <#
    .SYNOPSIS
    Get the Zen of GitHub.

    .DESCRIPTION
    Get a random sentence from the Zen of GitHub.

    .EXAMPLE
    Get-GitHubZen

    Get a random sentence from the Zen of GitHub.

    .NOTES
    [Get the Zen of GitHub](https://docs.github.com/rest/meta/meta#get-the-zen-of-github)
    #>
    [CmdletBinding()]
    param ()

    $inputObject = @{
        APIEndpoint = '/zen'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
