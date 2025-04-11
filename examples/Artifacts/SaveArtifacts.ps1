$modulesPath = $env:PSModulePath -Split [IO.Path]::PathSeparator | Select-Object -First 1
Get-GitHubArtifact -Owner PSModule -Repository GitHub -Name module |
    Save-GitHubArtifact -Path $modulesPath -Extract
