Register-ArgumentCompleter -CommandName 'New-GitHubRepository' -ParameterName 'Gitignore' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    Get-GitHubGitignore | Select-Object -ExpandProperty name | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName 'New-GitHubRepository' -ParameterName 'License' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    Get-GitHubLicense | Select-Object -ExpandProperty name | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
