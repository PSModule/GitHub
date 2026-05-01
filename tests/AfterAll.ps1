[CmdletBinding()]
param()

LogGroup 'AfterAll - Global Test Teardown' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    $id = $env:GITHUB_RUN_ID
    if (-not $id) {
        throw 'GITHUB_RUN_ID environment variable is not set. Refusing to clean up test repositories with an unscoped wildcard (would impact concurrent runs).'
    }
    if (-not $env:Settings) {
        throw 'Settings environment variable is not set. Process-PSModule must populate it with the test suite configuration.'
    }
    $prefix = 'Test'

    # Derive the list of OS names from the Settings JSON provided by Process-PSModule.
    try {
        $settings = $env:Settings | ConvertFrom-Json
    } catch {
        throw "Settings environment variable contains invalid JSON. Expected TestSuites.Module.OSName to be present. $_"
    }

    $osNames = @($settings.TestSuites.Module.OSName | Sort-Object -Unique)
    if (-not $osNames) {
        throw 'Settings JSON must include at least one non-empty TestSuites.Module.OSName value.'
    }
    $invalidOsNames = @($osNames | Where-Object { -not $_ -or -not $_.ToString().Trim() })
    if ($invalidOsNames.Count -gt 0) {
        throw 'Settings JSON contains one or more null or empty TestSuites.Module.OSName values.'
    }
    Write-Host "Cleaning up test repositories for OSes: $($osNames -join ', ')"

    foreach ($authCase in $authCases) {
        $authCase.GetEnumerator() | ForEach-Object { Set-Variable -Name $_.Key -Value $_.Value }

        if ($TokenType -eq 'GITHUB_TOKEN') {
            Write-Host "Skipping teardown for $AuthType-$TokenType (uses existing repository)"
            continue
        }

        LogGroup "Teardown - $AuthType-$TokenType" {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            if ($AuthType -eq 'APP') {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
            }
            Write-Host ($context | Format-List | Out-String)

            foreach ($os in $osNames) {
                $repoPrefix = "$prefix-$os-$TokenType"
                $repoName = "$repoPrefix-$id"

                LogGroup "Repository cleanup - $AuthType-$TokenType - $os" {
                    # Use deterministic name lookups instead of listing all repos to reduce API calls.
                    $cleanupRepoNames = @($repoName)
                    if ($OwnerType -eq 'organization') {
                        $cleanupRepoNames += "$repoName-2", "$repoName-3"
                    }

                    foreach ($cleanupRepoName in $cleanupRepoNames) {
                        switch ($OwnerType) {
                            'user' {
                                Get-GitHubRepository -Name $cleanupRepoName -ErrorAction SilentlyContinue |
                                    Remove-GitHubRepository -Confirm:$false
                            }
                            'organization' {
                                Get-GitHubRepository -Owner $Owner -Name $cleanupRepoName -ErrorAction SilentlyContinue |
                                    Remove-GitHubRepository -Confirm:$false
                            }
                        }
                    }
                }
            }

            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }
    }
}
