function Get-GitHubEnvironmentSecrets {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        [Alias('name')]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $EnvironmentName
    )

    begin {}

    process {
        $RepoID = (Get-GitHubRepo).id
        #/repositories/{repository_id}/environments/{environment_name}/secrets/{secret_name}
        #/repositories/{repository_id}/environments/{environment_name}/secrets
        # API Reference
        # https://docs.github.com/en/rest/reference/repos#get-all-environments

        $inputObject = @{
            APIEndpoint = "/repositories/$RepoID/environments/$EnvironmentName/secrets"
            Method      = 'GET'
        }

        $response = Invoke-GitHubAPI @inputObject

        $response
    }

    end {}
}
