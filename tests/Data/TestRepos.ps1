# Test files that require their own per-test-file repository.
# Each test file's per-context BeforeAll also calls Set-GitHubRepository as a safety net,
# so this list is an optimization rather than a hard dependency. BeforeAll.ps1 and
# AfterAll.ps1 both source this file so setup and teardown always operate on the same set.
@{
    # Test files that each need a primary repository.
    TestNames                  = @('Environments', 'Secrets', 'Variables', 'Releases', 'Actions')

    # Subset that also need companion -2/-3 repositories for org-scoped SelectedRepository tests.
    TestNamesWithExtraRepos    = @('Secrets', 'Variables')
}
