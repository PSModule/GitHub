---
description: "Code-writing guidelines for PowerShell in organization projects"
applyTo: "**/*.ps1, **/*.psd1, **/*.psm1"
---

# PowerShell Instructions

## Style & Formatting

- **Indentation**: 4 spaces (no tabs)
- **Max line length**: No hard limit, but prefer readability (PSScriptAnalyzer checks for excessively long lines)
- **Trailing whitespace**: Disallowed
- **Braces**: One True Brace Style (OTBS)
  - Opening brace on same line as statement
  - Closing brace on its own line
- **PowerShell Keywords**: Always lowercase
  - ✅ `if`, `else`, `return`, `function`, `param`, `foreach`, `while`, `try`, `catch`
  - ❌ `If`, `ELSE`, `Return`, `Function`

**Example:**
````powershell
# BEFORE: incorrect formatting
Function Get-Data {
Return $data
}

# AFTER: correct formatting
function Get-Data {
    if ($condition) {
        return $data
    }
}
````

## Function Structure

All functions must use this structure:

````powershell
filter FunctionName {
    <#
        .SYNOPSIS
        Brief description

        .DESCRIPTION
        Detailed description

        .EXAMPLE
        ```powershell
        FunctionName -Parameter 'value'
        ```

        Description of example
    #>
    [OutputType([ReturnType])]
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Parameter
    )

    begin {
        # Initialization, validation, context resolution
    }

    process {
        # Main logic, handles pipeline
    }

    end {
        # Cleanup if needed
    }
}
````

### Function Declaration Rules

- **Filter vs Function**: Use `filter` for pipeline-enabled functions, `function` only when explicitly needed
- **Always Include**: `begin`, `process`, `end` blocks even if some are empty
- **CmdletBinding**: Always include `[CmdletBinding()]` attribute
- **OutputType**: Always declare `[OutputType([Type])]` with the actual return type

## Parameter Guidelines

### Parameter Declaration

Every parameter must have explicit attributes in **this specific order**:

1. **`[Parameter()]`** - Always present, even if empty
2. **Validation attributes** - `[ValidateNotNullOrEmpty()]`, `[ValidateSet()]`, `[ValidateRange()]`, etc.
3. **`[Alias()]`** - If applicable
4. **Type and parameter name** - `[type] $ParameterName`

This order is enforced by PSScriptAnalyzer and ensures consistency across all functions.

**Example:**
````powershell
param(
    # The account owner
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [Alias('Organization', 'Username')]
    [string] $Owner,

    # Optional parameter with default
    [Parameter()]
    [System.Nullable[int]] $PerPage,

    # Switch parameter
    [Parameter()]
    [switch] $Force
)
````

### Parameter Types

- **Always specify types**: Never use untyped parameters
- **Nullable types**: Use `[System.Nullable[int]]` for optional numeric parameters
- **Arrays**: Specify element type: `[string[]]`, `[int[]]`
- **Objects**: Use `[object]` only when type varies; prefer specific types
- **Switches**: Use `[switch]` type, never `[bool]`

### Parameter Naming Standards

- **PascalCase**: All parameters use PascalCase
- **Convert from API**: Transform snake_case API parameters to PascalCase
  - API: `per_page` → PowerShell: `$PerPage`
  - API: `node_id` → PowerShell: `$NodeID`
  - API: `html_url` → PowerShell: `$Url`

- **Avoid Redundancy**: Don't repeat the object type in parameter names
  - ✅ `Get-GitHubRepository -ID 123` (not `-RepositoryID`)
  - ✅ `Get-GitHubUser -Name 'octocat'` (not `-Username`)

- **Standard Aliases**:
  - `$Owner` should have `[Alias('Organization', 'Username')]`
  - `$ID` can have `[Alias('Id', 'id')]` if needed for compatibility
  - `$Repository` can have `[Alias('Repo')]` for convenience

### Parameter Sets

- **Declare explicitly**: Use `DefaultParameterSetName` only if not the first set
- **Never use**: `DefaultParameterSetName = '__AllParameterSets'`
- **Name clearly**: Use descriptive names like `'Get a repository by name'`

**Example:**
````powershell
[CmdletBinding(DefaultParameterSetName = 'List all repositories')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Get by ID')]
    [int] $ID,

    [Parameter(Mandatory, ParameterSetName = 'Get by name')]
    [string] $Name
)
````

## Patterns (Do / Don't)

### String Validation

````powershell
# BEFORE: verbose string checking
if ([string]::IsNullOrEmpty($Parameter)) {
    throw "Parameter required"
}

