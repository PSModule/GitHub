Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubSecret' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $params = @{
        Owner      = $fakeBoundParameter.Owner
        Repository = $fakeBoundParameter.Repository
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    Get-GitHubSecret @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
