Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Context -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $contexts = @()
    $hasAnonymousParameter = $false
    $command = Get-Command -Name $commandName -ErrorAction SilentlyContinue
    if ($command) {
        $hasAnonymousParameter = $command.Parameters.ContainsKey('Anonymous')
    }
    if ($hasAnonymousParameter) {
        $contexts += 'Anonymous'
    }

    $contexts += Get-GitHubContext -ListAvailable -Verbose:$false -Debug:$false
    $contexts = $contexts | Sort-Object -Property Name
    $filteredOptions = $contexts | Where-Object { $_.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
