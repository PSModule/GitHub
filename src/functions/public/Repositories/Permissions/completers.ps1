Register-ArgumentCompleter -CommandName Set-GitHubRepositoryPermission -ParameterName Permission -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    @('None', 'Pull', 'Triage', 'Push', 'Maintain', 'Admin', 'Read', 'Write') | Where-Object { $_ -like $pattern } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
