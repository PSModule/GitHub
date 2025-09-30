---
applyTo: "**/*"
description: GitHub PowerShell Module specific patterns and conventions.
---

# GitHub Module Repository Instructions

> **Context**: This is the GitHub PowerShell module repository - a comprehensive PowerShell wrapper for the GitHub API.

## Repository Architecture

### Module Structure
- `src/functions/public/` - User-facing cmdlets organized by GitHub object type (Repositories, Issues, etc.)
- `src/functions/private/` - Internal helper functions
- `src/classes/public/` - PowerShell classes for GitHub objects (GitHubRepository, GitHubUser, etc.)
- `src/formats/` - Custom formatting for display output
- `src/types/` - Type extensions and aliases

### Core Design Patterns
- **Object-oriented organization**: Functions grouped by GitHub entity type, not API endpoints
- **Context-aware**: Automatically detects GitHub Actions environment and loads context
- **Pipeline-friendly**: All public functions support pipeline input where appropriate
- **Authentication abstraction**: Single connection model supporting multiple auth types

## Development Workflows

### Function Creation
Use the utility script to scaffold new functions:
```powershell
.\tools\utilities\New-Function.ps1 -Path "Repositories" -Method "GET"
```

### Local Development
```powershell
# Import module for testing
Import-Module ./src/GitHub.psm1 -Force

# Connect and test
Connect-GitHubAccount
Get-GitHubRepository -Owner PSModule -Name GitHub
```

### Testing
```powershell
# Run all tests
pwsh -Command "Invoke-Pester"

# Run specific test suite
pwsh -Command "Invoke-Pester -Path tests/Repositories.Tests.ps1"
```

## File Organization Rules
- Group by GitHub object type (Repository, Issue, etc.), not by API operation
- One API endpoint = one function
- Public functions in `public/ObjectType/`, private in `private/ObjectType/`
- Classes mirror the object hierarchy from GitHub API

## Key Integration Points
- **GitHub Actions**: Auto-detects runner environment, imports event data
- **Azure Key Vault**: Supports GitHub App key storage in Key Vault
- **PSModule Framework**: Follows PSModule.io conventions and build system
- **Pester Testing**: Comprehensive test suite with auth context scenarios

## Module Capabilities
This module serves as both a local automation tool and a GitHub Actions companion, with special handling for CI/CD scenarios and enterprise environments.

### Supported Features
- Multiple authentication methods (PATs, GitHub Apps, OAuth, device flow)
- GitHub Actions context awareness
- Enterprise GitHub (GHES, GHEC) support
- Pipeline-friendly cmdlets with standard PowerShell conventions
