filter Get-GitHubRepositoryCustomProperty {
    <#
        .SYNOPSIS
        Get all custom property values for a repository

        .DESCRIPTION
        Gets all custom property values that are set for a repository.
        Users with read access to the repository can use this endpoint.

        .EXAMPLE
        Get-GitHubRepositoryCustomProperty -Owner 'octocat' -Repo 'hello-world'

        Gets all custom property values that are set for the 'hello-world' repository.

        .NOTES
        [Get all custom property values for a repository](https://docs.github.com/rest/repos/custom-properties#get-all-custom-property-values-for-a-repository)

    #>
    [Alias('Get-GitHubRepositoryCustomProperties')]
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Contains a long link.')]
    [OutputType([pscustomobject])]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubContextSetting -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubContextSetting -Name Repo)
    )

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/properties/values"
        Method      = 'GET'
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
