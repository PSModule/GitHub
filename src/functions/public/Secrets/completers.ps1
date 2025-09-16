Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubSecret' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Owner       = $fakeBoundParameters.Owner
        Repository  = $fakeBoundParameters.Repository
        Environment = $fakeBoundParameters.Environment
        Context     = $fakeBoundParameters.Context
        Verbose     = $false
        Debug       = $false
    }
    $params | Remove-HashtableEntry -NullOrEmptyValues
    $filteredOptions = Get-GitHubSecret @params | Where-Object { $_.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
