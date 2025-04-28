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

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Owner -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-GitHubOwner -Verbose:$false -Context $fakeBoundParameter['Context'] | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    } | Where-Object { $_.CompletionText -like "$wordToComplete*" }
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
