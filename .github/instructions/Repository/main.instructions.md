---
description: "Project-specific code-writing guidance for GitHub PowerShell module"
applyTo: "**/*"
---

# GitHub PowerShell Module Instructions

## Repository Purpose

The **GitHub PowerShell** module provides a PowerShell-native interface for managing and automating GitHub environments. It supports:

- **Multiple GitHub environments**: GitHub.com, GitHub Enterprise Cloud (GHEC), and GitHub Enterprise Server (GHES)
- **GitHub Actions integration**: Context-aware execution with automatic workflow integration
- **Multiple authentication methods**: PAT, UAT, IAT, GitHub Apps
- **Pipeline-friendly commands**: Full support for PowerShell pipeline operations

The module is designed as both a local scripting companion and a GitHub Actions workflow companion, understanding its execution context and providing appropriate defaults.

## Architecture Overview

### Module Structure

```
src/
  functions/
    public/          # Exported commands (Verb-GitHubNoun)
      {ObjectType}/  # Grouped by GitHub object type (Repository, User, etc.)
    private/         # Internal API wrappers and helpers
      {ObjectType}/  # Mirror public structure
  classes/
    public/          # GitHubRepository, GitHubUser, GitHubOwner, etc.
  formats/           # Format.ps1xml for custom display
  types/             # Types.ps1xml for type extensions and aliases
  variables/         # Module-scope variables
  loader.ps1         # Module initialization and auto-discovery
  header.ps1         # Module requirements
  manifest.psd1      # Module manifest
  completers.ps1     # Argument completers
```

### Component Relationships

```
┌─────────────────┐
│  Public Funcs   │ (Verb-GitHubNoun)
│  - Pipeline     │ - Calls Resolve-GitHubContext
│  - Context      │ - Parameter validation
│  - Param sets   │ - Routes to private functions
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Private Funcs   │ (Verb-GitHubNoun)
│  - No pipeline  │ - Mandatory Context parameter
│  - API calls    │ - Direct API endpoint mapping
│  - No defaults  │ - Returns API responses
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Invoke-GitHub-  │
│     API         │ - REST API wrapper
│  - Auth handling│ - Error handling
│  - Pagination   │ - Rate limiting
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   GitHub API    │
└─────────────────┘
```

### Data Flow

1. **User calls public function** → `Get-GitHubRepository -Owner 'octocat' -Name 'Hello-World'`
2. **Context resolution** → `Resolve-GitHubContext` ensures Context is `[GitHubContext]` object
3. **Parameter defaulting** → If `$Repository` missing, default from `$Context.Repo`
4. **Parameter set routing** → Switch on `$PSCmdlet.ParameterSetName` to select private function
5. **Private function call** → Pass mandatory parameters including resolved Context
6. **API invocation** → `Invoke-GitHubAPI` with method, endpoint, body
7. **Response processing** → Transform API response to typed objects (e.g., `[GitHubRepository]`)
8. **Output** → Return typed objects to pipeline

## Project-Specific Rules

### Function Organization

- **Group by object type, NOT by API endpoint**
  - ✅ `src/functions/public/Repositories/Get-GitHubRepository.ps1`
  - ❌ `src/functions/public/Repos/Get-GitHubRepository.ps1`

- **Object types as folder names**:
  - `Repositories/` - Repository operations
  - `Users/` - User operations
  - `Organizations/` - Organization operations
  - `Teams/` - Team operations
  - `Releases/` - Release operations
  - `Secrets/`, `Variables/` - GitHub Actions resources
  - `Webhooks/` - Webhook operations
  - `Workflows/` - GitHub Actions workflows
  - `Apps/` - GitHub App operations
  - `Artifacts/` - GitHub Actions artifacts
  - `Environments/` - GitHub Environments

### API Coverage Philosophy

- **We do NOT need 100% GitHub API coverage**
- Maintain exclusion list for endpoints intentionally not covered
- Focus on commonly used operations
- Mark non-implemented endpoints as ⚠️ in coverage reports
- Examples of deliberately excluded endpoints:
  - Hovercards API
  - Legacy endpoints
  - Rarely-used administrative operations

### Context System

The module uses a `GitHubContext` system to manage authentication and connection state:

#### Context Resolution

Every public function must:
1. Accept a `$Context` parameter of type `[object]` (allows string or GitHubContext)
2. Call `Resolve-GitHubContext -Context $Context` in `begin` block
3. Call `Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT` to validate auth

**Example:**
```powershell
param(
    [Parameter()]
    [object] $Context
)

begin {
    $Context = Resolve-GitHubContext -Context $Context
    Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
}
```

