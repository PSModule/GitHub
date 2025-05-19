Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubWorkflow' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $params = @{
        Owner      = $fakeBoundParameter.Owner
        Repository = $fakeBoundParameter.Repository
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    Get-GitHubWorkflow @params | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubWorkflow' }) -ParameterName ID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $params = @{
        Owner      = $fakeBoundParameter.Owner
        Repository = $fakeBoundParameter.Repository
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    Get-GitHubWorkflow @params | Where-Object { $_.ID -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.ID, "$($_.Name) ($($_.ID))", 'ParameterValue', "$($_.Name) ($($_.ID))"  )
    }
}
