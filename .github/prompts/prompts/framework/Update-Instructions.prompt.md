---
description: Comprehensive framework for generating and maintaining Copilot instruction files across repositories
mode: agent
model: GPT-5-Codex (Preview) (copilot)
---

# Update Instructions

## Overview

This prompt analyzes codebases and generates, updates, and maintains Copilot instruction files that guide AI coding agents. It implements a structured workflow to create a comprehensive instruction system for the PSModule ecosystem, ensuring consistent guidance across repositories while separating framework-level patterns from project-specific implementations.

For detailed information about how the instruction architecture works, see [Instruction Architecture Documentation](../../../docs/Solutions/GitHub-Copilot-Customization-Architecture.md).

## Specifications

### Target Architecture

The instruction system follows a two-tier hierarchy:

```
$InstructionsPath/
├── framework/                    # Generic, reusable patterns (automation-managed)
│   ├── main.instructions.md     # Universal cross-language guidelines
│   └── {Language}/              # Language-specific framework patterns
│       ├── main.instructions.md
│       ├── tests.instructions.md
│       └── classes.instructions.md
└── repo/                        # Project-specific patterns (manually curated)
    ├── main.instructions.md     # Repository context and rules
    └── {Language}/              # Project-specific language patterns
        └── main.instructions.md
```

**Path Variables** (resolved via `./scripts/Get-Paths.ps1`):
- `$RepositoryPath` - Root repository path
- `$InstructionsPath` - Instructions directory path (e.g., `$RepositoryPath/.github/prompts/framework`)
- `$FrameworkInstructionsPath` - Framework instructions directory path (e.g., `$InstructionsPath/framework`)
- `$RepositoryInstructionsPath` - Repository instructions directory path (e.g., `$InstructionsPath/repo`)

### Content Requirements

#### Framework Instructions (`$FrameworkInstructionsPath/`)

**Universal Cross-Language Guidelines** (`main.instructions.md`)
- General style guidelines applying across all programming languages
- PSModule ecosystem patterns and structure
- PSModule build process integration and tooling
- Universal conventions: naming, file organization, documentation standards
- Consistency guidelines for all repository files

**Language-Specific Technical Guidelines** (`{Language}/main.instructions.md`)
- Language-specific style guidelines and best practices
- Syntax conventions, formatting rules, and idiomatic patterns
- Tooling integration: linters, formatters, build tools
- Code quality standards and technical patterns
- Error handling, logging, testing, and debugging approaches

#### Repository Instructions (`$RepositoryInstructionsPath/`)

**Project-Specific Context and Rules** (`main.instructions.md`)
- Repository purpose, scope, and deliverables
- Project-specific guidelines overriding/extending framework patterns
- Architecture, component relationships, and integration points
- Unique workflows, processes, and procedures
- Target audience, use cases, and business requirements

**Project-Specific Language Implementation** (`{Language}/main.instructions.md`)
- Language usage within this repository's specific context
- Project-specific patterns, conventions, and architectural decisions
- Integration patterns with other repository components
- Concrete examples demonstrating the repository's approach

#### Content Hierarchy and Precedence
1. **Framework instructions** provide foundation and universal patterns
2. **Repository instructions** override and extend framework instructions
3. **Language-specific instructions** inherit from their main instruction files
4. **Repository language instructions** take precedence over framework language instructions

### Quality Standards

#### File Format Requirements
```yaml
---
applyTo: <glob pattern for target files>
description: <succinct purpose in one sentence>
---
```
Content structure: Context lead, Goal, Execution steps, Behavior rules, Output format, Error handling, Definitions

#### Validation Criteria
- All instruction files must have proper YAML frontmatter
- `applyTo` patterns must correctly target intended file types
- Content completeness across all discovered languages/technologies
- Consistent terminology and patterns across instruction files
- Proper framework vs repository categorization

#### Success Metrics
- No content loss during migration or updates
- Complete technology coverage for discovered languages
- Proper separation of generic vs project-specific guidance
- All legacy instruction content successfully migrated

## Implementation Guide

### Prerequisites

1. **Path Resolution**: Execute [Gather.ps1](scripts/Gather.ps1) to establish required path variables
2. **Workspace Setup**: Ensure multiple repository scenario handling
3. **Backup Strategy**: Plan rollback procedures for failed migrations

### Execution Workflow

The implementation follows five distinct phases with clear gates between each:

#### Phase 1: Setup (T001)
- **Gate**: All paths resolved and validated
- Path resolution and workspace preparation

#### Phase 2: Analysis (T002-T003)
- **Gate**: Complete content inventory and categorization plan
- Discovery and content categorization planning

#### Phase 3: Creation (T004-T005)
- **Gate**: All instruction files created with proper structure
- Framework and repository instruction file creation

#### Phase 4: Migration (T006)
- **Gate**: All legacy content successfully migrated
- Content migration from legacy sources

#### Phase 5: Validation (T007-T009)
- **Gate**: System validated, cleaned up, and user feedback collected
- Quality validation, cleanup, and final verification

### Task Dependencies

```
T001 (Path Resolution)
   ↓
T002 (Discovery)
   ↓
T003 (Planning)
   ↓
T004 (Framework Creation)
   ↓
T005 (Repository Creation)
   ↓
T006 (Migration)
   ↓
T007 (Validation)
   ↓
T008 (Cleanup)
   ↓
T009 (Final)
```

### Detailed Tasks

Execute tasks in the specified order, with each task depending on successful completion of previous tasks:

#### T001: Path Resolution
- **Dependencies**: None
- **Goal**: Determine repository-specific paths for consistent task execution
- **Key Actions**: Run path resolution script, validate all required paths, ensure workspace compatibility
- **Success Criteria**: All paths resolved and validated