#### Context Properties

The resolved `[GitHubContext]` object provides:
- `$Context.Owner` - Current owner (user or organization)
- `$Context.Repo` - Current repository
- `$Context.Type` - Authentication type (PAT, UAT, IAT, APP)
- Additional context from GitHub Actions environment

#### Parameter Defaulting from Context

Public functions should default missing parameters from context:

```powershell
process {
    if (-not $Repository) {
        $Repository = $Context.Repo
    }
    if (-not $Repository) {
        throw "Repository not specified and not found in the context."
    }

    if (-not $Owner) {
        $Owner = $Context.Owner
    }
}
```

**Private functions must NOT do this** - they receive already-resolved parameters.

### Public vs Private Function Contract

#### Public Functions

- **Purpose**: User-facing API with convenience features
- **Pipeline**: Support `ValueFromPipelineByPropertyName`
- **Context**: Accept `[object] $Context`, resolve to `[GitHubContext]`
- **Parameter defaulting**: Default from context if not provided
- **Multiple parameter sets**: Route to appropriate private functions
- **Aliases**: Support common aliases on functions and parameters
- **Error handling**: User-friendly error messages

**Structure:**
```powershell
filter Get-GitHubSomething {
    [OutputType([GitHubSomething])]
    [CmdletBinding(DefaultParameterSetName = 'List all')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Get by ID')]
        [int] $ID,

        [Parameter(Mandatory, ParameterSetName = 'Get by name')]
        [string] $Name,

        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $params = @{
            Context = $Context
            ID      = $ID
            Name    = $Name
        }
        $params | Remove-HashtableEntry -NullOrEmptyValues

        switch ($PSCmdlet.ParameterSetName) {
            'Get by ID' {
                Get-GitHubSomethingByID @params
            }
            'Get by name' {
                Get-GitHubSomethingByName @params
            }
            'List all' {
                Get-GitHubSomethingList @params
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
```

#### Private Functions

- **Purpose**: Direct API endpoint wrappers
- **Pipeline**: NO pipeline support
- **Context**: Mandatory `[GitHubContext] $Context` parameter
- **Parameters**: All required parameters are mandatory
- **No defaulting**: Caller must provide all values
- **No aliases**: No function or parameter aliases
- **One API call = One function**: Each endpoint gets its own function

**Structure:**
```powershell
function Get-GitHubSomethingByID {
    [OutputType([GitHubSomething])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [GitHubContext] $Context,

        [Parameter(Mandatory)]
        [int] $ID
    )

    $stackPath = Get-PSCallStackPath
    Write-Debug "[$stackPath] - Start"

    $inputObject = @{
        Context     = $Context
        Method      = 'Get'
        APIEndpoint = "/something/$ID"
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
```

### Parameter Naming Conventions

#### Object-Oriented Naming

Function name implies the object type, so don't repeat it in parameters:

- ✅ `Get-GitHubRepository -ID 123` (not `-RepositoryID`)
- ✅ `Get-GitHubUser -Name 'octocat'` (not `-Username`)
- ✅ `Remove-GitHubTeam -Team 'developers'` (not `-TeamName`)

#### Standard Aliases

Consistently apply these aliases across all functions:

- `$Owner` → `[Alias('Organization', 'Username')]` (never use `[Alias('org')]`)
- `$Username` → `[Alias('Login')]` where applicable
- `$Repository` → `[Alias('Repo')]` for convenience
- `$ID` → `[Alias('Id', 'id')]` if needed for compatibility

#### API Parameter Conversion

Transform GitHub API snake_case to PowerShell PascalCase:

- `per_page` → `$PerPage`
- `node_id` → `$NodeID`
- `html_url` → `$Url`
- `created_at` → `$CreatedAt`
- `allow_forking` → `$AllowForking`

### API Call Pattern

All API calls follow this standard pattern:

```powershell
try {
    $inputObject = @{
        Context     = $Context
        Method      = 'Post'  # Use PascalCase: Get, Post, Put, Patch, Delete
        APIEndpoint = "/repos/$Owner/$Repository/issues"
        Body        = @{
            title = $Title
            body  = $Body
            labels = $Labels
        }
    }

    # Remove null values from body
    $inputObject.Body | Remove-HashtableEntry -NullOrEmptyValues

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Error "Repository '$Repository' not found for owner '$Owner'"
        return
    }
    throw
}
```

**Splat order (consistent across module):**
1. `Context`
2. `Method`
3. `APIEndpoint`
4. `Body` (for POST, PUT, PATCH)

