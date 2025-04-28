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

# Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Repository -ScriptBlock {
#     param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
#     $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

#     $repos = if ($fakeBoundParameter.ContainsKey('Owner')) {
#         Get-GitHubRepository -Verbose:$false -Owner $fakeBoundParameter['Owner']
#     } else {
#         Get-GitHubRepository -Verbose:$false
#     }
#     $repos | Where-Object { $_.Name -like "$wordToComplete*" } | ForEach-Object {
#         [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
#     }
# }
