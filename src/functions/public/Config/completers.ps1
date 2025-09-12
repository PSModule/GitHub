Register-ArgumentCompleter -CommandName Set-GitHubConfig, Get-GitHubConfig, Remove-GitHubConfig -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    ([GitHubConfig]).GetProperties().Name | Where-Object { $_ -like $pattern } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_ )
    }
}

Register-ArgumentCompleter -CommandName Set-GitHubConfig -ParameterName Value -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    if ($fakeBoundParameters.Name -eq 'CompletionMode') {
        $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
        @('StartsWith', 'Contains') | Where-Object { $_ -like $pattern } | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
