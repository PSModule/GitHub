Register-ArgumentCompleter -CommandName Set-GitHubRepositoryPermission -ParameterName Permission -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = Get-GitHubCompletionPattern -WordToComplete $wordToComplete
    $permissions = @('None', 'Pull', 'Triage', 'Push', 'Maintain', 'Admin', 'Read', 'Write')
    $permissions | Where-Object { $_ -like $pattern } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