### Class Design

#### Base Classes

- **GitHubNode**: Base class for objects with both `id` (database ID) and `node_id` (GraphQL ID)
  - Properties: `ID` (database ID), `NodeID` (GraphQL node ID)
  - All GitHub resources with these IDs should extend GitHubNode

#### Scope Properties

Objects that belong within a scope include properties for that scope:

- `Enterprise` - For enterprise-scoped resources
- `Owner`/`Organization`/`Account` - For owner-scoped resources
- `Repository` - For repository-scoped resources
- `Environment` - For environment-scoped resources

**Example:**
```powershell
class GitHubSecret : GitHubNode {
    [string] $Name
    [GitHubOwner] $Owner
    [GitHubRepository] $Repository
    [datetime] $CreatedAt
    [datetime] $UpdatedAt
}
```

#### Convenience Properties

Classes should have a convenience property matching the class name:

- `GitHubRepository` has `Repository` property (alias to `Name` via types file)
- `GitHubUser` has `User` property (alias to `Login` via types file)
- `GitHubTeam` has `Team` property (alias to `Slug` via types file)

This is done via types files (`src/types/*.Types.ps1xml`):

```xml
<Type>
    <Name>GitHubRepository</Name>
    <Members>
        <AliasProperty>
            <Name>Repository</Name>
            <ReferencedMemberName>Name</ReferencedMemberName>
        </AliasProperty>
    </Members>
</Type>
```

#### Property Standardization

- **ID Properties**:
  - `ID` - Primary resource ID (database ID)
  - `NodeID` - GraphQL node ID
  - Never use `RepositoryID`, `UserID` in class names - just `ID`

- **Size Properties**:
  - All disk size properties → `Size` in bytes
  - Convert from KB/MB if needed
  - Type: `[System.Nullable[uint64]]`

- **URL Properties**:
  - `Url` - Primary web URL (not `HtmlUrl`)
  - `ApiUrl` - API endpoint URL if different
  - Specific URLs: `Homepage`, `DocumentationUrl`, etc.

- **Date Properties**:
  - Use `[System.Nullable[datetime]]` type
  - Common names: `CreatedAt`, `UpdatedAt`, `PushedAt`, `ArchivedAt`

#### Example Class Structure

```powershell
class GitHubRepository : GitHubNode {
    # Primary identifiers
    [string] $Name
    [GitHubOwner] $Owner
    [string] $FullName  # Owner/Name format

    # URLs
    [string] $Url

    # Metadata
    [string] $Description
    [System.Nullable[datetime]] $CreatedAt
    [System.Nullable[datetime]] $UpdatedAt
    [System.Nullable[uint64]] $Size

    # Features
    [System.Nullable[bool]] $HasIssues
    [System.Nullable[bool]] $IsPrivate
    [System.Nullable[bool]] $IsArchived

    # Relationships
    [GitHubLicense] $License
    [string[]] $Topics
}
```

### Testing Patterns

#### Test Organization

Tests use authentication case matrix for comprehensive coverage:

```powershell
Describe 'Feature' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case> on <Target>' -ForEach $authCases {
        BeforeAll {
            $context = Connect-GitHubAccount @connectParams -PassThru -Silent
            LogGroup 'Context' {
                Write-Host ($context | Format-List | Out-String)
            }
        }

        AfterAll {
            Get-GitHubContext -ListAvailable | Disconnect-GitHubAccount -Silent
            Write-Host ('-' * 60)
        }

        It 'Should perform operation' {
            # Test implementation
        }
    }
}
```

#### GitHub Actions Integration

Tests are designed to run both locally and in GitHub Actions:

- Use `LogGroup` helper for collapsible GitHub Actions output
- Check authentication type for conditional tests
- Skip tests not applicable to certain auth types

### GitHub Actions Integration

#### Context Awareness

When running in GitHub Actions, the module automatically:

1. Imports `GITHUB_EVENT_PATH` data
2. Sets environment variables for common values
3. Detects repository, owner, workflow context
4. Provides defaults from the triggering event

**Automatic setup in loader.ps1:**
```powershell
if ($script:IsGitHubActions) {
    Write-Verbose 'Detected running on a GitHub Actions runner, preparing environment...'
    $env:GITHUB_REPOSITORY_NAME = $env:GITHUB_REPOSITORY -replace '.+/'
    Set-GitHubEnvironmentVariable -Name 'GITHUB_REPOSITORY_NAME' -Value $env:GITHUB_REPOSITORY_NAME
    $env:GITHUB_HOST_NAME = ($env:GITHUB_SERVER_URL ?? 'github.com') -replace '^https?://'
    Set-GitHubEnvironmentVariable -Name 'GITHUB_HOST_NAME' -Value $env:GITHUB_HOST_NAME
    Import-GitHubEventData
    Import-GitHubRunnerData
}
```

