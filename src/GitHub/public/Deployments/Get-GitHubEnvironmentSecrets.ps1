filter Get-GitHubEnvironmentSecrets {
    <#
    .SYNOPSIS
    Get GitHub environment secrets

    .DESCRIPTION
    Long description

    .PARAMETER Owner
    Parameter description

    .PARAMETER Repo
    Parameter description

    .PARAMETER EnvironmentName
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    https://docs.github.com/en/rest/reference/repos#get-all-environments
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('name')]
        [string] $EnvironmentName
    )

    $RepoID = (Get-GitHubRepo).id

    $inputObject = @{
        APIEndpoint = "/repositories/$RepoID/environments/$EnvironmentName/secrets"
        Method      = 'GET'
    }

    (Invoke-GitHubAPI @inputObject).Response

}
