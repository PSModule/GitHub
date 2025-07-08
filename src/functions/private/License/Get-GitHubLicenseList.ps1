filter Get-GitHubLicenseList {
    <#
        .SYNOPSIS
        Get all commonly used licenses

        .DESCRIPTION
        Lists the most commonly used licenses on GitHub.
        For more information, see "[Licensing a repository ](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)."

        .EXAMPLE
        Get-GitHubLicenseList

        Get all commonly used licenses.

        .OUTPUTS
        GitHubLicense[]

        .NOTES
        [Get all commonly used licenses](https://docs.github.com/rest/licenses/licenses#get-all-commonly-used-licenses)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [OutputType([GitHubLicense[]])]
    [CmdletBinding()]
    param(
        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT, Anonymous
    }

    process {
        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = '/licenses'
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            $_.Response | ForEach-Object { [GitHubLicense]::New($_) }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
