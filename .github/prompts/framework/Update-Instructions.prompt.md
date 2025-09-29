---
description: Analyze codebases and generate/update Copilot instruction files that guide AI coding agents with specific, actionable code-writing guidance.
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

Goal: Generate and maintain a comprehensive instruction system that provides specific, actionable guidance for writing code. The system separates organization-level patterns (automation-managed) from project-specific implementations (manually curated).

Execution steps:

1. **Gather** - Run [Gather.ps1](scripts/Gather.ps1) parse outputs for:
   - `$RepositoryPath` - Root repository path
   - `$InstructionsPath` - Instructions directory (e.g., `$RepositoryPath/.github/prompts/organization`)
   - `$OrganizationInstructionsPath` - Organization instructions directory (e.g., `$InstructionsPath/organization`)
   - `$RepositoryInstructionsPath` - Repository instructions directory (e.g., `$InstructionsPath/Repository`)

   If path resolution fails, abort and instruct user to verify script availability.

2. **Discovery and Analysis** - Perform comprehensive codebase scan:
   - Identify all languages and frameworks in use (scan file extensions, imports, dependencies)
   - Catalog existing instruction files and their coverage
   - Discover code patterns, naming conventions, and architectural decisions from actual code
   - Identify testing frameworks, build tools, and deployment patterns
   - Extract project-specific patterns from README, existing code, and configuration files

   Build an internal technology inventory map (languages → files → patterns).

3. **Content Categorization Planning** - For each discovered item, determine placement:

   **Organization Instructions** (automation-managed, `$OrganizationInstructionsPath/`):
   - Universal cross-language guidelines (`main.instructions.md`):
     * File organization and naming conventions
     * Documentation standards and comment patterns
     * Organization-wide integration patterns
     * Build process and tooling workflows

   - Language-specific patterns (`{Language}/main.instructions.md`):
     * Syntax formatting and code style (indentation, braces, line breaks)
     * Idiomatic language patterns and best practices
     * Error handling patterns with concrete examples
     * Testing patterns and assertion styles
     * Logging and debugging approaches
     * Performance optimization patterns

   **Repository Instructions** (manually curated, `$RepositoryInstructionsPath/`):
   - Project-specific context (`main.instructions.md`):
     * Repository purpose and scope
     * Architecture and component relationships
     * Unique workflows and processes
     * Project-specific overrides to organization patterns

   - Project-specific language usage (`{Language}/main.instructions.md`):
     * How this project uses the language specifically
     * Project-specific architectural patterns
     * Concrete code examples from this repository
     * Integration patterns between components

   **Categorization Rules**:
   - If pattern applies across all organization projects → Organization
   - If pattern is specific to this repository → Repository
   - When uncertain, default to Repository (can promote to Organization later)
   - Organization content must be generic enough for automation management

   **Unified Frontmatter Specification (applies to ALL instruction files)**
   Frontmatter MUST:
   - Contain exactly 2 fields in this order:
     1. `description`: Single-line string describing the file's purpose
     2. `applyTo`: Single string with one or more glob patterns (comma-separated if multiple)
   - Use only one YAML document block at the very top of the file (`---` ... `---`)
   - Avoid inline comments or extra keys
   - Represent multiple patterns in a single line, never as YAML arrays
  - Maintain field order: `description` first, then `applyTo`

   Examples:
   ```yaml
  ---
  description: "Universal code-writing guidelines for the organization"
  applyTo: "**/*"
  ---
   ```
   ```yaml
  ---
  description: "PowerShell code-writing guidelines for organization projects"
  applyTo: "**/*.ps1, **/*.psm1, **/*.psd1"
  ---
   ```
   ```yaml
  ---
  description: "Project-specific TypeScript patterns for {RepositoryName}"
  applyTo: "src/**/*.ts, scripts/**/*.ts"
  ---
   ```

   Validation rules enforced later (Step 7):
  - Exactly two keys present: `description`, `applyTo`
   - Both values non-empty strings
   - `applyTo` contains one or more glob patterns separated by commas in a single string
   - No duplicate normalized glob patterns
   - No table of contents headings in file content

