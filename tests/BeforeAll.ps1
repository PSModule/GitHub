[CmdletBinding()]
param()

LogGroup 'BeforeAll - Global Test Setup' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"
    $id = $env:GITHUB_RUN_ID
    if (-not $id) {
        throw 'GITHUB_RUN_ID environment variable is not set. Refusing to create or clean up test repositories with a non-deterministic name.'
    }
    if (-not $env:Settings) {
        throw 'Settings environment variable is not set. Process-PSModule must populate it with the test suite configuration.'
    }

    # Derive the list of OS names from the Settings JSON provided by Process-PSModule.
    try {
        $settings = $env:Settings | ConvertFrom-Json
    } catch {
        throw "Settings environment variable does not contain valid JSON. Process-PSModule must populate it with a valid test suite configuration. $_"
    }

    $osNames = @($settings.TestSuites.Module.OSName | Sort-Object -Unique)
    if (-not $osNames) {
        throw 'Settings JSON must contain TestSuites.Module.OSName with at least one OS name.'
    }
    $invalidOsNames = @($osNames | Where-Object { -not $_ -or -not $_.ToString().Trim() })
    if ($invalidOsNames.Count -gt 0) {
        throw 'Settings JSON contains one or more null or empty values in TestSuites.Module.OSName.'
    }
    Write-Host "Creating test repositories for OSes: $($osNames -join ', ')"

    # Test files that require their own per-test-file repository.
    # Each test file's per-context BeforeAll also calls Set-GitHubRepository as a safety net,
    # so this list is an optimization rather than a hard dependency.
    $testNames = @('Environments', 'Secrets', 'Variables', 'Releases', 'Actions')

    # Test files that need companion repositories (-2, -3) for org-scoped SelectedRepository tests.
    $testNamesWithExtraRepos = @('Secrets', 'Variables')

    foreach ($authCase in $authCases) {
        $authCase.GetEnumerator() | ForEach-Object { Set-Variable -Name $_.Key -Value $_.Value }

        if ($TokenType -eq 'GITHUB_TOKEN') {
            Write-Host "Skipping setup for $AuthType-$TokenType (uses existing repository)"
            continue
        }

        $context = Connect-GitHubAccount @connectParams -PassThru -Silent
        if ($AuthType -eq 'APP') {
            $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
        }
        Write-Host ($context | Format-List | Out-String)

        foreach ($os in $osNames) {
            foreach ($testName in $testNames) {
                $repoPrefix = "$testName-$os-$TokenType"
                $repoName = "$repoPrefix-$id"

                LogGroup "Repository setup - $AuthType-$TokenType - $os - $testName" {
                    # Clean up repos from a previous attempt of the same run (re-runs).
                    # Use deterministic name lookups instead of listing all repos to reduce API calls.
                    $cleanupRepoNames = @($repoName)
                    if ($OwnerType -eq 'organization' -and $testName -in $testNamesWithExtraRepos) {
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

                    # Provision the primary per-test-file repository.
                    $repoParams = @{
                        Name      = $repoName
                        AddReadme = $true
                        License   = 'mit'
                        Gitignore = 'VisualStudio'
                    }
                    switch ($OwnerType) {
                        'user' { Set-GitHubRepository @repoParams }
                        'organization' { Set-GitHubRepository @repoParams -Organization $Owner }
                    }

                    # Provision extra repositories needed by Secrets/Variables SelectedRepository tests.
                    # Only organization owners need them — those tests are skipped for user owners.
                    if ($OwnerType -eq 'organization' -and $testName -in $testNamesWithExtraRepos) {
                        foreach ($suffix in 2, 3) {
                            Set-GitHubRepository -Organization $Owner -Name "$repoName-$suffix"
                        }
                    }
                }
            }
        }

        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
    }
}
