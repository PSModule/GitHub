function Update-GitHubEnvironment {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/repos#create-or-update-an-environment
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Alias('environment_name')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name
    )

    begin {}

    process {
        $inputObject = @{
            APIEndpoint = "/repos/$Owner/$Repo/environments/$Name"
            Body        = @{
                owner            = $Owner
                repo             = $Repo
                environment_name = $Name
            }
            Method      = 'PUT'
        }

        $response = Invoke-GitHubAPI @inputObject

        $response
    }

    end {}
}