4. **Generate Organization Instructions** - For each discovered language/technology:

  Create `$OrganizationInstructionsPath/main.instructions.md` frontmatter using the Unified Frontmatter Specification (do not re-document rules here):
  - description: "Universal code-writing guidelines for the organization"
  - applyTo: `**/*`

   Content must include:
   - **File Organization**: How to structure new files, where to place components
   - **Naming Conventions**: Specific patterns for files, functions, variables, constants
   - **Documentation**: Required comment patterns, doc-string formats with examples
   - **Build Integration**: How code integrates with organization build processes

  Create `$OrganizationInstructionsPath/{Language}/main.instructions.md` frontmatter (unified spec) with:
  - description: "Code-writing guidelines for {Language} in organization projects"
  - applyTo: `**/*.{ext}`

   Content must include specific, actionable rules:
   - **Syntax Style**: Exact formatting rules (e.g., "Place opening brace on same line", "Use 4-space indentation")
   - **Code Patterns**: Common patterns with before/after examples
   - **Error Handling**: Specific error handling patterns (e.g., "Use try-catch for I/O operations", "Always include error context")
   - **Testing**: Test structure, assertion patterns, mocking approaches with examples
   - **Imports/Dependencies**: How to organize imports, dependency injection patterns
   - **Performance**: Specific optimization patterns (e.g., "Use StringBuilder for string concatenation in loops")

   Create specialized files as needed:
   - `tests.instructions.md` - Testing-specific patterns
   - `classes.instructions.md` - Class design patterns
   - Additional domain-specific instruction files

5. **Generate Repository Instructions** - Create project-specific guidance:

  Create `$RepositoryInstructionsPath/main.instructions.md` frontmatter (unified spec) with:
  - description: "Project-specific code-writing guidance for {RepositoryName}"
  - applyTo: `**/*`

   Content must include:
   - **Repository Purpose**: What this project does and why
   - **Architecture Overview**: Component structure, data flow, integration points
   - **Project-Specific Rules**: Overrides or extensions to organization patterns
   - **Workflows**: Development, testing, deployment processes
   - **Dependencies**: Key external dependencies and how they're used

  Create `$RepositoryInstructionsPath/{Language}/main.instructions.md` frontmatter (unified spec) with:
  - description: "How to write {Language} code in this specific project"
  - applyTo: `{specific-pattern}`

   Content must include concrete examples from the actual codebase:
   - **Project Patterns**: Specific architectural patterns used (e.g., "Use Factory pattern in src/factories/")
   - **Code Examples**: Real examples from the codebase showing correct patterns
   - **Integration**: How components interact (e.g., "Services depend on repositories, never directly on data layer")
   - **Conventions**: Project-specific naming or structure rules

6. **Migrate Legacy Content** - If legacy instruction files exist:
   - Read each legacy file completely
   - Categorize content sections (organization vs repository-specific)
   - Extract specific, actionable code-writing guidance
   - Discard vague guidance like "write good code" - replace with specific rules
   - Migrate content to appropriate new instruction files
   - Verify no content loss (compare old vs new content coverage)
   - DO NOT delete legacy files until migration is verified in step 7

7. **Validation** - Verify generated instruction system:
   - **Structural Validation**:
  * All instruction files have valid YAML frontmatter per the Unified Frontmatter Specification
     * `description` is a single string
     * `applyTo` is a single string containing glob pattern(s) - comma-separated if multiple
  * Field order is `description` first, then `applyTo`
     * No table of contents sections in any instruction file
     * File structure matches specification hierarchy

   - **Content Validation**:
     * Every discovered language has organization instructions
     * Repository instructions provide project-specific context
     * Instructions contain specific, actionable code-writing guidance (not vague principles)
     * Examples are concrete and relevant to the codebase
     * No duplicate or contradictory guidance across files
     * Content is concise - no unnecessary sections or philosophical discussions
     * Each section provides actionable patterns, not generic advice

   - **Coverage Validation**:
     * All file types in repository are covered by appropriate instructions
     * Testing, error handling, and logging patterns are documented
     * Organization-vs-repository categorization is correct

   If validation fails, report specific issues and DO NOT proceed to cleanup.

8. **Cleanup** - Only after successful validation:
   - Remove legacy instruction files that were fully migrated
   - Clean up temporary files or outdated patterns
   - Report final instruction file structure

9. **Report Completion** - Provide structured summary:
   - List all generated instruction files with paths
   - Show coverage: languages discovered vs languages documented
   - Highlight any gaps or manual curation needed
   - Provide statistics: number of organization files, repository files, legacy files migrated
   - Suggest next actions (e.g., "Review repository instructions for accuracy")

Behavior rules:

