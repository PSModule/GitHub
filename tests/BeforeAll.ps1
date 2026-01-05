<#
.SYNOPSIS
    Global setup script that runs once before all parallel tests.

.DESCRIPTION
    This script is executed by the Process-PSModule workflow before any tests run.
    It performs infrastructure setup tasks that benefit all test runs:
    - Cleans up stale resources from previous failed test runs
    - Reduces rate limiting by removing orphaned test artifacts upfront

    Individual test files still handle their own:
    - Authentication (Connect-GitHubAccount, Connect-GitHubApp)
    - Resource creation (repositories, teams, environments)
    - Resource cleanup (in their AfterAll blocks)

.NOTES
    This script is called automatically by Process-PSModule workflow.
    Tests continue to create their own isolated resources to support parallel execution.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$WarningPreference = 'Continue'

LogGroup 'BeforeAll - Global Test Setup' {
    Write-Host "Starting global test setup at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
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

    Write-Host "`nCleaning up stale resources from previous test runs..."
    Write-Host "Test prefixes to clean: $($testPrefixes -join ', ')"

    # Process each auth case to clean up stale resources
    foreach ($authCase in $authCases) {
        $owner = $authCase.Owner
        $ownerType = $authCase.OwnerType
        $tokenType = $authCase.TokenType
        $authType = $authCase.AuthType

        LogGroup "Cleanup - $owner ($ownerType) using $tokenType" {
            try {
                # Connect to GitHub
                Write-Host "Connecting to GitHub as $owner..."
                $context = Connect-GitHubAccount @($authCase.ConnectParams) -PassThru -Silent -ErrorAction Stop

                # For APP auth, also connect to the app installation
                if ($authType -eq 'APP') {
                    Write-Host "Connecting to GitHub App installation..."
                    $context = Connect-GitHubApp @($authCase.ConnectAppParams) -PassThru -Default -Silent -ErrorAction Stop
                }

                # Clean up repositories
                Write-Host "Checking for stale repositories..."
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
                        Write-Host "Found $($repos.Count) stale repositories to remove"
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
                        Write-Host "No stale repositories found"
                    }
                } catch {
                    Write-Warning "Error cleaning repositories: $_"
                    $stats.Errors++
                }

                # Clean up teams (organization only)
                if ($ownerType -eq 'organization') {
                    Write-Host "Checking for stale teams..."
                    try {
                        $teams = Get-GitHubTeam -Organization $owner -ErrorAction SilentlyContinue |
                            Where-Object {
                                $teamName = $_.Name
                                $testPrefixes | Where-Object { $teamName -like "$_*" }
                            }

                        if ($teams) {
                            Write-Host "Found $($teams.Count) stale teams to remove"
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
                            Write-Host "No stale teams found"
                        }
                    } catch {
                        Write-Warning "Error cleaning teams: $_"
                        $stats.Errors++
                    }

                    # Clean up organization secrets
                    Write-Host "Checking for stale organization secrets..."
                    try {
                        $secrets = Get-GitHubSecret -Owner $owner -ErrorAction SilentlyContinue |
                            Where-Object {
                                $secretName = $_.Name
                                $testPrefixes | Where-Object { $secretName -like "$_*" }
                            }

                        if ($secrets) {
                            Write-Host "Found $($secrets.Count) stale secrets to remove"
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
                            Write-Host "No stale secrets found"
                        }
                    } catch {
                        Write-Warning "Error cleaning secrets: $_"
                        $stats.Errors++
                    }

                    # Clean up organization variables
                    Write-Host "Checking for stale organization variables..."
                    try {
                        $variables = Get-GitHubVariable -Owner $owner -ErrorAction SilentlyContinue |
                            Where-Object {
                                $variableName = $_.Name
                                $testPrefixes | Where-Object { $variableName -like "$_*" }
                            }

                        if ($variables) {
                            Write-Host "Found $($variables.Count) stale variables to remove"
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
                            Write-Host "No stale variables found"
                        }
                    } catch {
                        Write-Warning "Error cleaning variables: $_"
                        $stats.Errors++
                    }
                }

                # Clean up app installations (APP auth only)
                if ($authType -eq 'APP') {
                    Write-Host "Checking for stale app installations..."
                    try {
                        # Reconnect as the app (not installation) to manage installations
                        Disconnect-GitHubAccount -Silent
                        $context = Connect-GitHubAccount @($authCase.ConnectParams) -PassThru -Silent -ErrorAction Stop

                        $installations = Get-GitHubAppInstallation -ErrorAction SilentlyContinue |
                            Where-Object {
                                $targetName = $_.Target.Name
                                $testPrefixes | Where-Object { $targetName -like "$_*" }
                            }

                        if ($installations) {
                            Write-Host "Found $($installations.Count) stale app installations to remove"
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
                            Write-Host "No stale app installations found"
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
    LogGroup 'Cleanup Summary' {
        Write-Host "`nGlobal test setup completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        Write-Host "Cleanup Statistics:"
        Write-Host "  Repositories removed:      $($stats.RepositoriesRemoved)"
        Write-Host "  Teams removed:             $($stats.TeamsRemoved)"
        Write-Host "  Environments removed:      $($stats.EnvironmentsRemoved)"
        Write-Host "  Secrets removed:           $($stats.SecretsRemoved)"
        Write-Host "  Variables removed:         $($stats.VariablesRemoved)"
        Write-Host "  App installations removed: $($stats.AppInstallationsRemoved)"
        Write-Host "  Errors encountered:        $($stats.Errors)"
        Write-Host ""

        if ($stats.Errors -gt 0) {
            Write-Warning "Some cleanup operations failed. Tests may encounter issues with existing resources."
        } else {
            Write-Host "All cleanup operations completed successfully."
        }
    }
}

Write-Host "BeforeAll.ps1 completed"
