Register-ArgumentCompleter -ParameterName Context -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    $contexts = Get-GitHubContext -ListAvailable -Verbose:$false | Where-Object { "$($_.HostName)/$($_.UserName)" -like "$wordToComplete*" }

    $contexts | ForEach-Object {
        $contextID = "$($_.HostName)/$($_.UserName)"
        [System.Management.Automation.CompletionResult]::new($contextID, $contextID, 'ParameterValue', $contextID)
    }
}