# AFTER: use built-in validation
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Parameter
)

# Or simple null check
if (-not $Parameter) {
    throw "Parameter required"
}
````

### Hashtable Cleanup

````powershell
# BEFORE: manual null checking
if ($null -ne $Value1) { $hash.Value1 = $Value1 }
if ($null -ne $Value2) { $hash.Value2 = $Value2 }

# AFTER: use helper function
$hash = @{
    Value1 = $Value1
    Value2 = $Value2
}
$hash | Remove-HashtableEntry -NullOrEmptyValues
````

### Pipeline Support

````powershell
# BEFORE: array collection
function Get-Items {
    $results = @()
    foreach ($item in $collection) {
        $results += Process-Item $item
    }
    return $results
}

# AFTER: streaming output
filter Get-Items {
    process {
        foreach ($item in $collection) {
            Process-Item $item | Write-Output
        }
    }
}
````

## Error Handling

### Try-Catch Blocks

- Wrap all API calls in try-catch
- Include context in error messages
- Use `throw` for fatal errors
- Use `Write-Error` for non-fatal errors

**Example:**
````powershell
try {
    $result = Invoke-GitHubAPI @params
    Write-Output $result.Response
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Error "Repository '$Name' not found in owner '$Owner'"
        return
    }
    throw
}
````

### ShouldProcess

- **Only for destructive operations**: `Set-*`, `Remove-*`, `New-*`, `Update-*`
- **Never for Get operations**: `Get-*` commands never use ShouldProcess
- **Implementation**:

````powershell
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string] $Name
)

process {
    if ($PSCmdlet.ShouldProcess($Name, 'Delete repository')) {
        Invoke-GitHubAPI @params
    }
}
````

## Testing

### Test Framework

- **Framework**: Pester 5.x
- **Test files**: `{Feature}.Tests.ps1` in `tests/` directory
- **Required version**: Declare in `#Requires` statement

**Example:**
````powershell
#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

BeforeAll {
    # Setup code
}

Describe 'Get-GitHubRepository' {
    Context 'When getting by name' {
        It 'Returns the repository' {
            $result = Get-GitHubRepository -Owner 'octocat' -Name 'Hello-World'
            $result.Name | Should -Be 'Hello-World'
        }
    }
}
````

### Assertion Patterns

- Use Pester assertions: `Should -Be`, `Should -Not -BeNullOrEmpty`, etc.
- Test positive and negative cases
- Mock external calls appropriately

### Test Organization

````powershell
Describe 'Feature' {
    $authCases = . "$PSScriptRoot/Data/AuthCases.ps1"

    Context 'As <Type> using <Case>' -ForEach $authCases {
        BeforeAll {
            # Setup per context
        }

        It 'Does something' {
            # Test assertion
        }

        AfterAll {
            # Cleanup per context
        }
    }
}
````

## Build Frameworks

- **Build tool**: Native PowerShell module loading
- **PSModule framework**: Custom build and release automation
- **Manifest**: All configuration in `src/manifest.psd1`

## CI Frameworks

- **GitHub Actions**: Primary CI/CD platform
- **Workflow files**: `.github/workflows/`
- **PSModule.yml**: Organization-wide CI configuration

## Logging & Telemetry

### Logging Levels

- **Write-Debug**: Detailed diagnostic information (use `$DebugPreference`)
  - Parameter values
  - API endpoints being called
  - Context resolution details

- **Write-Verbose**: General progress information
  - High-level operation flow
  - Initialization messages

- **Write-Warning**: Non-fatal issues
  - Deprecated features
  - Fallback behaviors

- **Write-Error**: Errors that don't stop execution
  - Optional operations that failed
  - Validation failures with -ErrorAction Continue

**Example:**
````powershell
begin {
    $stackPath = Get-PSCallStackPath
    Write-Debug "[$stackPath] - Start"
    $Context = Resolve-GitHubContext -Context $Context
    Write-Verbose "Resolved context: $($Context.Type)"
}

process {
    if ($DebugPreference -eq 'Continue') {
        Write-Debug "ParamSet: [$($PSCmdlet.ParameterSetName)]"
        [pscustomobject]$params | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
    }
}
````

### GitHub Actions Integration

For GitHub Actions workflow commands, use module-specific functions:
- `Set-GitHubOutput` - Set workflow outputs
- `Set-GitHubEnvironmentVariable` - Set environment variables
- `Write-GitHubNotice` / `Write-GitHubWarning` / `Write-GitHubError` - Workflow annotations

## Performance

### String Concatenation

