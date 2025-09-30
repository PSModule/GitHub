---
applyTo:
    - '**/*.ps1'
    - '**/*.psm1'
    - '**/*.psd1'
description: Repository-specific PowerShell conventions for the PSModule GitHub module reference implementation.
---

# PSModule PowerShell Conventions (GitHub Module)

This repository is the canonical GitHub module used to demonstrate PSModule patterns; any PowerShell changes here must represent best practices.

## Goal
- Preserve the object-oriented, context-aware architecture that groups functionality by GitHub entity.
- Ensure authentication, logging, and pipeline support remain consistent for both local development and GitHub Actions execution.

## Execution Steps
1. Identify whether your change touches public functions, private helpers, classes, or formatting assets and open the matching repo/framework instruction files.
2. Place code in the correct directory:
     - `src/functions/public/<ObjectType>/` for exported cmdlets.
     - `src/functions/private/<ObjectType>/` for helpers.
     - `src/classes/public/` for GitHub object models.
     - `src/formats/` or `src/types/` for view/type extensions.
3. Follow the function/class templates below, wiring context resolution, authentication, and logging appropriately.
4. Update accompanying tests, documentation, and formatting/type files when interfaces change.
5. Validate with `Import-Module ./src/GitHub.psm1 -Force`, `Invoke-Pester`, and relevant sample workflows before committing.

## Behavior Rules
- **Architecture & Organization**
    - Group functions by GitHub entity (Repository, Issue, User, etc.) rather than API operation.
    - Map each public function to a single API endpoint, using classes to mirror response objects.
- **Function Template**

```powershell
function Verb-GitHubNoun {
        <#
                .SYNOPSIS
                Brief description following GitHub API terminology.

                .DESCRIPTION
                Comprehensive description with GitHub API context.

                .EXAMPLE
                Verb-GitHubNoun -Owner PSModule -Repository GitHub

                .NOTES
                Link to GitHub REST/GraphQL docs and related functions.
        #>
        [OutputType([GitHubObjectType])]
        [CmdletBinding()]
        param(
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$Owner,

                [Parameter()]
                [string]$Repository = (Get-GitHubContext).Repository
        )

        begin {
                $stackPath = Get-PSCallStackPath
                Write-Debug "[$stackPath] - Start"
                Resolve-GitHubContext -Context ([ref]$Context)
                Assert-GitHubContext -Context $Context -RequiredContext Owner, Repository
        }

        process {
                try {
                        $result = Invoke-GitHubAPI -Context $Context -ApiEndpoint $apiEndpoint
                        return $result
                } catch {
                        Write-Debug "Error: $_"
                        throw
                }
        }

        end {
                Write-Debug "[$stackPath] - End"
        }
}
```
- **Context & Authentication**
    - All public functions call `Resolve-GitHubContext` and `Assert-GitHubContext`; private functions accept a `[GitHubContext]` parameter.
    - Support PAT, OAuth UAT, GitHub App JWT, and installation tokens; integrate with Azure Key Vault where appropriate.
- **Pipeline & Output**
    - Provide pipeline input, implement `begin/process/end`, and support `-PassThru` for mutating operations.
    - Return strongly typed objects (classes) and avoid formatted strings.
- **Logging & GitHub Actions Integration**
    - Detect GitHub Actions via environment variables, use `Set-GitHubLogGroup`/`LogGroup` for structured output, and honor secrets hygiene.
- **Error Handling**
    - Use validation attributes, raise actionable errors with documentation links, and handle rate limiting gracefully.
- **Enterprise Support**
    - Respect custom API URLs for GHES/GHEC, surface enterprise-specific parameters/examples, and ensure compatibility.

## Output Format
- Modules must load without warnings, export expected cmdlets, and expose updated comment-based help.
- Changes to classes or public functions require synchronized formatter/type updates and documentation refreshes.

## Error Handling
- Treat failing imports, analyzer violations, missing help, or context assertions as blocking; resolve before merge.
- Document known deviations (legacy behavior, upstream bugs) with TODO comments tied to issues.

## Definitions
| Term | Description |
| --- | --- |
| **GitHubContext** | Internal object capturing owner, repository, enterprise, and auth details for API calls. |
| **Invoke-GitHubAPI** | Core helper that executes REST/GraphQL requests using the resolved context and handles retry/telemetry logic. |
| **PSModule helpers** | Shared scripts/modules (e.g., Install-PSModuleHelpers) that bootstrap authentication, logging, and formatting. |
---
applyTo: '**/*.ps1'
applyTo: '**/*.psm1'
applyTo: '**/*.psd1'
description: Repository-specific PowerShell conventions for PSModule ecosystem.
---

# PSModule PowerShell Conventions

## GitHub Module Architecture Patterns
This repository follows the **GitHub PowerShell module** architecture, which serves as the reference implementation for PSModule ecosystem patterns.

### Module Structure
- `src/functions/public/` - User-facing cmdlets organized by GitHub object type (Repositories, Issues, Users, etc.)
- `src/functions/private/` - Internal helper functions following same organizational pattern
- `src/classes/public/` - PowerShell classes for GitHub objects (`GitHubRepository`, `GitHubUser`, etc.)
- `src/formats/` - Custom formatting views for display output
- `src/types/` - Type extensions and aliases for enhanced PowerShell experience

### Core Design Patterns
- **Object-oriented organization**: Functions grouped by GitHub entity type, not API endpoints
- **Context-aware**: Automatically detects GitHub Actions environment and loads context
- **Pipeline-friendly**: All public functions support pipeline input where appropriate
- **Authentication abstraction**: Single connection model supporting multiple auth types

### Function Organization Rules
- **Object-oriented grouping**: Functions grouped by GitHub entity type, not by API endpoints
- **One API endpoint per function**: Each function maps to exactly one GitHub API endpoint
- **Hierarchical folders**: `public/ObjectType/` and `private/ObjectType/` structure
- **Class mirroring**: Classes mirror the object hierarchy from GitHub API responses
- Group by GitHub object type (Repository, Issue, etc.), not by API operation
- Public functions in `public/ObjectType/`, private in `private/ObjectType/`

## Function Naming and Structure
```powershell
function Verb-GitHubNoun {
    <#
        .SYNOPSIS
        Brief description following GitHub API terminology.

        .DESCRIPTION
        Comprehensive description with GitHub API context and usage scenarios.

        .EXAMPLE
        Verb-GitHubNoun -Owner PSModule -Repository GitHub

        Description referencing actual GitHub objects and realistic scenarios.

        .NOTES
        References to GitHub API documentation and related functions.
    #>
    [OutputType([GitHubObjectType])]
    [CmdletBinding()]
    [Alias('Alias-Pattern')]
    param(
        # GitHub-specific parameter with validation
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Owner,

        # Parameter from resolved context when possible
        [Parameter()]
        [string] $Repository = (Get-GitHubContext).Repository
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"

        # Context resolution and validation
        Resolve-GitHubContext -Context ([ref] $Context)
        Assert-GitHubContext -Context $Context -RequiredContext Owner, Repository
    }

    process {
        try {
            Write-Debug "Enterprise : [$($Context.Enterprise)]"
            Write-Debug "Owner : [$($Context.Owner)]"
            Write-Debug "Repo : [$($Context.Repository)]"

            # API call with proper error handling
            $result = Invoke-GitHubAPI -Context $Context -ApiEndpoint $apiEndpoint

            return $result
        } catch {
            Write-Debug "Error: $_"
            throw
        } finally {
            Write-Debug 'Finally'
        }
    }

