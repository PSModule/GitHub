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

4. **Generate Organization Instructions** - For each discovered language/technology:

   Create `$OrganizationInstructionsPath/main.instructions.md`:
   ```yaml
   ---
   applyTo: "**/*"
   description: "Universal code-writing guidelines for the organization"
   ---
   ```

   Content must include:
   - **File Organization**: How to structure new files, where to place components
   - **Naming Conventions**: Specific patterns for files, functions, variables, constants
   - **Documentation**: Required comment patterns, doc-string formats with examples
   - **Build Integration**: How code integrates with organization build processes

   Create `$OrganizationInstructionsPath/{Language}/main.instructions.md`:
   ```yaml
   ---
   applyTo: "**/*.{ext}"
   description: "Code-writing guidelines for {Language} in organization projects"
   ---
   ```

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

   Create `$RepositoryInstructionsPath/main.instructions.md`:
   ```yaml
   ---
   applyTo: "**/*"
   description: "Project-specific code-writing guidance for {RepositoryName}"
   ---
   ```

   Content must include:
   - **Repository Purpose**: What this project does and why
   - **Architecture Overview**: Component structure, data flow, integration points
   - **Project-Specific Rules**: Overrides or extensions to organization patterns
   - **Workflows**: Development, testing, deployment processes
   - **Dependencies**: Key external dependencies and how they're used

   Create `$RepositoryInstructionsPath/{Language}/main.instructions.md`:
   ```yaml
   ---
   applyTo: "{specific-pattern}"
   description: "How to write {Language} code in this specific project"
   ---
   ```

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
     * All instruction files have valid YAML frontmatter
     * `applyTo` glob patterns are correct and non-overlapping
     * File structure matches specification hierarchy

   - **Content Validation**:
     * Every discovered language has organization instructions
     * Repository instructions provide project-specific context
     * Instructions contain specific, actionable code-writing guidance (not vague principles)
     * Examples are concrete and relevant to the codebase
     * No duplicate or contradictory guidance across files

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

Here’s the ready-to-use template:

```markdown
---
applyTo: "**/*.{ext}"             # A single string Glob pattern for applicable files
description: "Code-writing guidelines for {Language} in this organization/project/repository"
---

# {Language} Instructions

## Style & Formatting
- Indentation: {n} spaces
- Max line length: {n}
- Trailing whitespace: disallowed
- Braces/blocks: {rule}
- Imports/using/order: {rule}
- Naming conventions: {rule} (classes, methods, variables, constants)

**Example:**
```{ext}
// BEFORE: bad formatting
function  foo ( )  {return 42}

// AFTER: correct formatting
function foo() {
    return 42;
}
```

## Project Structure

* **Directory layout** (example tree):

```
src/
  services/
  models/
  tests/
```
* Rules for file placement (public APIs, internal modules)
* Location of configuration files

## Patterns (Do / Don’t)

* ✅ Prefer {X} over {Y}
* ❌ Do not {anti-pattern}

**Example:**

```{ext}
// BEFORE
const result = JSON.parse(fs.readFileSync(path))

// AFTER
const result = await loadConfig(path)
```

## Error Handling

* Use `{error construct}` for {scenarios}
* Wrap I/O and network calls in try/catch
* Always include context in error messages
* Example with logging + rethrow

## Testing

* Testing framework: `{testFramework}`
* Test file layout and naming conventions
* Assertion style: {rule}
* Fixtures/mocks: {approach}
* Coverage floor: {percent}%

**Example:**

```{ext}
test("should compute total", () => {
    expect(sum([1, 2, 3])).toBe(6);
});
```

## Build Frameworks

* Build tool: `{buildTool}`
* Build tasks/scripts location: `{path}`

## CI Frameworks

* CI integration: how builds and tests are executed in pipelines

## Logging & Telemetry

* Use `{logger API}` only
* Levels: DEBUG / INFO / WARN / ERROR — with examples
* Correlation IDs: required for async workflows
* No secrets/PII in logs
* Required structured fields: {list}

## Performance

* Optimize hot paths {rule}
* Guidelines on allocations, I/O usage
* Profiling steps & recommended tools

**Example:**

```{ext}
// BEFORE
let result = "";
for (const item of items) {
    result += item;
}

// AFTER
let result = items.join("");
```

## Dependencies

* Allowed package sources: {registry}
* Pin versions using {approach}
* Dependency injection patterns: {rule}
* Banned packages: {list}

## Documentation

* Required doc-block style: {docStyle}
* Inline documentation example:

```{ext}
/**
 * Adds two numbers.
 * @param {number} a
 * @param {number} b
 * @returns {number}
 */
function add(a, b) { return a + b; }
```
* Location for usage samples (e.g., `/docs/examples/`)
* Link to ADRs or design notes if relevant

## Snippets

Provide canonical ready-to-use snippets for:

* Service/module/class boilerplate
* Unit test boilerplate
* Common error-handling pattern
* Logger usage example

## Forbidden

* ❌ Explicitly disallow {anti-pattern} with rationale
* ❌ Avoid {package/tool} because {reason}
* Provide alternatives: ✅ “Use {X} instead of {Y}”

```
