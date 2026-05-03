---
description: "Use when writing, editing, or reviewing Pester test files under the tests/ folder. Covers per-test-file repository setup, self-contained test lifecycle, auth case iteration, naming conventions, and skip patterns for the GitHub module integration tests."
applyTo: "tests/**"
---
# Integration Test Conventions

## Test infrastructure accounts

### User

Login: `psmodule-user`
Owner of:

- [psmodule-user](https://github.com/psmodule-user) (standalone org)
- [psmodule-test-org2](https://github.com/orgs/psmodule-test-org2) (standalone org)

Secrets:

- `TEST_USER_PAT` → `psmodule-user` (user)
- `TEST_USER_USER_FG_PAT` → `psmodule-user` (user)
- `TEST_USER_ORG_FG_PAT` → `psmodule-test-org2` (org)

### APP_ENT — PSModule Enterprise App

Homed in `MSX`. ClientID: `Iv23lieHcDQDwVV3alK1`.
Installed on [psmodule-test-org3](https://github.com/orgs/psmodule-test-org3) (enterprise org) with all permissions and push events.

Required enterprise-scoped permissions (configured on the app, homed in `msx`):

- `enterprise_organization_installations: write` — required by `Install-GitHubApp` on enterprise-owned organizations
  ([docs](https://docs.github.com/rest/enterprise-admin/organization-installations#install-a-github-app-on-an-enterprise-owned-organization)).
  The Organizations test creates an enterprise organization and then installs the app on it; the
  endpoint returns 404 (not 403) when this permission is missing, which makes a missing
  permission look like a missing resource. See issue #596.

Secrets: `TEST_APP_ENT_CLIENT_ID`, `TEST_APP_ENT_PRIVATE_KEY`

### APP_ORG — PSModule Organization App

Homed in `PSModule`. ClientID: `Iv23liYDnEbKlS9IVzHf`.
Installed on [psmodule-test-org](https://github.com/orgs/psmodule-test-org) (standalone org) with all permissions and push events.

Secrets: `TEST_APP_ORG_CLIENT_ID`, `TEST_APP_ORG_PRIVATE_KEY`

## Auth cases

`AuthCases.ps1` defines 7 auth cases. Each test file iterates over all cases, skipping those
that don't apply (e.g., `repository` and `enterprise` owner types skip repo-dependent tests).

| # | AuthType | TokenType     | Owner              | OwnerType    |
|---|----------|---------------|--------------------|--------------|
| 1 | PAT      | USER_FG_PAT   | psmodule-user      | user         |
| 2 | PAT      | ORG_FG_PAT    | psmodule-test-org2 | organization |
| 3 | PAT      | PAT           | psmodule-user      | user         |
| 4 | IAT      | GITHUB_TOKEN  | PSModule           | repository   |
| 5 | App      | APP_ORG       | psmodule-test-org  | organization |
| 6 | App      | APP_ENT       | psmodule-test-org3 | organization |
| 7 | App      | APP_ENT       | msx                | enterprise   |

Cases 4 (`repository`) and 7 (`enterprise`) skip repo creation. Cases 1 and 3 share the same user owner
(`psmodule-user`) but have different `$TokenType` values, so repo names are unique.

## Setup and teardown

Test infrastructure is provisioned once per workflow run using `BeforeAll.ps1` and torn down using `AfterAll.ps1`.
For generic guidance on setup/teardown scripts, see the
[Process-PSModule documentation](https://github.com/PSModule/Process-PSModule#setup-and-teardown-scripts).

Each test file gets its own repository, scoped by test name: `{TestName}-{OS}-{TokenType}-{RunID}`. This
eliminates cross-file resource collisions when test files run in parallel across OSes and in sequence
across auth contexts.

### `BeforeAll.ps1` — global setup

Runs once before all parallel test files. For each auth case (except `GITHUB_TOKEN`):

1. Connects using the auth case credentials
2. Removes any existing repositories for the deterministic names used by the run
3. Provisions a per-test-file repository per OS using `Set-GitHubRepository`: `{TestName}-{OS}-{TokenType}-{GITHUB_RUN_ID}`
   - Includes `-AddReadme`, `-License 'mit'`, and `-Gitignore 'VisualStudio'` so tests have a default branch with content
   - For `user` owners: `Set-GitHubRepository -Name $repoName ...`
   - For `organization` owners: `Set-GitHubRepository -Organization $Owner -Name $repoName ...`
4. For `organization` owners only, provisions extra repositories (`-2`, `-3` suffix) for
   test files that need companion repos (e.g., Secrets/Variables `SelectedRepository` tests)

`Set-GitHubRepository` is idempotent — if the repository already exists it updates it in place (issuing a
PATCH), and if it does not exist it creates it. Because the same parameters are passed each time, the
end-state is identical regardless of how many times the setup runs. The extra PATCH on the happy path is
a deliberate trade-off for simplicity: one call handles both first-run and partial-rerun scenarios without
branching logic.

### `AfterAll.ps1` — global teardown

Runs once after all parallel test files complete. For each auth case (except `GITHUB_TOKEN`):

1. Connects using the auth case credentials
2. Removes the per-test-file repositories by their deterministic names

## Per-test-file repositories

Each test file that depends on a GitHub repository uses its own repository, scoped by test name:
`{TestName}-{OS}-{TokenType}-{RunID}`. This prevents cross-file resource collisions — test files
run in parallel across OSes and in sequence across auth contexts, so one test file must never
create resources on another test file's repository.

Each test file must ensure its repository exists using `Set-GitHubRepository` in its per-context
`BeforeAll`. `Set-GitHubRepository` is idempotent — if the repository already exists it updates it
in place (PATCH), and if it does not exist it creates it. When the same parameters are passed each
time the end-state is identical. This makes every test file self-sufficient regardless of whether
the global `BeforeAll.ps1` already provisioned the repository.

**Do not** use `Get-GitHubRepository` with a throw guard — that breaks partial reruns.
**Do not** use `New-GitHubRepository` — that fails if the repository already exists.

Primary repositories use `-AddReadme`, `-License 'mit'`, and `-Gitignore 'VisualStudio'` so that
a default branch with content is available for tests that need commits (e.g., releases, tags).

Some auth cases (e.g., `repository`, `enterprise`) do not operate on a user- or org-owned repository.
Skip provisioning for those owner types and set `$repo = $null` so that repo-dependent tests can
be skipped cleanly:

```powershell
$repoPrefix = "$testName-$os-$TokenType"
$repoName = "$repoPrefix-$id"
if ($OwnerType -in ('repository', 'enterprise')) {
    $repo = $null
} else {
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

            $repoPrefix = "$testName-$os-$TokenType"
            $repoName = "$repoPrefix-$id"
            if ($OwnerType -in ('repository', 'enterprise')) {
                $repo = $null
            } else {
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

            # Clean up stale resources from prior runs (re-runs with same GITHUB_RUN_ID)
            # Example: remove leftover releases, environments, etc.
        }

        AfterAll {
            # Remove all test-specific resources created during this context
            # (environments, releases, secrets, etc.)
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
        }

        It 'Should do something' -Skip:($OwnerType -in ('repository', 'enterprise')) {
            # Test logic using $repo, $Owner, $repoName
        }
    }
}
```

## Naming conventions

| Resource   | Pattern                                      | Example                               |
|------------|----------------------------------------------|---------------------------------------|
| Repo       | `{TestName}-{OS}-{TokenType}-{RunID}`        | `Releases-Linux-USER_FG_PAT-1234`     |
| Extra repo | `{TestName}-{OS}-{TokenType}-{RunID}-{N}`    | `Secrets-Linux-ORG_FG_PAT-1234-2`     |
| Secret     | `{TestName}_{OS}_{TokenType}_{RunID}`        | `Secrets_Linux_PAT_1234`              |
| Variable   | `{TestName}_{OS}_{TokenType}_{RunID}`        | `Variables_Linux_PAT_1234`            |
| Team       | `{TestName}_{OS}_{TokenType}_{RunID}_{Name}` | `Teams_Linux_APP_ORG_1234_Pull`       |
| Env        | `{TestName}-{OS}-{TokenType}-{RunID}`        | `Secrets-Linux-PAT-1234`              |

## Key rules

- `$id` must always be `$env:GITHUB_RUN_ID` — never `[guid]::NewGuid()` or `Get-Random`.
- Skip repo-dependent tests with `-Skip:($OwnerType -in ('repository', 'enterprise'))`.
- Disconnect all sessions in `AfterAll`: `Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent`.
- Each test file uses its own repository: `{TestName}-{OS}-{TokenType}-{RunID}`. No two test files share a repository.
- Each test file is self-contained and responsible for its own setup and teardown:
  - **BeforeAll (per-context):** Ensure the repository exists via `Set-GitHubRepository`. Clean up stale test-specific resources from prior runs (re-runs with the same `GITHUB_RUN_ID`).
  - **AfterAll (per-context):** Remove all test-specific resources created during the run (environments, releases, secrets, variables, etc.).
- Any individual test file or auth context can be re-run independently. Tests must not assume clean initial state — they must be idempotent.
- Tests run in parallel across OSes (Linux, macOS, Windows) and in sequence across auth contexts (7 cases). Resource names must include enough dimensions to prevent collisions across all parallel and sequential axes.
- `Repositories.Tests.ps1` is independent — it creates and deletes its own repos because it tests CRUD.
