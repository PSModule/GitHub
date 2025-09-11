Register-ArgumentCompleter -CommandName Set-GitHubRepositoryPermission -ParameterName Permission -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $permissions = @('None', 'Pull', 'Triage', 'Push', 'Maintain', 'Admin', 'Read', 'Write')
    $permissions | Where-Object { $_ -like (Get-GitHubCompletionPattern -WordToComplete $wordToComplete) } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
