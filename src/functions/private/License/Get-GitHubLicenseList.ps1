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

        .NOTES
        https://docs.github.com/rest/licenses/licenses#get-all-commonly-used-licenses

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [OutputType([string[]])]
    [CmdletBinding()]
    param (
        # The context to run the command in.
        [Parameter()]
        [string] $Context
    )

    $inputObject = @{
        Context     = $Context
        APIEndpoint = '/licenses'
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }

}
