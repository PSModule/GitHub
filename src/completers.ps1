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

# Status functions - Stamp parameter completer
$statusStampCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters

    if (-not $script:GitHub.Stamps) {
        return $null
    }

    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $filteredOptions = $script:GitHub.Stamps.Keys | Where-Object { $_ -like $pattern }

    if (-not $filteredOptions) {
        return $null
    }

    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName @(
    'Get-GitHubStatus'
    'Get-GitHubScheduledMaintenance'
    'Get-GitHubStatusComponent'
    'Get-GitHubStatusIncident'
) -ParameterName Stamp -ScriptBlock $statusStampCompleter
