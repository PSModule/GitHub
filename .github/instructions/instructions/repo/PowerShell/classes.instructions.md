---
applyTo: '**/classes/**/*.ps1'
description: Repository-specific PowerShell class patterns for GitHub objects.
---

# GitHub Module Class Guidelines

## GitHub Object Class Structure
- One class per file, named after the GitHub resource type
- Use PascalCase for all public properties and methods
- Extend `GitHubNode` for objects with database/node IDs from GitHub API

## GitHub-Specific Property Standards
- `ID` property for GitHub database ID (aliased to `DatabaseID` via types)
- `NodeID` property for GitHub GraphQL node ID
- Size properties in bytes, named `Size` (GitHub API standard)
- Include GitHub scope properties (Enterprise, Owner, Repository, etc.)

## GitHub Class Aliases
- Add class name as alias property pointing to primary identifier
- Example: `GitHubRepository` has `Repository` property pointing to `Name`
- Use types files (`.Types.ps1xml`) for property aliases matching GitHub API

## GitHub Object Documentation
- Include comprehensive property descriptions matching GitHub API documentation
- Document expected value formats and examples from GitHub API responses
- Reference official GitHub API documentation for complex properties
- Include permission requirements and availability information

## GitHub API Integration
- Properties should match GitHub API response field names where possible
- Handle GitHub API timestamp formats and convert to PowerShell DateTime
- Support both REST API and GraphQL API response patterns
- Include calculated properties for derived GitHub data

## Inheritance Hierarchy for GitHub Objects
- Use `GitHubNode` base class for objects with ID and URL properties
- Implement common GitHub interfaces consistently across related classes
- Override methods only when necessary for GitHub-specific behavior
- Maintain serialization compatibility with GitHub API responses

## JSON Integration for GitHub API
- Ensure classes serialize/deserialize correctly with GitHub API responses
- Use appropriate property names that match GitHub API field names
- Handle null values gracefully during GitHub API deserialization
- Support round-trip serialization for GitHub API data

## Reference Implementation Files
- See `src/classes/public/GitHubNode.ps1` for base class pattern
- See `src/classes/public/Repositories/` for GitHub repository object examples
- Check `src/types/` for GitHub-specific property alias patterns
- Reference GitHub API documentation for object structure