````powershell
# BEFORE: O(n²) string concatenation
$result = ""
foreach ($item in $items) {
    $result += "$item`n"
}

# AFTER: efficient string building
$result = $items -join "`n"
# Or for complex scenarios
$result = [System.Text.StringBuilder]::new()
foreach ($item in $items) {
    [void]$result.AppendLine($item)
}
$result.ToString()
````

### Array Building

````powershell
# BEFORE: expensive array growth
$results = @()
foreach ($item in $collection) {
    $results += Process-Item $item
}

# AFTER: use ArrayList or stream
$results = [System.Collections.ArrayList]@()
foreach ($item in $collection) {
    [void]$results.Add((Process-Item $item))
}

# BETTER: stream with pipeline
filter Process-Collection {
    process {
        foreach ($item in $collection) {
            Process-Item $item
        }
    }
}
````

### Unnecessary Variable Creation

````powershell
# BEFORE: unnecessary intermediate variables
$apiResult = Invoke-GitHubAPI @params
$response = $apiResult.Response
Write-Output $response

# AFTER: direct pipeline
Invoke-GitHubAPI @params | Select-Object -ExpandProperty Response
````

### Pipeline Output Pattern

When extracting properties from API responses, choose between two patterns based on context:

**Pattern 1: ForEach-Object with explicit output** (preferred for complex transformations)
````powershell
Invoke-GitHubAPI @params | ForEach-Object {
    Write-Output $_.Response
}
````

**Pattern 2: Select-Object -ExpandProperty** (preferred for simple property extraction)
````powershell
Invoke-GitHubAPI @params | Select-Object -ExpandProperty Response
````

**When to use each:**
- Use **ForEach-Object** when you need to:
  - Transform or process each item
  - Add additional logic or filtering
  - Make explicit what's being output for debugging
  - Ensure proper streaming behavior

- Use **Select-Object -ExpandProperty** when you need to:
  - Simply extract a property with no transformation
  - Keep the pipeline concise
  - Extract from a single object (not a collection)

## Dependencies

### Module Requirements

- Declare all dependencies in `src/header.ps1`:
  ````powershell
  #Requires -Modules @{ ModuleName = 'ModuleName'; RequiredVersion = 'x.y.z' }
  ````

- Use specific versions, not minimum versions
- Keep dependencies minimal

### Package Sources

- **PowerShell Gallery**: Primary source for modules
- **Install command**: `Install-PSResource -Name ModuleName -Repository PSGallery -TrustRepository`

## Documentation

### Comment-Based Help

Required sections for all public functions:

````powershell
<#
    .SYNOPSIS
    One-line description.

    .DESCRIPTION
    Detailed description of functionality.

    .EXAMPLE
    ```powershell
    Function-Name -Parameter 'value'
    ```

    Description of what this example demonstrates.

    .PARAMETER Parameter
    Description of the parameter.

    .INPUTS
    GitHubOwner

    .OUTPUTS
    GitHubRepository

    .LINK
    https://psmodule.io/ModuleName/Functions/Function-Name/

    .NOTES
    Link to official API documentation if applicable.
#>
````

### Documentation Conventions

#### Examples with Triple Backticks

