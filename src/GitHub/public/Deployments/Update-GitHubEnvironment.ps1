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
        $body = @{
            owner            = $Owner
            repo             = $Repo
            environment_name = $Name
        }

        $inputObject = @{
            APIEndpoint = "/repos/$Owner/$Repo/environments/$Name"
            Method      = 'PUT'
            Body        = $body
        }

        Invoke-GitHubAPI @inputObject

    }

    end {}
}
