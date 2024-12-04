filter Get-GitHubApiVersion {
    <#
        .SYNOPSIS
        Get all API versions.

        .DESCRIPTION
        Get all supported GitHub API versions.

        .EXAMPLE
        Get-GitHubApiVersion

        Get all supported GitHub API versions.

        .NOTES
        [Get all API versions](https://docs.github.com/rest/meta/meta#get-all-api-versions)
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param(
        # The context to run the command in.
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $inputObject = @{
        Context     = $Context
        ApiEndpoint = '/versions'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
