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
    $settings = $env:Settings | ConvertFrom-Json
    $osNames = @($settings.TestSuites.Module.OSName | Sort-Object -Unique)
    Write-Host "Creating test repositories for OSes: $($osNames -join ', ')"

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
            $repoPrefix = "Test-$os-$TokenType"
            $repoName = "$repoPrefix-$id"

            LogGroup "Repository setup - $AuthType-$TokenType - $os" {
                # Clean up repos from a previous attempt of the same run (re-runs).
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

                # Create the primary shared repository (with readme, license, gitignore for release tests).
                $repoParams = @{
                    Name      = $repoName
                    AddReadme = $true
                    License   = 'mit'
                    Gitignore = 'VisualStudio'
                }
                switch ($OwnerType) {
                    'user' {
                        New-GitHubRepository @repoParams
                    }
                    'organization' {
                        New-GitHubRepository @repoParams -Organization $Owner
                    }
                }

                # Create extra repositories needed by Secrets/Variables SelectedRepository tests.
                # Only organization owners need them — those tests are skipped for user owners.
                if ($OwnerType -eq 'organization') {
                    foreach ($suffix in 2, 3) {
                        $extraName = "$repoName-$suffix"
                        New-GitHubRepository -Organization $Owner -Name $extraName
                    }
                }
            }
        }

        Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
    }
}
