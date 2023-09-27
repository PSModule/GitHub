function Get-GitHubEnvironment {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo)
    )

    begin {}

    process {
        # API Reference
        # https://docs.github.com/en/rest/reference/repos#get-all-environments

        $inputObject = @{
            APIEndpoint = "/repos/$Owner/$Repo/environments"
            Method      = 'GET'
        }

        $response = Invoke-GitHubAPI @inputObject

        $response
    }

    end {}
}
