# Users and apps used for the testing framework

## User

Login: 'psmodule-user'
Owner of:
- [psmodule-user](https://github.com/psmodule-user) (standalone org)
- [psmodule-test-org2](https://github.com/orgs/psmodule-test-org2) (standalone org)

Secrets:
- TEST_USER_PAT -> 'psmodule-user' (user)
- TEST_USER_USER_FG_PAT -> 'psmodule-user' (user)
- TEST_USER_ORG_FG_PAT -> 'psmodule-test-org2' (org)


## APP_ENT - PSModule Enterprise App

Homed in 'MSX'
ClientID: 'Iv23lieHcDQDwVV3alK1'
Installed on:
- [psmodule-test-org3](https://github.com/orgs/psmodule-test-org3) (enterprise org)
Permissions:
- All
Events:
- Push

Secrets:
- TEST_APP_ENT_CLIENT_ID
- TEST_APP_ENT_PRIVATE_KEY

## APP_ORG - PSModule Organization App

Homed in PSModule
ClientID: 'Iv23liYDnEbKlS9IVzHf'
Installed on:
- [psmodule-test-org](https://github.com/orgs/psmodule-test-org) (standalone org)
Permissions:
- All
Events:
- Push

Secrets:
- TEST_APP_ORG_CLIENT_ID
- TEST_APP_ORG_PRIVATE_KEY

## Auth cases

[AuthCases.ps1](../tests/Data/AuthCases.ps1) defines 7 auth cases. Each test file iterates over all cases, skipping those
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

Cases 4 (`repository`) and 7 (`enterprise`) skip repo creation. Cases 1 and 3 share the same user owner (`psmodule-user`)
but have different `$TokenType` values, so repo names are unique.

## Setup and teardown

Shared test infrastructure is provisioned once per workflow run using `BeforeAll.ps1` and torn down using `AfterAll.ps1`.
For generic guidance on setup/teardown scripts, see the
[Process-PSModule documentation](https://github.com/PSModule/Process-PSModule#setup-and-teardown-scripts).

### `BeforeAll.ps1` — global setup

Runs once before all parallel test files. For each auth case (except `GITHUB_TOKEN`):

1. Connects using the auth case credentials
2. Cleans up stale repos from previous failed runs (matching `Test-$os-$TokenType-*`)
3. Creates a shared repository per OS: `Test-{OS}-{TokenType}-{GITHUB_RUN_ID}`
   - For `user` owners: `New-GitHubRepository -Name $repoName`
   - For `organization` owners: `New-GitHubRepository -Organization $Owner -Name $repoName`

### `AfterAll.ps1` — global teardown

Runs once after all parallel test files complete. For each auth case (except `GITHUB_TOKEN`):

1. Connects using the auth case credentials
2. Removes all repositories matching the `Test-{OS}-{TokenType}-*` prefix

## Test file pattern

Each test file follows this pattern:

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
            # Connect
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            if ($AuthType -eq 'APP') {
                $context = Connect-GitHubApp @connectAppParams -PassThru -Default -Silent
            }

            # Reference the shared repo (NOT New-GitHubRepository)
            $repoPrefix = "Test-$os-$TokenType"
            $repoName = "$repoPrefix-$id"
            $repo = Get-GitHubRepository -Owner $Owner -Name $repoName
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

### Key conventions

- **`$id = $env:GITHUB_RUN_ID`** — not `[guid]::NewGuid()` or `Get-Random`. This makes the repo name deterministic
  per workflow run so shared infrastructure can be referenced by name.
- **`Get-GitHubRepository`** — test files fetch the shared repo, they do not create repos.
- **`-Skip:($OwnerType -in ('repository', 'enterprise'))`** — standard skip condition for repo-dependent tests.
- **`Disconnect-GitHubAccount`** — every context disconnects all sessions in `AfterAll`.
- Test-specific ephemeral resources (releases, secrets, variables, environments, teams) are still created and cleaned up
  within each test file. Only repositories are shared.

## Naming conventions

| Resource   | Pattern                                      | Example                          |
|------------|----------------------------------------------|----------------------------------|
| Repo       | `Test-{OS}-{TokenType}-{RunID}`              | `Test-Linux-USER_FG_PAT-1234`   |
| Extra repo | `Test-{OS}-{TokenType}-{RunID}-{N}`          | `Test-Linux-USER_FG_PAT-1234-1` |
| Secret     | `{TestName}_{OS}_{TokenType}_{RunID}`        | `Secrets_Linux_PAT_1234`         |
| Variable   | `{TestName}_{OS}_{TokenType}_{RunID}`        | `Variables_Linux_PAT_1234`       |
| Team       | `{TestName}_{OS}_{TokenType}_{RunID}_{Name}` | `Teams_Linux_APP_ORG_1234_Pull`  |
| Env        | `{TestName}-{OS}-{TokenType}-{RunID}`        | `Secrets-Linux-PAT-1234`         |
