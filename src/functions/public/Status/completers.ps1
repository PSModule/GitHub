Register-ArgumentCompleter -CommandName @(
    'Get-GitHubScheduledMaintenance'
    'Get-GitHubStamp'
    'Get-GitHubStatus'
    'Get-GitHubStatusComponent'
    'Get-GitHubStatusIncident'
) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    $stamps = Get-GitHubStamp
    if (-not $stamps) {
        return $null
    }

    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $filteredOptions = $stamps | Where-Object { $_.Name -like $pattern }

    if (-not $filteredOptions) {
        return $null
    }

    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
