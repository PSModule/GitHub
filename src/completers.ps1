Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Context -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $contexts = @()
    $hasAnonymousParameter = $false
    $command = Get-Command -Name $commandName -ErrorAction SilentlyContinue
    if ($command) {
        $hasAnonymousParameter = $command.Parameters.ContainsKey('Anonymous')
    }
    if ($hasAnonymousParameter) {
        $contexts += 'Anonymous'
    }

    $contexts += (Get-GitHubContext -ListAvailable -Verbose:$false).Name
    $contexts | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