- **Frontmatter Requirements**: Follow the Unified Frontmatter Specification (single two-key block, no inline comments, order enforced).
- **No Table of Contents**: Instruction files MUST NOT include a table of contents or navigation sections. Start directly with actionable content.
- **Conciseness Required**: Keep instructions minimal and focused. Every section must provide actionable code-writing guidance. Remove:
  * Philosophical discussions or "why" explanations beyond brief context
  * Redundant examples that don't add new patterns
  * Generic advice that applies universally (e.g., "write clean code")
  * Sections that don't apply to the specific project/language
- **Code-Specific Focus**: Instructions must be about *how to write code*, not general principles. Replace "Follow best practices" with "Use StringBuilder for string concatenation inside loops to avoid O(n²) performance".
- **Actionable Guidance**: Every rule must be specific enough to execute. Replace "Handle errors appropriately" with "Wrap all I/O operations in try-catch blocks with context-aware error messages".
- **Concrete Examples**: Include before/after code examples, especially for common patterns.
- **Hierarchical Override**: Repository instructions can override organization instructions - document overrides explicitly.
- **No Vagueness**: Remove generic advice like "write clean code". Specify what "clean" means in measurable terms.
- **Halt on Validation Failure**: Never proceed to cleanup if validation detects issues - report problems first.
- **Preserve Content**: During migration, err on the side of preserving too much rather than losing guidance.
- **Absolute Paths**: All file operations must use absolute paths resolved in step 1.

Error handling:

- **Path Resolution Failure**: Abort with instructions to verify `./scripts/Get-Paths.ps1`
- **Content Categorization Ambiguity**: Default to repository-specific, flag for manual review
- **Validation Failures**: Report specific issues with file paths and guidance for fixing
- **Legacy Migration Conflicts**: Preserve both versions in comments, flag for manual resolution
- **Missing Coverage**: Report gaps but complete generation for covered areas

Output format:

Provide a structured completion report:
```
✅ Instruction System Generation Complete

Organization Instructions Generated:
- $OrganizationInstructionsPath/main.instructions.md
- $OrganizationInstructionsPath/{Language}/main.instructions.md (per language)
- {Additional specialized files}

Repository Instructions Generated:
- $RepositoryInstructionsPath/main.instructions.md
- $RepositoryInstructionsPath/{Language}/main.instructions.md (per language)

Coverage Statistics:
- Languages Discovered: {count} ({list})
- Organization Files: {count}
- Repository Files: {count}
- Legacy Files Migrated: {count}
- Legacy Files Removed: {count}

⚠️ Manual Review Needed:
- {List any ambiguous categorizations}
- {List any missing coverage areas}
- {List any validation warnings}

Next Actions:
- Review repository-specific instructions for accuracy
- Test instruction application on sample code generation
- Update any project-specific patterns that emerged during generation
```

Context for instruction generation: $ARGUMENTS

### Template for language oriented instructions

Use this minimal template when creating a new language/project instruction file. Omit sections that are not relevant.

```markdown
---
description: "Code-writing guidelines for {Language} in this organization/project/repository"
applyTo: "**/*.{ext}"
---

## Style & Formatting
- Indentation: {n} spaces
- Max line length: {n}
- Trailing whitespace: disallowed
- Braces/blocks: {rule}
- Imports/using/order: {rule}
- Naming conventions: {rule}

**Example:**
```{ext}
// BEFORE: bad formatting
function  foo ( )  {return 42}

// AFTER: correct formatting
function foo() {
  return 42;
}
```

## Patterns (Do / Don't)
* ✅ Prefer {X} over {Y}
* ❌ Avoid {anti-pattern}

```{ext}
// BEFORE
const result = JSON.parse(fs.readFileSync(path))
// AFTER
const result = await loadConfig(path)
```

## Error Handling
* Use `{error construct}` for {scenarios}
* Include context in thrown errors

## Testing
* Framework: `{testFramework}`
* Layout & naming conventions

```{ext}
test("should compute total", () => {
  expect(sum([1, 2, 3])).toBe(6);
});
```

## Performance
```{ext}
// BEFORE (inefficient)
let result = "";
for (const item of items) { result += item; }
// AFTER
let result = items.join("");
```

## Documentation
```{ext}
/**
 * Adds two numbers.
 */
function add(a, b) { return a + b; }
```

## Forbidden
* ❌ {anti-pattern} → ✅ Use {preferred pattern}

<!-- TEMPLATE NOTES:
Keep files concise. Remove any unused sections. Each rule must be actionable with a concrete example. -->
```
