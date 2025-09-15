Register-ArgumentCompleter -CommandName Set-GitHubConfig, Get-GitHubConfig, Remove-GitHubConfig -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    ([GitHubConfig]).GetProperties().Name | Where-Object { $_ -like $pattern } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_ )
    }
}

Register-ArgumentCompleter -CommandName Set-GitHubConfig -ParameterName Value -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $pattern = switch (Get-GitHubConfig -Name CompletionMode) { 'Contains' { "*$wordToComplete*" } default { "$wordToComplete*" } }
    switch ($fakeBoundParameters.Name) {
        'CompletionMode' {
            @('StartsWith', 'Contains') | Where-Object { $_ -like $pattern } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
        'HttpVersion' {
            @('1.0', '1.1', '2.0', '3.0') | Where-Object { $_ -like $pattern } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
        'EnvironmentType' {
            @('Local', 'GitHubActions', 'FunctionApp', 'Unknown') | Where-Object { $_ -like $pattern } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
        'ApiVersion' {
            $params = @{
                Context = $fakeBoundParameters.Context
                Debug   = $false
                Verbose = $false
            }
            Get-GitHubApiVersion @params | Where-Object { $_ -like $pattern } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
        }
        'DefaultContext' {
            Get-GitHubContext -ListAvailable | Where-Object { $_.Name -like $pattern } | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_.Name, $_.Name, 'ParameterValue', $_.Name)
            }
        }
    }
}
