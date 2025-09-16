Register-ArgumentCompleter -CommandName Set-GitHubConfig, Get-GitHubConfig, Remove-GitHubConfig -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    $filteredOptions = ([GitHubConfig]).GetProperties().Name | Where-Object { $_ -like $pattern }
    if (-not $filteredOptions) {
        return $null
    }
    $filteredOptions | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_ )
    }
}

Register-ArgumentCompleter -CommandName Set-GitHubConfig -ParameterName Value -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    switch ($fakeBoundParameters.Name) {
        'CompletionMode' {
            $filteredOptions = @('StartsWith', 'Contains') | Where-Object { $_ -like $pattern }
            if (-not $filteredOptions) {
                return $null
            }
            $filteredOptions | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
        'HttpVersion' {
            $filteredOptions = @('1.0', '1.1', '2.0', '3.0') | Where-Object { $_ -like $pattern }
            if (-not $filteredOptions) {
                return $null
            }
            $filteredOptions | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
        'EnvironmentType' {
            $filteredOptions = @('Local', 'GitHubActions', 'FunctionApp', 'Unknown') | Where-Object { $_ -like $pattern }
            if (-not $filteredOptions) {
                return $null
            }
            $filteredOptions | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
        'ApiVersion' {
            $params = @{
                Context = $fakeBoundParameters.Context
                Debug   = $false
                Verbose = $false
            }
            $filteredOptions = Get-GitHubApiVersion @params | Where-Object { $_ -like $pattern }
            if (-not $filteredOptions) {
                return $null
            }
            $filteredOptions | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
        'DefaultContext' {
            $filteredOptions = Get-GitHubContext -ListAvailable | Where-Object { $_.Name -like $pattern }
            if (-not $filteredOptions) {
                return $null
            }
            $filteredOptions | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
            }
        }
    }
}
