---
applyTo: "**/*.{ps1,psm1,psd1}"
description: GitHub module PowerShell specific patterns and conventions.
---

# GitHub Module PowerShell Instructions

## Function Structure Pattern
All public functions in this module follow this specific pattern:

### Authentication Context Pattern
```powershell
function Get-GitHubExample {
    [CmdletBinding()]
    param(
        [Parameter()]
        [object] $Context
    )

    begin {
        # Always start public functions with context resolution and validation
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context

        # Include permission requirements comment
        # Requires permissions: repository:read
    }

    process {
        # Implementation with consistent API call pattern
        $splat = @{
            Method      = 'GET'
            APIEndpoint = '/repos/{owner}/{repo}/example'
            Body        = $Body
            Context     = $Context
        }
        Invoke-GitHubAPI @splat | ForEach-Object { Write-Output $_.Response }
    }
}
```

## Parameter Conventions
- Use PascalCase for all parameters
- Always include `[Parameter()]` attribute (even if empty)
- Use `[ValidateNotNullOrEmpty()]` instead of string null checks
- Owner parameters: `[Alias('User','Organization')]`
- Repository parameters: `[Alias('Repo')]` if needed
- Context parameter: `[object] $Context` for all public functions

## Authentication Context
- **Public functions**: Handle context resolution and validation with `Resolve-GitHubContext` and `Assert-GitHubContext`
- **Private functions**: Expect resolved `[GitHubContext] $Context` parameter
- Support all auth types: PAT, UAT, IAT, GitHub App JWT

## API Call Patterns
- Always splat API calls with consistent parameter order: Method, APIEndpoint, Body, Context
- Use PascalCase for HTTP methods: `Get`, `Post`, `Put`, `Delete`, `Patch`
- Handle pipeline output with `ForEach-Object { Write-Output $_.Response }`
- Include permission requirements in function begin block

## Naming Standards
- **Public functions**: `Verb-GitHubNoun` (e.g., `Get-GitHubRepository`) with aliases where appropriate
- **Private functions**: Same pattern but NO aliases
- **Classes**: `GitHubObjectType` (e.g., `GitHubRepository`)
- Object-oriented parameter naming (don't repeat function context in parameter names)

## Error Handling & Validation
- Use `[ValidateNotNullOrEmpty()]` instead of string null checks
- Throw meaningful errors when required parameters missing from context
- Follow PowerShell error handling patterns
- Provide actionable error messages that guide users to solutions
- Include relevant GitHub API documentation links in error messages

## GitHub Actions Integration
- Always consider whether code is running in GitHub Actions environment
- Respect existing authentication context before establishing new connections
- Support environment variable-based configuration
- Handle both local development and CI/CD scenarios

## Reference Implementation
- See `src/functions/public/Auth/Connect-GitHubAccount.ps1` for authentication patterns
- See `src/functions/public/Repositories/` for standard function structure
- Follow patterns documented in `CodingStandard.md`
