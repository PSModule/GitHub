﻿Register-ArgumentCompleter -CommandName New-GitHubRepository -ParameterName Gitignore -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    Get-GitHubGitignore | Select-Object -ExpandProperty name | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName New-GitHubRepository -ParameterName License -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    Get-GitHubLicense | Select-Object -ExpandProperty name | Where-Object { $_ -like "*$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName Get-GitHubRepository -ParameterName AdditionalProperty -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    [GitHubRepository].GetProperties().Name | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName Get-GitHubRepository -ParameterName Property -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    [GitHubRepository].GetProperties().Name | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport) -ParameterName Repository -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $params = @{
        Property = 'Name'
        Verbose  = $false
        Debug    = $false
    }
    if ($fakeBoundParameters.ContainsKey('Owner')) {
        $params['Owner'] = $fakeBoundParameters.Owner
    } elseif ($fakeBoundParameters.ContainsKey('Organization')) {
        $params['Owner'] = $fakeBoundParameters.Organization
    }
    (Get-GitHubRepository @params).Name | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName ($script:PSModuleInfo.FunctionsToExport |
        Where-Object { $_ -like '*GitHubRepository' }) -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters
    $params = @{
        Property = 'Name'
        Verbose  = $false
        Debug    = $false
    }
    if ($fakeBoundParameters.ContainsKey('Owner')) {
        $params['Owner'] = $fakeBoundParameters.Owner
    } elseif ($fakeBoundParameters.ContainsKey('Organization')) {
        $params['Owner'] = $fakeBoundParameters.Organization
    }
    (Get-GitHubRepository @params).Name | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