#### Workflow Commands

Use module-specific functions for workflow commands:

- `Set-GitHubOutput -Name 'result' -Value 'success'`
- `Set-GitHubEnvironmentVariable -Name 'VAR' -Value 'value'`
- `Write-GitHubNotice 'Information message'`
- `Write-GitHubWarning 'Warning message'`
- `Write-GitHubError 'Error message'`

These use the correct workflow command syntax internally.

### Formatting and Type Extensions

#### Format Files (`.Format.ps1xml`)

Define custom table and list views for display:

```xml
<!-- src/formats/GitHubRepository.Format.ps1xml -->
<Configuration>
    <ViewDefinitions>
        <View>
            <Name>GitHubRepository</Name>
            <ViewSelectedBy>
                <TypeName>GitHubRepository</TypeName>
            </ViewSelectedBy>
            <TableControl>
                <TableHeaders>
                    <TableColumnHeader><Label>Name</Label></TableColumnHeader>
                    <TableColumnHeader><Label>Owner</Label></TableColumnHeader>
                    <TableColumnHeader><Label>Private</Label></TableColumnHeader>
                </TableHeaders>
                <TableRowEntries>
                    <TableRowEntry>
                        <TableColumnItems>
                            <TableColumnItem><PropertyName>Name</PropertyName></TableColumnItem>
                            <TableColumnItem><PropertyName>Owner</PropertyName></TableColumnItem>
                            <TableColumnItem><PropertyName>IsPrivate</PropertyName></TableColumnItem>
                        </TableColumnItems>
                    </TableRowEntry>
                </TableRowEntries>
            </TableControl>
        </View>
    </ViewDefinitions>
</Configuration>
```

#### Type Files (`.Types.ps1xml`)

Define property aliases and computed properties:

```xml
<!-- src/types/GitHubRepository.Types.ps1xml -->
<Types>
    <Type>
        <Name>GitHubRepository</Name>
        <Members>
            <AliasProperty>
                <Name>Repository</Name>
                <ReferencedMemberName>Name</ReferencedMemberName>
            </AliasProperty>
        </Members>
    </Type>
</Types>
```

## Development Workflows

### Adding a New Function

1. Determine object type (Repository, User, Team, etc.)
2. Create public function in `src/functions/public/{ObjectType}/`
3. Create corresponding private function(s) in `src/functions/private/{ObjectType}/`
4. Add class definition if new object type in `src/classes/public/{ObjectType}/`
5. Add format file in `src/formats/` for display
6. Add type file in `src/types/` for convenience properties
7. Add tests in `tests/{Feature}.Tests.ps1`
8. Add examples in `examples/{Feature}/`

### Function Checklist

- [ ] Public function uses `filter` with `begin`, `process`, `end`
- [ ] All parameters have `[Parameter()]` attribute
- [ ] Context parameter is `[object]` type, resolved in `begin`
- [ ] Parameters default from context where appropriate
- [ ] Switch on parameter set name to route to private functions
- [ ] Private function has mandatory `[GitHubContext] $Context` parameter
- [ ] API call uses standard splat pattern
- [ ] Error handling with try-catch
- [ ] Comment-based help with examples
- [ ] Test coverage with auth case matrix
- [ ] No `ShouldProcess` on `Get-` commands
- [ ] Aliases applied consistently

### Versioned Resources

For resources with versions (like workflow files), follow this pattern:

- **Default behavior**: Get latest version
- **Optional parameters**:
  - `-Name` - Get specific version by name
  - `-AllVersions` - Get all versions

Example: `Get-GitHubWorkflow` gets the latest, `Get-GitHubWorkflow -AllVersions` lists all.

## Key Differences from Organization Standards

### Module-Specific Overrides

1. **Filter over Function**: This module prefers `filter` for public functions (organization default is `function`)
2. **Context System**: Unique authentication and context management system
3. **Object Type Grouping**: Strict enforcement of grouping by object type vs endpoint
4. **Two-Tier Function Model**: Public/private split with different contracts
5. **GitHub Actions Integration**: Built-in workflow command support

### Additional Module Patterns

