# GitHub Copilot Instructions for Process-PSModule

This repository provides a comprehensive GitHub Actions workflow system for PowerShell module development, testing, building, and publishing. When contributing to this project or using it as a reference, please follow these guidelines and patterns.

## Repository Overview

**Process-PSModule** is a reusable workflow that:
- Builds, tests, and publishes PowerShell modules using the PSModule framework
- Provides multi-OS testing (Linux, macOS, Windows)
- Generates documentation and publishes to GitHub Pages
- Publishes modules to PowerShell Gallery
- Follows Test-Driven Development and Continuous Delivery practices

## PowerShell Development Standards

### Code Structure
- **Public Functions**: Place in `src/functions/public/`
- **Private Functions**: Place in `src/functions/private/`
- **Classes**: Place in `src/classes/public/` or `src/classes/private/`
- **Data Files**: Place in `src/data/` (`.psd1` files)
- **Module Manifest**: `src/manifest.psd1`

### Function Standards
```powershell
function Verb-Noun {
    <#
        .SYNOPSIS
        Brief description of what the function does.

        .DESCRIPTION
        Detailed description of the function's purpose and behavior.

        .PARAMETER ParameterName
        Description of the parameter.

        .EXAMPLE
        Verb-Noun -ParameterName 'Value'

        Description of what this example does.

        .NOTES
        Additional notes about the function.

        .LINK
        https://github.com/PSModule/Process-PSModule
    #>
    [CmdletBinding()]
    param (
        # Parameter description
        [Parameter(Mandatory)]
        [string] $ParameterName
    )

    begin {
        # Initialization code
    }

    process {
        # Main function logic
    }

    end {
        # Cleanup code
    }
}
```

### Code Style Requirements

Based on PSScriptAnalyzer configuration:

#### Indentation and Spacing
- Use **4 spaces** for indentation (no tabs)
- Maximum line length: **150 characters**
- Place opening braces on the same line
- Place closing braces on new line
- Use consistent whitespace around operators and separators

#### Bracing Style
```powershell
# Correct
if ($condition) {
    Write-Output "Good"
}

# Incorrect
if ($condition)
{
    Write-Output "Bad"
}
```

#### Variable and Parameter Naming
- Use PascalCase for parameters: `$ModuleName`
- Use camelCase for local variables: `$tempPath`
- Use meaningful, descriptive names

#### Error Handling
```powershell
try {
    # Main logic
}
catch {
    Write-Error "Detailed error message: $($_.Exception.Message)"
    throw
}
```

## Testing Patterns

### Pester Test Structure
```powershell
Describe 'Function-Name' {
    Context 'When condition is met' {
        It 'Should perform expected action' {
            # Arrange
            $input = 'test value'

            # Act
            $result = Function-Name -Parameter $input

            # Assert
            $result | Should -Be 'expected value'
        }
    }

    Context 'When validation fails' {
        It 'Should throw meaningful error' {
            { Function-Name -Parameter $null } | Should -Throw
        }
    }
}
```

### Test File Organization
- Unit tests: `tests/Unit/`
- Integration tests: `tests/Integration/`
- Test files should mirror source structure
- Name test files: `[FunctionName].Tests.ps1`

## Documentation Standards

### Comment-Based Help
Every public function must include:
- `.SYNOPSIS` - Brief one-line description
- `.DESCRIPTION` - Detailed explanation
- `.PARAMETER` - For each parameter
- `.EXAMPLE` - At least one working example
- `.NOTES` - Additional context if needed
- `.LINK` - Reference links

### Markdown Documentation
- Function documentation: `src/functions/public/[Category]/[Category].md`
- Use clear headings and code examples
- Include real-world usage scenarios

## Configuration Patterns