#### T002: Discovery and Analysis
- **Dependencies**: T001
- **Goal**: Analyze existing instruction structure and identify content sources
- **Key Actions**: Catalog existing instructions, identify languages/technologies, analyze codebase patterns
- **Success Criteria**: Complete inventory of existing content and technology discovery

#### T003: Content Categorization and Planning
- **Dependencies**: T002
- **Goal**: Plan content migration and organization strategy based on specifications
- **Key Actions**: Categorize content (framework vs repo-specific), identify gaps, plan file structure
- **Success Criteria**: Clear categorization plan with no ambiguous content

#### T004: Framework Instructions Creation/Update
- **Dependencies**: T003
- **Goal**: Create generic, reusable instruction files according to specifications
- **Key Actions**: Create universal guidelines, language-specific technical patterns, specialized components
- **Success Criteria**: All framework instruction files created with proper structure and content

#### T005: Repository-Specific Instructions Creation/Update
- **Dependencies**: T003
- **Goal**: Create project-specific instruction files according to specifications
- **Key Actions**: Create project context, repository-specific language patterns, specialized workflows
- **Success Criteria**: All repo-specific instruction files created with project context

#### T006: Content Migration from Legacy Files
- **Dependencies**: T004, T005
- **Goal**: Migrate content from legacy sources without loss
- **Key Actions**: Extract legacy content, categorize by type, migrate to appropriate instruction files
- **Success Criteria**: All legacy content successfully migrated without loss

#### T007: Structure Validation and Quality Check
- **Dependencies**: T006
- **Goal**: Validate instruction system completeness and accuracy
- **Key Actions**: Verify YAML frontmatter, validate file patterns, check content completeness
- **Success Criteria**: All validation checks pass with no structural or content issues

#### T008: Legacy File Cleanup
- **Dependencies**: T007
- **Goal**: Clean up legacy instruction files after successful migration
- **Key Actions**: Verify migration completion, remove legacy files, clean up loose files
- **Success Criteria**: Legacy files cleaned up only after confirmed migration

#### T009: Final Validation and User Feedback
- **Dependencies**: T008
- **Goal**: Complete final system validation and provide user feedback
- **Key Actions**: Final validation, provide completion summary, collect user feedback
- **Success Criteria**: Final validation completed and user feedback provided

## Reference

### Content Templates

#### YAML Frontmatter Template
```yaml
---
applyTo: "<glob pattern targeting specific file types>"
description: "Brief, actionable description of the instruction's purpose"
---
```

#### Instruction File Structure
```markdown
# Brief Context (if needed)

## Goal
Clear statement of what this instruction achieves.

## Execution Steps
1. Step-by-step actions
2. Ordered list format
3. Specific and actionable

## Behavior Rules
- Constraints and requirements
- Quality standards
- Error handling approaches

## Examples (if applicable)
Concrete examples demonstrating the patterns.
```

### Quick Reference

#### Content Categorization Matrix
| Content Type | Framework | Repository |
|--------------|-----------|------------|
| Style guidelines | Universal patterns | Project-specific overrides |
| Language patterns | Generic best practices | Repository-specific implementation |
| Architecture | N/A | Project structure and components |
| Build/Deploy | Generic PSModule process | Project-specific workflows |
| Testing | Universal test patterns | Project-specific test strategies |

#### Task Execution Checklist
- [ ] **T001**: Path variables established and validated
- [ ] **T002**: Content inventory complete with technology identification
- [ ] **T003**: Categorization plan created with clear framework/repo separation
- [ ] **T004**: Framework instructions created following specifications
- [ ] **T005**: Repository instructions created with project context
- [ ] **T006**: Legacy content migrated without loss
- [ ] **T007**: All validation checks passed
- [ ] **T008**: Legacy files cleaned up safely
- [ ] **T009**: User feedback collected and system verified

### Troubleshooting

#### Common Issues and Solutions

**Issue**: Content categorization unclear
- **Solution**: Apply hierarchy: Generic patterns → framework, Project-specific patterns → repository

**Issue**: Legacy content migration incomplete
- **Solution**: Abort cleanup, verify all content accounted for, retry migration

**Issue**: Validation failures
- **Solution**: Check YAML frontmatter format, verify `applyTo` patterns, ensure content completeness

**Issue**: Path resolution fails
- **Solution**: Verify `./scripts/Get-Paths.ps1` exists and executes successfully

#### Recovery Procedures
- **Before T008**: All operations are additive, safe to retry individual tasks
- **During T008**: STOP if any validation fails - content loss risk
- **After T008**: Recovery requires manual restoration from version control

#### Abort Conditions
- Path resolution script unavailable or fails
- Critical content cannot be categorized (framework vs repository)
- Legacy content migration would result in data loss
- Validation reveals structural inconsistencies that cannot be resolved

### Validation Checklists

#### Pre-Execution Validation
- [ ] Repository paths accessible and writable
- [ ] Path resolution script available: `./scripts/Get-Paths.ps1`
- [ ] Backup/recovery strategy in place
- [ ] Multiple repository workspace scenario confirmed

#### Task Completion Validation
- [ ] No content loss during any migration step
- [ ] All instruction files have valid YAML frontmatter
- [ ] `applyTo` patterns correctly target intended file types
- [ ] Framework vs repository categorization follows hierarchy rules
- [ ] All discovered technologies have appropriate instruction coverage

#### Final System Validation
- [ ] Complete instruction system covers all repository needs
- [ ] Legacy files removed only after confirmed migration
- [ ] Framework instructions suitable for automation management
- [ ] Repository instructions remain manually curated
- [ ] User feedback indicates system completeness and usability
