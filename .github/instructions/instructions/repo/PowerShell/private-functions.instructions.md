---
applyTo: "**/functions/private/**/*.ps1"
description: Repository-specific PowerShell private function patterns for GitHub module.
---

# GitHub Module Private Function Guidelines

## Function Declaration Standards
- No `[CmdletBinding(SupportsShouldProcess)]` or aliases
- No pipeline input support - private functions focus on single responsibility
- Expect all parameters to be provided by calling public functions

## Parameter Requirements for GitHub Functions
- `[GitHubContext] $Context` is MANDATORY - always resolved by public caller
- `$Owner`, `$Repository`, `$ID` parameters are MANDATORY when needed by GitHub API
- No parameter defaulting logic - public functions handle context resolution
- Use same parameter naming conventions as public functions

## GitHub Private Function Structure
```powershell
function Verb-GitHubPrivateNoun {
    param(
        [Parameter(Mandatory)]
        [GitHubContext] $Context,

        [Parameter(Mandatory)]
        [string] $Owner,

        [Parameter(Mandatory)]
        [string] $Repository
    )

    begin {
        # No context resolution - already done by public caller
        # Direct GitHub API interaction logic
    }

    process {
        # Main GitHub API implementation
        $apiEndpoint = "repos/$Owner/$Repository"
        # etc.
    }
}
```

## GitHub API Integration
- Direct calls to `Invoke-GitHubAPI` with resolved context
- Handle GitHub API response formatting and error conditions
- Return structured data for public function processing
- Support GitHub Enterprise Server (GHES) and GitHub Enterprise Cloud (GHEC)

## No Aliases Policy
- No function-level aliases to keep internal interfaces simple
- No parameter aliases - use exact parameter names
- Keep internal interfaces consistent across all private functions

## GitHub-Specific Error Handling
- Assume valid context and parameters (validated by public functions)
- Focus on GitHub API-specific error conditions and rate limiting
- Let exceptions bubble up to public function level for user-friendly messages
- Handle different GitHub environments appropriately

## Object Organization
- Follow same object-type organization as public functions
- Group by GitHub entity type (Repository, Issue, User, etc.)
- Match folder structure: `private/ObjectType/` mirrors `public/ObjectType/`

## Reference Implementation Files
- See `src/functions/private/Repositories/` for GitHub repository operation patterns
- Follow object-type organization matching public functions
- Use `src/functions/public/` patterns as reference for consistency
