# Test Setup/Teardown Scripts

This document describes the global test setup and teardown scripts used in the GitHub module test suite.

## Overview

The GitHub module uses Process-PSModule's BeforeAll/AfterAll support to optimize test execution and reduce rate limiting issues.

### Key Concepts

1. **BeforeAll.ps1** - Runs once before all parallel test jobs
   - Cleans up stale resources from previous failed test runs
   - Reduces rate limiting by removing orphaned artifacts upfront
   - Does NOT replace individual test BeforeAll blocks

2. **AfterAll.ps1** - Runs once after all parallel test jobs complete
   - Performs final cleanup of any remaining test resources
   - Provides a safety net for resources missed by individual tests
   - Generates a cleanup report

3. **Individual Test Files** - Keep their existing BeforeAll/AfterAll blocks
   - Handle authentication (Connect-GitHubAccount, Connect-GitHubApp)
   - Create and clean up their own isolated resources
   - Support parallel execution across different auth scenarios

## How It Works

### Before Tests Run

```
Process-PSModule Workflow
  ↓
BeforeAll.ps1 (runs once)
  ↓
Parallel Test Matrix
  ├─ Test File 1 → BeforeAll → Tests → AfterAll
  ├─ Test File 2 → BeforeAll → Tests → AfterAll
  └─ Test File 3 → BeforeAll → Tests → AfterAll
  ↓
AfterAll.ps1 (runs once)
```

### What Gets Cleaned Up

Both BeforeAll.ps1 and AfterAll.ps1 clean up test resources across all authentication scenarios:

- **Repositories**: Any repository with test name prefixes (e.g., `RepositoriesTests-*`)
- **Teams**: Teams created during tests (organization contexts only)
- **Secrets**: Organization secrets created during tests
- **Variables**: Organization variables created during tests
- **App Installations**: GitHub App installations on test organizations (APP auth only)

### Resource Naming Convention

Tests use a consistent naming pattern that allows the cleanup scripts to identify test resources:

```powershell
$testName = 'RepositoriesTests'  # Test file identifier
$os = $env:RUNNER_OS             # Linux, Windows, macOS
$tokenType = 'USER_FG_PAT'       # Auth type identifier
$guid = [guid]::NewGuid()        # Unique run identifier

$resourceName = "$testName-$os-$tokenType-$guid"
```

Examples:
- `RepositoriesTests-Linux-USER_FG_PAT-a1b2c3d4`
- `TeamsTests-Windows-APP_ORG-e5f6g7h8`

The cleanup scripts look for resources matching the test name prefixes (e.g., `RepositoriesTests-*`).

## Benefits

1. **Speed**: Pre-cleanup ensures tests don't encounter conflicts with stale resources
2. **Rate Limiting**: Significantly fewer API calls by removing orphaned resources upfront
3. **Reliability**: Consistent test environment across all test runs
4. **Cost**: Fewer parallel operations hitting API rate limits
5. **Maintainability**: Centralized cleanup logic in two files

## Test Prefixes

The following test prefixes are recognized by the cleanup scripts:

- `RepositoriesTests`
- `TeamsTests`
- `EnvironmentsTests`
- `SecretsTests`
- `VariablesTests`
- `AppsTests`
- `ArtifactsTests`
- `ReleasesTests`
- `PermissionsTests`
- `MsxOrgTests`
- `GitHubTests`

## Authentication Scenarios

The cleanup scripts process all authentication scenarios defined in `tests/Data/AuthCases.ps1`:

1. **Fine-grained PAT** - User account (`psmodule-user`)
2. **Fine-grained PAT** - Organization account (`psmodule-test-org2`)
3. **Classic PAT** - User account (`psmodule-user`)
4. **GitHub Actions Token** - Repository context (`PSModule/GitHub`)
5. **GitHub App** - Organization installation (`psmodule-test-org`)
6. **GitHub App** - Enterprise installation (`psmodule-test-org3`)
7. **GitHub App** - Enterprise context (`msx`)

## Cleanup Statistics

Both scripts generate statistics showing:
- Number of repositories removed
- Number of teams removed
- Number of secrets removed
- Number of variables removed
- Number of app installations removed
- Number of errors encountered

## Example Output

```
BeforeAll - Global Test Setup
  Cleanup - psmodule-user (user) using USER_FG_PAT
    Connecting to GitHub as psmodule-user...
    Checking for stale repositories...
    Found 3 stale repositories to remove
      Removing repository: psmodule-user/RepositoriesTests-Linux-USER_FG_PAT-old1
      Removing repository: psmodule-user/TeamsTests-Linux-USER_FG_PAT-old2
      Removing repository: psmodule-user/SecretsTests-Linux-USER_FG_PAT-old3
    No stale teams found

  Cleanup Summary
    Repositories removed:      12
    Teams removed:             5
    Secrets removed:           3
    Variables removed:         2
    App installations removed: 0
    Errors encountered:        0
    
    All cleanup operations completed successfully.
```

## Troubleshooting

### Tests Fail Due to Missing Resources

The cleanup scripts only remove resources that match test name prefixes. If your tests are failing due to missing resources, ensure your test is creating its own resources in the BeforeAll block.

### Cleanup Script Errors

If the cleanup scripts encounter errors, they will continue processing other resources. Check the error messages in the workflow logs to identify the issue. Common causes:
- Insufficient permissions for the authentication token
- Rate limiting (should be rare with pre-cleanup)
- Network connectivity issues

### Resources Not Being Cleaned

Ensure your test resources follow the naming convention: `{TestName}-{OS}-{TokenType}-{GUID}`

The cleanup scripts look for resources starting with the test name prefixes listed above.
