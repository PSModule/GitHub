---
description: "Use when writing, editing, or reviewing Pester test files under the tests/ folder. Covers shared repository setup, auth case iteration, naming conventions, and skip patterns for the GitHub module integration tests."
applyTo: "tests/**"
---
# Integration Test Conventions

## Shared test repositories

Each test file that depends on a GitHub repository must ensure it exists using `Set-GitHubRepository`
in its per-context `BeforeAll`. `Set-GitHubRepository` is idempotent — it returns the existing repository
if it already exists, or creates it if it does not. This makes every test file self-sufficient regardless
of whether the global `BeforeAll.ps1` already provisioned the repository.

**Do not** use `Get-GitHubRepository` with a throw guard — that breaks partial reruns.
**Do not** use `New-GitHubRepository` — that fails if the repository already exists.

Primary repositories use `-AddReadme`, `-License 'mit'`, and `-Gitignore 'VisualStudio'` so that
a default branch with content is available for tests that need commits (e.g., releases, tags).

```powershell
$repoPrefix = "Test-$os-$TokenType"
$repoName = "$repoPrefix-$id"
$repoParams = @{
    Name      = $repoName
    AddReadme = $true
    License   = 'mit'
    Gitignore = 'VisualStudio'
}
$repo = switch ($OwnerType) {
    'user'         { Set-GitHubRepository @repoParams }
    'organization' { Set-GitHubRepository @repoParams -Organization $Owner }
}
```

For organization-scoped tests that need companion repositories (Secrets/Variables `SelectedRepository`),
provision `-2` and `-3` variants the same way:

```powershell
$repo2 = Set-GitHubRepository -Organization $Owner -Name "$repoName-2"
$repo3 = Set-GitHubRepository -Organization $Owner -Name "$repoName-3"
```

## Test file structure

```powershell
BeforeAll {
    $testName = 'TestName'
    $os = $env:RUNNER_OS
    $id = $env:GITHUB_RUN_ID
}

Describe 'TestName' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            if ($AuthType -eq 'APP') {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
            }

            $repoPrefix = "Test-$os-$TokenType"
            $repoName = "$repoPrefix-$id"
            $repoParams = @{
                Name      = $repoName
                AddReadme = $true
                License   = 'mit'
                Gitignore = 'VisualStudio'
            }
            $repo = switch ($OwnerType) {
                'user'         { Set-GitHubRepository @repoParams }
                'organization' { Set-GitHubRepository @repoParams -Organization $Owner }
            }
        }

        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        It 'Should do something' -Skip:($OwnerType -in ('repository', 'enterprise')) {
            # Test logic using $repo, $Owner, $repoName
        }
    }
}
```

## Naming conventions

| Resource   | Pattern                                      | Example                        |
|------------|----------------------------------------------|--------------------------------|
| Repo       | `Test-{OS}-{TokenType}-{RunID}`              | `Test-Linux-USER_FG_PAT-1234`  |
| Extra repo | `Test-{OS}-{TokenType}-{RunID}-{N}`          | `Test-Linux-USER_FG_PAT-1234-2`|
| Secret     | `{TestName}_{OS}_{TokenType}_{RunID}`        | `Secrets_Linux_PAT_1234`       |
| Variable   | `{TestName}_{OS}_{TokenType}_{RunID}`        | `Variables_Linux_PAT_1234`     |
| Team       | `{TestName}_{OS}_{TokenType}_{RunID}_{Name}` | `Teams_Linux_APP_ORG_1234_Pull`|
| Env        | `{TestName}-{OS}-{TokenType}-{RunID}`        | `Secrets-Linux-PAT-1234`       |

## Key rules

- `$id` must always be `$env:GITHUB_RUN_ID` — never `[guid]::NewGuid()` or `Get-Random`.
- Skip repo-dependent tests with `-Skip:($OwnerType -in ('repository', 'enterprise'))`.
- Disconnect all sessions in `AfterAll`: `Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent`.
- Test-specific ephemeral resources (releases, secrets, variables, environments, teams) are created and
  cleaned up within each test file. Only repositories are shared.
- `Repositories.Tests.ps1` is the exception — it creates and deletes its own repos because it tests CRUD.
