---
applyTo: '**/*.Tests.ps1'
description: Repository-specific Pester test patterns for GitHub module functionality.
---

# GitHub Module Pester Test Guidelines

## GitHub-Specific Test Structure
Follow the hierarchical structure defined in the GitHub Test Specification:

### GitHub Module-Level `Describe`
- Outermost block corresponds to GitHub module or component being tested
- Use descriptive names that identify the GitHub API area

### GitHub Function-Level Context
- Each GitHub function gets its own `Context` block within the module
- Name format: `Context 'Function: Get-GitHubRepository'`

### GitHub Use Case Context
- Group GitHub test cases by scenario within function context
- Name format: `Context 'Get-GitHubRepository - simple usage'`, `'Get-GitHubRepository - Pipeline usage'`
- Include GitHub-specific contexts: `'Get-GitHubRepository - Enterprise usage'`

## GitHub Authentication Test Cases
- Test with multiple GitHub authentication contexts: PAT, UAT, IAT, GitHub Apps
- Use GitHub auth cases from `tests/Data/AuthCases.ps1`
- Format: `Context 'As <Type> using <Case> on <Target>' -ForEach $authCases`
- Handle different GitHub environments (github.com, GHES, GHEC)

## GitHub Test Organization Pattern
```powershell
Describe 'GitHub.Repositories' {
    Context 'Function: Get-GitHubRepository' {
        Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
            BeforeAll {
                $context = Connect-GitHubAccount @connectParams -PassThru -Silent
                # GitHub-specific setup
            }

            It 'Should return GitHub repository object' {
                # GitHub API test implementation
            }

            AfterAll {
                # Clean up GitHub test resources
            }
        }
    }
}
```

## GitHub Test Data Management
- Store GitHub test data in `tests/Data/` folder
- Use unique identifiers (GUID) for GitHub test resources
- Clean up GitHub test resources in `AfterAll` blocks
- Use dedicated test organizations/repositories when possible
- Handle GitHub API rate limiting in tests

## GitHub-Specific Test Requirements
- All tests should be runnable in CI/CD environments
- Use proper diagnostic suppressions for known Pester/PSScriptAnalyzer issues
- Target 50%+ code coverage as configured in `.github/PSModule.yml`
- Test GitHub Enterprise scenarios where applicable

## GitHub Integration Test Patterns
- Test against actual GitHub API where appropriate
- Mock sensitive operations while testing core logic paths
- Validate GitHub object types and properties returned
- Include GitHub pipeline testing for functions that support it
- Test GitHub error conditions and API rate limiting

## Reference Implementation Files
- See `tests/Repositories.Tests.ps1` for comprehensive GitHub test patterns
- Check `tests/Data/AuthCases.ps1` for GitHub auth scenario patterns
- Follow `tests/TEMPLATE.ps1` for new GitHub test files
- Reference GitHub API documentation for test case validation
