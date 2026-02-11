Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName User -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    $filteredOptions = Get-GitHubAppInstallation @params | Where-Object { $_.Type -eq 'User' -and $_.Target.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Target.Name, $_.Target.Name, 'ParameterValue', $_.Target.Name)
    }
}
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName Organization -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    $filteredOptions = Get-GitHubAppInstallation @params | Where-Object { $_.Type -eq 'Organization' -and $_.Target.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Target.Name, $_.Target.Name, 'ParameterValue', $_.Target.Name)
    }
}
Register-ArgumentCompleter -CommandName Connect-GitHubApp -ParameterName Enterprise -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    $filteredOptions = Get-GitHubAppInstallation @params | Where-Object { $_.Type -eq 'Enterprise' -and $_.Target.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Target.Name, $_.Target.Name, 'ParameterValue', $_.Target.Name)
    }
}

Register-ArgumentCompleter -CommandName @(
    'Get-GitHubStatus'
    'Get-GitHubScheduledMaintenance'
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
