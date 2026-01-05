<#
.SYNOPSIS
    Global teardown script that runs once after all parallel tests complete.

.DESCRIPTION
    This script is executed by the Process-PSModule workflow after all tests have run.
    It performs final cleanup tasks to ensure no test artifacts are left behind:
    - Removes any remaining test resources that weren't cleaned up by individual tests
    - Generates a final cleanup report
    - Helps prevent resource accumulation from failed tests

    Individual test files handle their own cleanup in AfterAll blocks, but this
    provides a safety net for any resources that might have been missed.

.NOTES
    This script is called automatically by Process-PSModule workflow.
    It uses the same cleanup logic as BeforeAll.ps1 to ensure consistent cleanup.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$WarningPreference = 'Continue'

LogGroup 'AfterAll - Global Test Teardown' {
    Write-Host "Starting global test teardown at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "Runner OS: $env:RUNNER_OS"
    Write-Host "GitHub Actions: $env:GITHUB_ACTIONS"

    # Track statistics
    $stats = @{
        RepositoriesRemoved      = 0
        TeamsRemoved             = 0
        EnvironmentsRemoved      = 0
        SecretsRemoved           = 0
        VariablesRemoved         = 0
        AppInstallationsRemoved  = 0
        Errors                   = 0
    }

    # Test name prefixes used across test files
    $testPrefixes = @(
        'RepositoriesTests'
        'TeamsTests'
        'EnvironmentsTests'
        'SecretsTests'
        'VariablesTests'
        'AppsTests'
        'ArtifactsTests'
        'ReleasesTests'
        'PermissionsTests'
        'MsxOrgTests'
        'GitHubTests'
    )

    # Get all authentication scenarios
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Write-Host "`nPerforming final cleanup of test resources..."
    Write-Host "Test prefixes to clean: $($testPrefixes -join ', ')"

    # Process each auth case to clean up remaining resources
    foreach ($authCase in $authCases) {
        $owner = $authCase.Owner
        $ownerType = $authCase.OwnerType
        $tokenType = $authCase.TokenType
        $authType = $authCase.AuthType

        LogGroup "Final Cleanup - $owner ($ownerType) using $tokenType" {
            try {
                # Connect to GitHub
                Write-Host "Connecting to GitHub as $owner..."
                $context = Connect-GitHubAccount @authCase.ConnectParams -PassThru -Silent -ErrorAction Stop
                Write-Host "Connected as: $($context.Login)"

                # For APP auth, also connect to the app installation
                if ($authType -eq 'APP') {
                    Write-Host "Connecting to GitHub App installation..."
                    $context = Connect-GitHubApp @authCase.ConnectAppParams -PassThru -Default -Silent -ErrorAction Stop
                    Write-Host "Connected to installation: $($context.Installation.ID)"
                }

                # Clean up repositories
                Write-Host "Checking for remaining repositories..."
                try {
                    $repos = switch ($ownerType) {
                        'user' {
                            Get-GitHubRepository -ErrorAction SilentlyContinue |
                                Where-Object {
                                    $repoName = $_.Name
                                    $testPrefixes | Where-Object { $repoName -like "$_-*" }
                                }
                        }
                        'organization' {
                            Get-GitHubRepository -Organization $owner -ErrorAction SilentlyContinue |
                                Where-Object {
                                    $repoName = $_.Name
                                    $testPrefixes | Where-Object { $repoName -like "$_-*" }
                                }
                        }
                        default { @() }
                    }

                    if ($repos) {
                        Write-Host "Found $($repos.Count) repositories to remove"
                        foreach ($repo in $repos) {
                            try {
                                Write-Host "  Removing repository: $($repo.FullName)"
                                $repo | Remove-GitHubRepository -Confirm:$false -ErrorAction Stop
                                $stats.RepositoriesRemoved++
                            } catch {
                                Write-Warning "  Failed to remove repository $($repo.FullName): $_"
                                $stats.Errors++
                            }
                        }
                    } else {
                        Write-Host "No repositories found (good - tests cleaned up after themselves)"
                    }
                } catch {
                    Write-Warning "Error cleaning repositories: $_"
                    $stats.Errors++
                }

                # Clean up teams (organization only)
                if ($ownerType -eq 'organization') {
                    Write-Host "Checking for remaining teams..."
                    try {
                        $teams = Get-GitHubTeam -Organization $owner -ErrorAction SilentlyContinue |
                            Where-Object {
                                $teamName = $_.Name
                                $testPrefixes | Where-Object { $teamName -like "$_*" }
                            }

                        if ($teams) {
                            Write-Host "Found $($teams.Count) teams to remove"
                            foreach ($team in $teams) {
                                try {
                                    Write-Host "  Removing team: $($team.Name)"
                                    $team | Remove-GitHubTeam -Confirm:$false -ErrorAction Stop
                                    $stats.TeamsRemoved++
                                } catch {
                                    Write-Warning "  Failed to remove team $($team.Name): $_"
                                    $stats.Errors++
                                }
                            }
                        } else {
                            Write-Host "No teams found (good - tests cleaned up after themselves)"
                        }
                    } catch {
                        Write-Warning "Error cleaning teams: $_"
                        $stats.Errors++
                    }

                    # Clean up organization secrets
                    Write-Host "Checking for remaining organization secrets..."
                    try {
                        $secrets = Get-GitHubSecret -Owner $owner -ErrorAction SilentlyContinue |
                            Where-Object {
                                $secretName = $_.Name
                                $testPrefixes | Where-Object { $secretName -like "$_*" }
                            }

                        if ($secrets) {
                            Write-Host "Found $($secrets.Count) secrets to remove"
                            foreach ($secret in $secrets) {
                                try {
                                    Write-Host "  Removing secret: $($secret.Name)"
                                    $secret | Remove-GitHubSecret -ErrorAction Stop
                                    $stats.SecretsRemoved++
                                } catch {
                                    Write-Warning "  Failed to remove secret $($secret.Name): $_"
                                    $stats.Errors++
                                }
                            }
                        } else {
                            Write-Host "No secrets found (good - tests cleaned up after themselves)"
                        }
                    } catch {
                        Write-Warning "Error cleaning secrets: $_"
                        $stats.Errors++
                    }

                    # Clean up organization variables
                    Write-Host "Checking for remaining organization variables..."
                    try {
                        $variables = Get-GitHubVariable -Owner $owner -ErrorAction SilentlyContinue |
                            Where-Object {
                                $variableName = $_.Name
                                $testPrefixes | Where-Object { $variableName -like "$_*" }
                            }

                        if ($variables) {
                            Write-Host "Found $($variables.Count) variables to remove"
                            foreach ($variable in $variables) {
                                try {
                                    Write-Host "  Removing variable: $($variable.Name)"
                                    $variable | Remove-GitHubVariable -ErrorAction Stop
                                    $stats.VariablesRemoved++
                                } catch {
                                    Write-Warning "  Failed to remove variable $($variable.Name): $_"
                                    $stats.Errors++
                                }
                            }
                        } else {
                            Write-Host "No variables found (good - tests cleaned up after themselves)"
                        }
                    } catch {
                        Write-Warning "Error cleaning variables: $_"
                        $stats.Errors++
                    }
                }

                # Clean up app installations (APP auth only)
                if ($authType -eq 'APP') {
                    Write-Host "Checking for remaining app installations..."
                    try {
                        # Reconnect as the app (not installation) to manage installations
                        Disconnect-GitHubAccount -Silent
                        $context = Connect-GitHubAccount @authCase.ConnectParams -PassThru -Silent -ErrorAction Stop
                        Write-Host "Reconnected as app: $($context.ClientID)"

                        $installations = Get-GitHubAppInstallation -ErrorAction SilentlyContinue |
                            Where-Object {
                                $targetName = $_.Target.Name
                                $testPrefixes | Where-Object { $targetName -like "$_*" }
                            }

                        if ($installations) {
                            Write-Host "Found $($installations.Count) app installations to remove"
                            foreach ($installation in $installations) {
                                try {
                                    Write-Host "  Uninstalling from: $($installation.Target.Name)"
                                    $installation | Uninstall-GitHubApp -Confirm:$false -ErrorAction Stop
                                    $stats.AppInstallationsRemoved++
                                } catch {
                                    Write-Warning "  Failed to uninstall from $($installation.Target.Name): $_"
                                    $stats.Errors++
                                }
                            }
                        } else {
                            Write-Host "No app installations found (good - tests cleaned up after themselves)"
                        }
                    } catch {
                        Write-Warning "Error cleaning app installations: $_"
                        $stats.Errors++
                    }
                }

                # Disconnect after cleanup
                Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent

            } catch {
                Write-Warning "Failed to process $owner ($ownerType): $_"
                $stats.Errors++
                # Ensure we disconnect even on error
                Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            }
        }
    }

    # Report cleanup statistics
    LogGroup 'Final Cleanup Summary' {
        Write-Host "`nGlobal test teardown completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Host "Final Cleanup Statistics:"
        Write-Host "  Repositories removed:      $($stats.RepositoriesRemoved)"
        Write-Host "  Teams removed:             $($stats.TeamsRemoved)"
        Write-Host "  Environments removed:      $($stats.EnvironmentsRemoved)"
        Write-Host "  Secrets removed:           $($stats.SecretsRemoved)"
        Write-Host "  Variables removed:         $($stats.VariablesRemoved)"
        Write-Host "  App installations removed: $($stats.AppInstallationsRemoved)"
        Write-Host "  Errors encountered:        $($stats.Errors)"
        Write-Host ""

        if ($stats.RepositoriesRemoved -eq 0 -and $stats.TeamsRemoved -eq 0 -and
            $stats.SecretsRemoved -eq 0 -and $stats.VariablesRemoved -eq 0) {
            Write-Host "✓ Excellent! All tests cleaned up their resources properly."
        } elseif ($stats.Errors -eq 0) {
            Write-Host "✓ Final cleanup completed successfully. Some resources were left behind by tests."
        } else {
            Write-Warning "Some cleanup operations failed. Manual cleanup may be required."
        }
    }
}

Write-Host "AfterAll.ps1 completed"
