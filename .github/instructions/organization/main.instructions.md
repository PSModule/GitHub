---
description: "Universal code-writing guidelines for the organization"
applyTo: "**/*"
---

# PSModule Organization Instructions

## File Organization

- **Module Structure**: Follow PowerShell module best practices with clear separation of concerns
  - `src/` - All source code
  - `tests/` - All test files
  - `examples/` - Usage examples
  - `tools/` - Development and utility scripts
  - `icon/` - Module branding assets

- **Source Directory Layout**:
  ```
  src/
    functions/
      public/     # Exported functions
      private/    # Internal helper functions
    classes/
      public/     # Exported classes
    formats/      # .Format.ps1xml files
    types/        # .Types.ps1xml files
    variables/    # Module-level variables
    loader.ps1    # Module initialization
    header.ps1    # Module requirements and headers
    manifest.psd1 # Module manifest
    completers.ps1 # Argument completers
  ```

- **File Placement Rules**:
  - One function per file, named exactly as the function (e.g., `Get-GitHubRepository.ps1`)
  - One class per file, named after the class (e.g., `GitHubRepository.ps1`)
  - Group related functions in folders by object type, not by API endpoint
  - Test files follow naming: `{Feature}.Tests.ps1`

## Naming Conventions

- **Files**: PascalCase matching the function/class name exactly
  - ✅ `Get-GitHubRepository.ps1`
  - ❌ `get-githubrepository.ps1`
  - ❌ `GetGitHubRepository.ps1`

- **Functions**: Verb-Noun format with module prefix
  - Public: `Verb-ModuleNoun` (e.g., `Get-GitHubRepository`)
  - Private: `Verb-ModuleNoun` (same format, no export)
  - Use approved PowerShell verbs only

- **Parameters**: PascalCase
  - ✅ `$Owner`, `$Repository`, `$PerPage`
  - ❌ `$owner`, `$repo_name`, `$per_page`

- **Variables**: camelCase for local variables, PascalCase for parameters
  - ✅ `$apiEndpoint`, `$userData`
  - ❌ `$APIEndpoint`, `$api_endpoint`

- **Classes**: PascalCase with module prefix
  - ✅ `GitHubRepository`, `GitHubOwner`
  - ❌ `githubRepository`, `GitHub_Repository`

- **Properties**: PascalCase
  - ✅ `$repo.Name`, `$repo.FullName`
  - ❌ `$repo.name`, `$repo.full_name`

## Documentation Standards

- **Comment-Based Help**: Required for all public functions
  - Use `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.INPUTS`, `.OUTPUTS`, `.LINK`
  - Place before function definition
  - Always include at least one `.EXAMPLE` with fenced code blocks (```)

- **Example Format**:
  ````powershell
  <#
      .SYNOPSIS
      Brief one-line description.

      .DESCRIPTION
      Detailed description of what the function does.

      .EXAMPLE
      ```powershell
      Get-Something -Name 'example'
      ```

      Description of what this example does.

      .PARAMETER Name
      Description of the Name parameter.

      .LINK
      https://psmodule.io/ModuleName/Functions/Get-Something/
  #>
  ````

- **Inline Comments**: Use `#` for single-line comments explaining complex logic
- **Permission Comments**: Always document required API permissions in the `begin` block

## Build Integration

- **Module Manifest**: Central configuration in `src/manifest.psd1`
- **Loader Pattern**: Use `src/loader.ps1` for module initialization
- **Header Requirements**: Declare module dependencies in `src/header.ps1`
- **Auto-Loading**: Functions and classes are auto-discovered and loaded

## Code Quality Standards

- **Linting**: All code must pass PSScriptAnalyzer rules
- **SuppressMessageAttribute**: Only use when justified with clear reasoning
  ```powershell
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
      'PSAvoidUsingWriteHost', '',
      Justification = 'Required for GitHub Actions output.'
  )]
  ```

- **Error Handling**: Use structured error handling (see language-specific instructions)
- **Verbose Output**: Use `Write-Debug` and `Write-Verbose` appropriately
- **Progress Indicators**: Use `Write-Progress` for long-running operations

## Version Control

- **Git Workflow**: Feature branches, pull requests, code reviews
- **Commit Messages**: Clear, descriptive commit messages
- **Branching**: `main` as default branch, feature branches for development

## Testing Requirements

- **Test Coverage**: Aim for high coverage, but 100% is not required
- **Test Organization**: Mirror source structure in tests directory
- **Test Naming**: `{Feature}.Tests.ps1` format
- **Test Framework**: See language-specific instructions for framework details