- `Get-PSCallStackPath` - Standard debug tracing
- `Remove-HashtableEntry -NullOrEmptyValues` - Clean up splatted parameters
- `LogGroup` helper for GitHub Actions output grouping
- API coverage tracking with exclusion list

## API Coverage Philosophy

### Intentional Exclusions

- **We do NOT need 100% coverage of the GitHub API**
- Maintain a separate file listing endpoints you intentionally do not cover
- Coverage reports can mark excluded endpoints with ⚠️
- Examples of commonly excluded endpoints: hovercards, rarely used features

### Function Design Rules

1. **One API Call = One Function**: If a single function handles multiple distinct API calls, split it into multiple functions
2. **DefaultParameterSetName Prohibition**: Do NOT declare `DefaultParameterSetName = '__AllParameterSets'` - only specify if it's actually different from the first parameter set
3. **Permissions Comment Required**: In the `begin` block, add a comment stating which permissions are required for the API call

Example:
```powershell
begin {
    # Requires: repo, read:org permissions
    $Context = Resolve-GitHubContext -Context $Context
    Assert-GitHubContext -Context $Context -AuthType PAT, UAT
}
```

## Versioned Resource Pattern

Functions that get versioned objects return the **latest version** by default:

- **Default behavior**: Get latest version
- **`-Name` parameter**: Get specific version by name
- **`-AllVersions` switch**: Get all versions

Example:
```powershell
Get-GitHubWorkflow              # Gets latest
Get-GitHubWorkflow -AllVersions # Gets all versions
```

## Class Design Rules

### ID vs NodeID Distinction

- **`ID` property**: The main resource identifier (GitHub's databaseID)
- **`NodeID` property**: GitHub's GraphQL node_id
- All classes using both should extend `GitHubNode` base class

### Class Property Standards

1. **Scope Properties**: Objects belonging inside another scope include scope properties:
   - `Enterprise` - For enterprise-scoped resources
   - `Owner` / `Organization` / `Account` - For organization-scoped resources
   - `Repository` - For repository-scoped resources
   - `Environment` - For environment-scoped resources

2. **Convenience Property Pattern**: Classes have their class name as a property aliased to the typical command value
   - Example: `GitHubRepository` class has `Repository` property (aliased via types file) with value from `Name` property
   - This enables: `$repo.Repository` to get the name used in commands

3. **Interface Consistency**: Remove properties that are purely "API wrapper" fields (e.g., raw HTTP artifacts not relevant to users)

4. **Size Properties**: All properties referencing size on disk should:
   - Be converted to bytes
   - Be named `Size`
   - Use type `[System.Nullable[uint64]]`

Example class structure:
```powershell
class GitHubRepository : GitHubNode {
    [string] $Name                          # Source for Repository alias
    [GitHubOwner] $Owner                    # Scope property
    [System.Nullable[uint64]] $Size         # Size in bytes
    [System.Nullable[datetime]] $CreatedAt
    [System.Nullable[datetime]] $UpdatedAt
    [string[]] $Topics
    [GitHubLicense] $License
}
```

Corresponding types file entry:
```xml
<Type>
    <Name>GitHubRepository</Name>
    <Members>
        <AliasProperty>
            <Name>Repository</Name>
            <ReferencedMemberName>Name</ReferencedMemberName>
        </AliasProperty>
    </Members>
</Type>
```

## Common Pitfalls to Avoid

1. ❌ **Don't group by API endpoint** - Use object type folders
2. ❌ **Don't use `[Alias('org')]` on $Organization** - Use `Owner` parameter with `[Alias('Organization', 'User')]` instead
3. ❌ **Don't put defaulting logic in private functions** - Only in public functions
4. ❌ **Don't forget context resolution** - Every public function needs it
5. ❌ **Don't repeat object type in parameter names** - Function name implies it (use `Get-GitHubRepository -ID` not `-RepositoryID`)
6. ❌ **Don't use Write-Host** - Use Write-Output/Debug/Verbose (except workflow commands)
7. ❌ **Don't add ShouldProcess to Get commands** - Only for destructive operations
8. ❌ **Don't use pipeline in private functions** - Public functions only
9. ❌ **Don't forget to remove null values from body** - Use `Remove-HashtableEntry`
10. ❌ **Don't use string redundant checks** - Use `-not $Param` or validation attributes
11. ❌ **Don't create multiple API calls in one function** - Split into separate functions
12. ❌ **Don't use `DefaultParameterSetName = '__AllParameterSets'`** - Only use if actually different from first set
13. ❌ **Don't forget permissions comment in begin block** - Document required permissions
