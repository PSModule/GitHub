function Get-GitHubEnvironment {
    <#
        .SYNOPSIS
        Get GitHub environment

        .DESCRIPTION
        Long description

        .PARAMETER Owner
        Parameter description

        .PARAMETER Repo
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
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    begin {}

    process {

        $inputObject = @{
            APIEndpoint = "/repos/$Owner/$Repo/environments"
            Method      = 'GET'
        }

        (Invoke-GitHubAPI @inputObject).Response

    }

    end {}
}