**CRITICAL**: When writing `.EXAMPLE` sections in PSModule organization projects, **always use triple backticks** (` ``` `) around code blocks:

````powershell
.EXAMPLE
```powershell
Get-GitHubRepository -Owner 'octocat' -Name 'Hello-World'
```

Gets the Hello-World repository from the octocat account.
````

**Why**: The PSModule framework automatically removes default PowerShell help fences during documentation generation. Without explicit triple backticks, code examples will not render correctly in generated documentation.

❌ **WRONG** (will not render properly):
```powershell
.EXAMPLE
Get-GitHubRepository -Owner 'octocat'

Gets a repository.
```

✅ **RIGHT** (renders correctly):
````powershell
.EXAMPLE
```powershell
Get-GitHubRepository -Owner 'octocat'
```

Gets a repository.
````

#### Inline Parameter Documentation

Use inline comments with `///` for parameter descriptions, **not** separate `.PARAMETER` comment blocks:

**Example:**
````powershell
param(
    /// The account owner of the repository (organization or user)
    [Parameter(Mandatory)]
    [string] $Owner,

    /// The name of the repository
    [Parameter(Mandatory)]
    [string] $Name
)
````

This pattern keeps parameter documentation colocated with the parameter definition for better maintainability.

#### .NOTES Section

The `.NOTES` section should include a link to the official API documentation:

````powershell
.NOTES
[List repositories for a user](https://docs.github.com/rest/repos/repos#list-repositories-for-a-user)
````

#### .LINK Section

The `.LINK` section should list local documentation first, then official API documentation:

````powershell
.LINK
https://psmodule.io/GitHub/Functions/Get-GitHubRepository/

.NOTES
[Get a repository](https://docs.github.com/rest/repos/repos#get-a-repository)
````

### Inline Documentation

- Use `#` for single-line explanatory comments
- Document required permissions in `begin` block:
  ````powershell
  begin {
      # Requires: repo scope for private repositories
  }
  ````

## Snippets

### Public Function Boilerplate

````powershell
filter Verb-ModuleNoun {
    <#
        .SYNOPSIS
        Brief description

        .DESCRIPTION
        Detailed description

        .EXAMPLE
        ```powershell
        Verb-ModuleNoun -Parameter 'value'
        ```

        Example description
    #>
    [OutputType([ReturnType])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Parameter,

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
        try {
            $params = @{
                Context = $Context
                Parameter = $Parameter
            }
            $params | Remove-HashtableEntry -NullOrEmptyValues

            Invoke-PrivateFunction @params
        } catch {
            throw
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
````

### Private Function Boilerplate

````powershell
function Verb-ModulePrivateNoun {
    [OutputType([ReturnType])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [GitHubContext] $Context,

        [Parameter(Mandatory)]
        [string] $Parameter
    )

    $stackPath = Get-PSCallStackPath
    Write-Debug "[$stackPath] - Start"

    try {
        $inputObject = @{
            Context     = $Context
            Method      = 'Get'
            APIEndpoint = "/endpoint"
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    } catch {
        throw
    }
}
````

### Test Boilerplate

````powershell
#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

BeforeAll {
    # Setup
}

Describe 'Feature' {
    Context 'When condition' {
        BeforeAll {
            # Context setup
        }

        It 'Should do something' {
            # Arrange
            $expected = 'value'

            # Act
            $result = Do-Something

            # Assert
            $result | Should -Be $expected
        }

        AfterAll {
            # Context cleanup
        }
    }
}
````

### API Call Pattern

When building the splat for `Invoke-GitHubAPI`, parameters must be in this specific order:

1. **Method** - The HTTP method (PascalCase: `'Get'`, `'Post'`, `'Put'`, `'Delete'` - not `'GET'`, `'POST'`, etc.)
2. **APIEndpoint** - The API endpoint path
3. **Body** - The request body (if applicable)
4. **Context** - The GitHub context object

**Example:**
````powershell
try {
    $inputObject = @{
        Context     = $Context
        Method      = 'Post'
        APIEndpoint = "/repos/$Owner/$Repository/issues"
        Body        = @{
            title = $Title
            body  = $Body
        }
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 404) {
        Write-Error "Resource not found: $Owner/$Repository"
        return
    }
    throw
}
````

**Critical**: Method values must use PascalCase (`Post`, `Delete`, `Put`, `Get`), not uppercase (`POST`, `DELETE`, `PUT`, `GET`).

## Forbidden

### Anti-Patterns

- ❌ **Untyped parameters**: Always specify parameter types
  ```powershell
  # WRONG
  param($Parameter)

  # RIGHT
  param([string] $Parameter)
  ```

- ❌ **Uppercase PowerShell keywords**: All keywords must be lowercase
  ```powershell
  # WRONG
  Function Get-Data { Return $data }

  # RIGHT
  function Get-Data { return $data }
  ```

- ❌ **Missing [Parameter()] attribute**: All parameters must have it
  ```powershell
  # WRONG
  param([string] $Name)

  # RIGHT
  param(
      [Parameter()]
      [string] $Name
  )
  ```

- ❌ **ShouldProcess on Get commands**: Never use with Get-* functions
  ```powershell
  # WRONG
  function Get-GitHubRepository {
      [CmdletBinding(SupportsShouldProcess)]
      param(...)
  }

  # RIGHT
  function Get-GitHubRepository {
      [CmdletBinding()]
      param(...)
  }
  ```

- ❌ **String redundant checks**: Use validation attributes or simple null checks
  ```powershell
  # WRONG
  if ([string]::IsNullOrEmpty($Param)) { }

  # RIGHT
  if (-not $Param) { }
  # OR with validation
  [ValidateNotNullOrEmpty()]
  [string] $Param
  ```

- ❌ **Write-Host**: Use Write-Output, Write-Verbose, or Write-Debug instead
  - Exception: GitHub Actions workflow commands via module functions

- ❌ **DefaultParameterSetName = '__AllParameterSets'**: Never use this
