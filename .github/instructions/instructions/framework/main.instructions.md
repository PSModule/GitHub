---
applyTo: '**/*'
description: Universal cross-language guidelines for PSModule framework development.
---

# PSModule Framework Guidelines

Universal patterns and conventions that apply across all programming languages and file types within the PSModule ecosystem.

## Goal
- Establish consistent development patterns across all PSModule repositories
- Provide foundational guidelines that language-specific instructions build upon
- Ensure compatibility with PSModule build processes, tooling, and ecosystem integration

## Execution Steps
1. Review target file type and apply language-specific instructions in addition to these universal guidelines
2. Follow PSModule naming conventions and file organization patterns
3. Integrate with established build processes, authentication patterns, and logging standards
4. Validate changes against both local tooling and CI automation
5. Document new patterns for potential promotion to framework-level guidance

## Behavior Rules
- **Naming Conventions**
  - Use PascalCase for public functions, types, and exported members
  - Use kebab-case for file names and directory structures
  - Use descriptive, intention-revealing names that align with domain terminology
- **File Organization**
  - Maintain consistent directory structures across repositories
  - Separate public/private components clearly
  - Group related functionality logically
- **Documentation Standards**
  - All public APIs must have complete documentation
  - Include examples that demonstrate real-world usage patterns
  - Link to related documentation and external references
- **Build Integration**
  - Support cross-platform compatibility (Windows, Linux, macOS)
  - Integrate with existing PSModule build and deployment pipelines
  - Ensure compatibility with automated testing and validation processes
- **Authentication & Security**
  - Use PSModule authentication abstractions for external service integration
  - Follow principle of least privilege for permissions and access
  - Implement proper error handling for authentication failures
- **Logging & Observability**
  - Use structured logging with LogGroup for consistency
  - Include appropriate level of detail for debugging and monitoring
  - Support pipeline-friendly output formats

## Output Format
- All artifacts must be compatible with PSModule tooling and build processes
- Follow established patterns for the target file type
- Maintain consistency with existing repository structure and conventions

## Error Handling
- Provide clear, actionable error messages
- Include context for debugging and resolution
- Follow established patterns for error handling in the target technology
- Document known issues and workarounds

## Definitions
| Term | Description |
| --- | --- |
| **PSModule ecosystem** | Collection of PowerShell modules, documentation, and tooling following consistent patterns |
| **LogGroup** | Structured logging system used across PSModule repositories |
| **Cross-platform compatibility** | Support for Windows, Linux, and macOS operating systems |
| **Authentication abstractions** | Standardized patterns for handling external service authentication |
