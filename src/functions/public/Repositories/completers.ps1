Register-ArgumentCompleter -CommandName New-GitHubRepository -ParameterName Gitignore -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    $filteredOptions = Get-GitHubGitignore @params | Where-Object { $_ -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName New-GitHubRepository -ParameterName License -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    $filteredOptions = Get-GitHubLicense @params | Where-Object { $_.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}

Register-ArgumentCompleter -CommandName Get-GitHubRepository -ParameterName AdditionalProperty -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $filteredOptions = [GitHubRepository].GetProperties().Name | Where-Object { $_ -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName Get-GitHubRepository -ParameterName Property -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $filteredOptions = [GitHubRepository].GetProperties().Name | Where-Object { $_ -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Repository -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Owner   = $fakeBoundParameters.Owner ?? $fakeBoundParameters.Organization
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    $filteredOptions = Get-GitHubRepository @params | Where-Object { $_.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubRepository' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $params = @{
        Owner   = $fakeBoundParameters.Owner ?? $fakeBoundParameters.Organization
        Context = $fakeBoundParameters.Context
        Verbose = $false
        Debug   = $false
    }
    $filteredOptions = Get-GitHubRepository @params | Where-Object { $_.Name -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
    }
}
