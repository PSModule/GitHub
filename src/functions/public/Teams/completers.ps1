Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubTeam' }) -ParameterName Slug -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Organization = $fakeBoundParameters.Organization
        Context      = $fakeBoundParameters.Context
        Verbose      = $false
        Debug        = $false
    }
    $filteredOptions = Get-GitHubTeam @params | Where-Object { $_.Slug -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Slug, $_.Slug, 'ParameterValue', $_.Slug)
    }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Team -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Organization = $fakeBoundParameters.Organization ?? $fakeBoundParameters.Owner
        Context      = $fakeBoundParameters.Context
        Verbose      = $false
        Debug        = $false
    }
    $filteredOptions = Get-GitHubTeam @params | Where-Object { $_.Slug -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Slug, $_.Slug, 'ParameterValue', $_.Slug)
    }
}
