Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubWorkflow' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Owner      = $fakeBoundParameters.Owner
        Repository = $fakeBoundParameters.Repository
        Context    = $fakeBoundParameters.Context
        Verbose    = $false
        Debug      = $false
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    $filteredOptions = Get-GitHubWorkflow @params | Where-Object { $_.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubWorkflow' }) -ParameterName ID -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Owner      = $fakeBoundParameters.Owner
        Repository = $fakeBoundParameters.Repository
        Context    = $fakeBoundParameters.Context
        Verbose    = $false
        Debug      = $false
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    $filteredOptions = Get-GitHubWorkflow @params | Where-Object { $_.ID -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.ID, "$($_.Name) ($($_.ID))", 'ParameterValue', "$($_.Name) ($($_.ID))"  )
    }
}