### PSModule.yml Structure
```yaml
Name: ModuleName

Test:
  Skip: false
  SourceCode:
    Skip: false
  PSModule:
    Skip: false
  Module:
    Skip: false
  CodeCoverage:
    PercentTarget: 80

Build:
  Skip: false
  Module:
    Skip: false
  Docs:
    Skip: false

Publish:
  Module:
    Skip: false
    AutoCleanup: true
    AutoPatching: true
```

## Workflow Understanding

### Pipeline Stages
1. **Get-Settings** - Read configuration
2. **Build-Module** - Compile source into module
3. **Test-SourceCode** - Test source files
4. **Lint-SourceCode** - PSScriptAnalyzer validation
5. **Test-Module** - PSModule framework tests
6. **Test-ModuleLocal** - Pester tests from repo
7. **Get-TestResults** - Aggregate test results
8. **Get-CodeCoverage** - Calculate coverage
9. **Build-Docs** - Generate documentation
10. **Build-Site** - Create static site
11. **Publish** - Release to PowerShell Gallery and GitHub

### Conditional Execution
- Tests run on multiple OS platforms (matrix strategy)
- Steps can be skipped via configuration
- Publishing only occurs on merged PRs

## GitHub Actions Patterns

### Workflow Inputs
```yaml
inputs:
  Name:
    type: string
    description: Module name
    required: false
  SettingsPath:
    type: string
    description: Path to settings file
    default: .github/PSModule.yml
  Debug:
    type: boolean
    description: Enable debug output
    default: false
```

### Secrets Required
- `APIKEY` - PowerShell Gallery API key for publishing

## Common Patterns

### Module Requirements
Use `#Requires` statements at the top of files that need specific modules:
```powershell
#Requires -Modules @{ModuleName='RequiredModule'; ModuleVersion='1.0.0'}
```

### Alias Definitions
```powershell
# Multiple alias methods supported
[Alias('Short-Name1')]
[Alias('Short-Name2')]
function Long-FunctionName {
    # Function body
}

# Alternative alias definitions at end of file
New-Alias Short-Name3 Long-FunctionName
New-Alias -Name Short-Name4 -Value Long-FunctionName
Set-Alias Short-Name5 Long-FunctionName
```

### PSScriptAnalyzer Suppressions
When suppression is necessary, use the standard format:
```powershell
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'RuleName', 'Target', Scope = 'Function',
    Justification = 'Clear reason for suppression'
)]
function Function-Name {
    # Function body
}
```

### Validation
```powershell
[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[ValidatePattern('^[a-zA-Z0-9-]+$')]
[string] $ModuleName
```

## File Patterns to Follow

### Directory Structure
```
.github/
  workflows/          # GitHub Actions workflows
  linters/           # Linter configurations
  PSModule.yml       # Project configuration
src/
  functions/
    public/          # Exported functions
    private/         # Internal functions
  classes/
    public/          # Exported classes
    private/         # Internal classes
  data/              # Configuration files
  assemblies/        # Binary dependencies
  modules/           # Nested modules
tests/
  Unit/              # Unit tests
  Integration/       # Integration tests
docs/                # Additional documentation
```

## Best Practices

1. **Follow PowerShell naming conventions** - Use approved verbs (`Get-Verb`)
2. **Write comprehensive tests first** (TDD approach)
3. **Include proper error handling** with meaningful messages
4. **Document all public interfaces** with comment-based help
5. **Use semantic versioning** for releases
6. **Validate inputs thoroughly** using parameter validation
7. **Write clean, readable code** that follows the style guide
8. **Test on multiple platforms** when making changes

## Troubleshooting

### Common Issues
- **PSScriptAnalyzer violations** - Check against rules in `.powershell-psscriptanalyzer.psd1`
- **Test failures** - Ensure tests follow Pester v5 syntax
- **Build failures** - Verify module manifest and dependencies
- **Documentation errors** - Check mkdocs.yml configuration

When making changes, always:
1. Run PSScriptAnalyzer locally
2. Execute relevant tests
3. Update documentation
4. Follow the established patterns in existing code
