function Initialize-RunnerEnvironment {
    <#
        .SYNOPSIS
        Initialize the runner environment for the GitHub module

        .DESCRIPTION
        Initialize the runner environment for the GitHub module

        .EXAMPLE
        Initialize-RunnerEnvironment

        Initializes the runner environment for the GitHub module
    #>
    [CmdletBinding()]
    param()

    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME

    # Autologon if a token is present in environment variables
    $gitHubToken = Get-ChildItem -Path 'Env:' | Where-Object Name -In 'GH_TOKEN', 'GITHUB_TOKEN' | Select-Object -First 1 -ExpandProperty Value
    $gitHubTokenPresent = $gitHubToken.count -gt 0 -and -not [string]::IsNullOrEmpty($gitHubToken)
    Write-Debug "GitHub token present: [$gitHubTokenPresent]"
    if ($gitHubTokenPresent) {
        $params = @{
            AccessToken = $gitHubToken
            Owner       = $env:GITHUB_REPOSITORY_OWNER
            Repo        = $env:GITHUB_REPOSITORY_NAME
            Server      = $env:GITHUB_SERVER_URL
        }
        Connect-GitHubAccount @params
    }
}
