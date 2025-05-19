# Complete the Name parameter for all *GitHubEnvironment commands
Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubEnvironment' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $params = @{
        Owner      = $fakeBoundParameter.Owner
        Repository = $fakeBoundParameter.Repository
        Context    = $fakeBoundParameter.Context
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    Get-GitHubEnvironment @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}

# Complete the Environment parameter for all functions in the module
Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Environment -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $params = @{
        Owner      = $fakeBoundParameter.Owner
        Repository = $fakeBoundParameter.Repository
        Context    = $fakeBoundParameter.Context
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    Get-GitHubEnvironment @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
