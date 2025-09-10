# Complete the Name parameter for all *GitHubEnvironment commands
Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubEnvironment' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    $params = @{
        Owner      = $fakeBoundParameters.Owner
        Repository = $fakeBoundParameters.Repository
        Context    = $fakeBoundParameters.Context
        Verbose    = $false
        Debug      = $false
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    Get-GitHubEnvironment @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}

# Complete the Environment parameter for all functions in the module
Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Environment -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    $params = @{
        Owner      = $fakeBoundParameters.Owner
        Repository = $fakeBoundParameters.Repository
        Context    = $fakeBoundParameters.Context
        Verbose    = $false
        Debug      = $false
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    Get-GitHubEnvironment @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
