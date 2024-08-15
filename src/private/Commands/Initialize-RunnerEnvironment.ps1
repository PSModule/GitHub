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
    param ()

    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnv -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME

}
