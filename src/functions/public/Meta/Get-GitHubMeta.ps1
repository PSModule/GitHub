filter Get-GitHubMeta {
    <#
        .SYNOPSIS
        Get GitHub meta information.

        .DESCRIPTION
        Returns meta information about GitHub, including a list of GitHub's IP addresses. For more information, see
        "[About GitHub's IP addresses](https://docs.github.com/articles/about-github-s-ip-addresses/)."

        The API's response also includes a list of GitHub's domain names.

        The values shown in the documentation's response are example values. You must always query the API directly to get the latest values.

        **Note:** This endpoint returns both IPv4 and IPv6 addresses. However, not all features support IPv6. You should refer to the specific
        documentation for each feature to determine if IPv6 is supported.

        .EXAMPLE
        Get-GitHubMeta

        Returns meta information about GitHub, including a list of GitHub's IP addresses.

        .NOTES
        [Get GitHub meta information](https://docs.github.com/rest/meta/meta#get-apiname-meta-information)

        .LINK
        https://psmodule.io/GitHub/Functions/Meta/Get-GitHubMeta
    #>
    [OutputType([object])]
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
            ApiEndpoint = '/meta'
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
