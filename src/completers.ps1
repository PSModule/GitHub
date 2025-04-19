Register-ArgumentCompleter -ParameterName Context -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $fakeBoundParameter

    $contexts = @()

    # Check if the command has an Anonymous parameter
    $hasAnonymousParameter = $false
    if ($commandAst -and $commandAst.CommandElements -and $commandAst.CommandElements.Count -gt 1) {
        $command = Get-Command -Name $commandAst.CommandElements[0].Value -ErrorAction SilentlyContinue
        if ($command) {
            $hasAnonymousParameter = $command.Parameters.ContainsKey('Anonymous')
        }
    }
    if ($hasAnonymousParameter) {
        $contexts += 'Anonymous'
    }

    $contexts += (Get-GitHubContext -ListAvailable -Verbose:$false).Name

    $contexts | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, "ListIItem: $($_)", 'ParameterValue', "Tooltip: $($_)")
    }
}
