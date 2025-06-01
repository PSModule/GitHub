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

        .LINK
        https://psmodule.io/GitHub/Functions/Meta/Get-GitHubApiVersion
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param(
        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT, Anonymous
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            ApiEndpoint = '/versions'
            Anonymous   = $Anonymous
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
