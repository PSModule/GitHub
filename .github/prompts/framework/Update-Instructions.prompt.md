---
description: Analyze codebases and generate/update Copilot instruction files that guide AI coding agents with specific, actionable code-writing guidance.
---

The user input to you can be provided directly by the agent or as a command argument - you **MUST** consider it before proceeding with the prompt (if not empty).

User input:

$ARGUMENTS

Goal: Generate and maintain a comprehensive instruction system that provides specific, actionable guidance for writing code. The system separates organization-level patterns (automation-managed) from project-specific implementations (manually curated).

### Folder Structure Specification

The `.github/` folder contains three Copilot configuration directories, each supporting the three-tier structure:

```
.github/
├─instructions/                     # AI agent guidance and patterns
│ ├─enterprise/                     # Enterprise-wide standard customizations
│ │ ├─main.instructions.md          # Enterprise-wide style and coding guidelines
│ │ └─{Language}/                   # Enterprise-wide language-specific patterns
│ │   ├─main.instructions.md        # Enterprise-wide language-specific general style guides
│ │   └─{component}.instructions.md # Enterprise-wide language-specific component requirements (i.e. classes, tests)
│ ├─organization/                   # Organization-wide standard customizations
│ │ ├─main.instructions.md          # Organization-wide style and coding guidelines
│ │ └─{Language}/                   # Organization-wide language-specific patterns
│ │   ├─main.instructions.md        # Organization-wide language-specific general style guides
│ │   └─{component}.instructions.md # Organization-wide language-specific component requirements (i.e. classes, tests)
│ └─repository/                     # Repository-specific overrides
│   ├─main.instructions.md          # Repository-specific style and coding guidelines
│   └─{Language}/                   # Repository-specific language-specific patterns
│     ├─main.instructions.md        # Repository-specific language-specific general style guides
│     └─{component}.instructions.md # Repository-specific language-specific component requirements (i.e. classes, tests)
├─prompts/                          # Reusable prompts
│ ├─enterprise/                     # Enterprise-wide prompts
│ │ └─{prompt-files}                #
│ ├─organization/                   # Organization-wide prompts
│ │ └─{prompt-files}                #
│ └─repository/                     # Repository-specific prompts
│   └─{prompt-files}                #
└─chatmodes/                        # Specialized chat modes
  ├─enterprise/                     # Enterprise-wide chat modes
  │ └─{chatmode-files}              #
  ├─organization/                   # Organization-wide chat modes
  │ └─{chatmode-files}              #
  └─repository/                     # Repository-specific chat modes
    └─{chatmode-files}              #
```

Execution steps:

1. **Gather** - Run [Gather.ps1](scripts/Gather.ps1) parse outputs for:
  - `$RepositoryPath` - Root repository path
  - `$InstructionsPath` - Instructions directory root (e.g., `$RepositoryPath/.github/instructions` or `$RepositoryPath/.github/prompts` depending on workspace layout)
  - `$EnterpriseInstructionsPath` (optional) - Enterprise instructions directory (e.g., `$InstructionsPath/enterprise`). Treat as highest precedence for universal, multi-organization guidance. If not present, skip enterprise-level operations gracefully.
  - `$OrganizationInstructionsPath` - Organization instructions directory (e.g., `$InstructionsPath/organization`)
  - `$RepositoryInstructionsPath` - Repository instructions directory (e.g., `$InstructionsPath/repository` or `$InstructionsPath/Repository` — resolve case-insensitively, prefer existing path)

  If multiple candidate folders exist differing only by case, select the one with existing content; otherwise create in lowercase. All subsequent generated paths must use the resolved casing to avoid duplication.
  If path resolution fails, abort and instruct user to verify script availability.

2. **Discovery and Analysis** - Perform comprehensive codebase scan:
  - Obtain a flat, sorted list of all repository files by running the [Get-RepositoryFiles.ps1 -RepositoryPath $RepositoryPath](./scripts/Get-RepositoryFiles.ps1).
    Treat this list as the authoritative source for building the language mapping. When mapping, simply derive:
    - Extension: `[IO.Path]::GetExtension(path).ToLowerInvariant()`
    - Relative path (if needed): `path.Substring($RepositoryPath.Length).TrimStart('\\','/')`
    Manually ignore common binary/asset extensions (e.g. .png, .jpg, .jpeg, .gif, .ico, .lock, .exe, .dll, .pdb, .zip, .gz, .7z, .tar, .tgz, .bmp, .svg).
   - Identify all languages and frameworks in use (scan file extensions, imports, dependencies)
   - Catalog existing instruction files and their coverage
   - Discover code patterns, naming conventions, and architectural decisions from actual code
   - Identify testing frameworks, build tools, and deployment patterns
   - Extract project-specific patterns from README, existing code, and configuration files
   - Produce a canonical LANGUAGE MAPPING from file extensions → inferred language → representative sample files.
     * Collect all unique file extensions excluding binary/asset types (default ignore: .png, .jpg, .gif, .ico, .lock, .exe, .dll, .pdb, .zip, .gz, .7z)
     * Normalize extensions to lowercase.
     * Map extensions to language buckets using rules (examples):
       - .ps1, .psm1, .psd1 → PowerShell
       - .ps1xml → XML (PowerShell metadata) (treat as XML specialization)
       - .md → Markdown (documentation authoring)
       - .yml, .yaml → YAML (CI / config)
       - .json → JSON (configuration/data)
       - .xml (generic) → XML
     * For any unrecognized text file (heuristic: attempt to read first 512 bytes as UTF-8) create a Temporary language bucket named "Generic-{EXT}" so it is not ignored.
     * Provide at least 1–3 representative relative file paths per language (prioritize files under src/ then tests/ then root).
   - Build an internal technology inventory map (languages → extensions → representative files → patterns).
   - Output the mapping as JSON structure for later steps (keys: Language, Extensions[], RepresentativeFiles[], InstructionFilesPresent(bool)).

   Language mapping MUST precede content generation so missing instruction files can be created deterministically.

3. **Content Categorization Planning** - For each discovered item, determine placement:

  **Enterprise Instructions** (highest-level, automation-managed, `$EnterpriseInstructionsPath/`, OPTIONAL):
  - Purpose: Hold only guidance truly universal across multiple organizations / repositories and multiple languages & tools.
  - File: `$EnterpriseInstructionsPath/main.instructions.md` consolidates ONLY cross-enterprise universal rules (if enterprise layer exists).
  - Language folders: Same pattern as organization if enterprise-level language-specific nuances are required (rare). Prefer promoting only when identical patterns appear in all organizations.

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
   - If pattern applies across all organizations (enterprise scope) → Enterprise
   - If pattern is specific to this repository → Repository
   - When uncertain, default to Repository (can promote to Organization later)
   - Organization content must be generic enough for automation management
   - Enterprise content must be generic enough to apply across disparate organizations and technology stacks; keep extremely small & strictly universal.
   - Every discovered language (from language mapping) MUST have at minimum:
     * Organization-level `{Language}/main.instructions.md` (unless intentionally excluded via an explicit ExclusionList provided by user input)
     * Repository-level `{Language}/main.instructions.md`
     * Enterprise-level `{Language}/main.instructions.md` ONLY if (a) enterprise path exists AND (b) language rules are materially identical across all organizations or explicitly flagged for enterprise promotion.
   - If a discovered language lacks an instructions file, AUTO-GENERATE it using the minimal language template (do not wait for user confirmation).
   - Provide specialized treatment rules:
     * PowerShell XML metadata (.ps1xml) falls under XML, but if PowerShell instructions exist, do NOT duplicate cross-language rules—only add a short XML-specific file focusing on formatting & schema constraints.
     * Markdown instructions emphasize documentation style & fenced code consistency.
     * YAML instructions emphasize indentation (2 spaces), key ordering (stable where meaningful), and workflow file conventions.
     * JSON instructions emphasize trailing comma prohibition, stable property ordering (if project mandates), and schema references if any.
   - Include an automatically managed `languages.instructions.md` summary file at BOTH organization and repository instruction roots describing the discovered mapping (regenerate each run). Frontmatter for these summary files:
     ---
     description: "Auto-generated language mapping summary"
     applyTo: "**/*"
     ---
     (No additional keys; file is overwritten each generation.)

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

3.1 **Cross-Level Normalization & Promotion (Enterprise ↔ Organization ↔ Repository)**

   BEFORE generating or updating instruction file contents for steps 4–9, perform a consolidation analysis:

   - **Discovery Inputs**: Use language mapping + existing instruction files at all three levels (enterprise if present, organization, repository).
   - **Similarity Detection**: For each language and for the universal `main.instructions.md` files:
     * Compute a simple normalized content fingerprint (e.g., lowercase, strip whitespace & code blocks) to detect near-duplicates (>=80% similarity) across levels.
     * Identify sections (by heading + first sentence) that appear verbatim or with only repository-specific nouns changed.
   - **Promotion Rules**:
     * If the same rule text (or semantically identical after removing repository-specific identifiers) appears in ≥ 90% of repository-level language instruction files, promote that rule to the organization-level language file; remove duplicates from repository files and leave an inline note referencing organization rule.
     * If the same organization-level universal rule appears unchanged across all organizations (detected via enterprise layer presence & markers) AND enterprise path exists, promote to enterprise `main.instructions.md`; leave minimal reference lines in organization file (e.g., "(Inherited from enterprise universal guidelines)").
     * When promoting, ensure frontmatter of target file already conforms; append promoted rule under the correct section (create section if absent) maintaining concise ordering (prefer alphabetical section ordering: Style, Patterns, Error Handling, Testing, Performance, Documentation, Integration, Forbidden).
   - **Demotion Rule**: If an organization-level rule is only referenced by a single repository and is repository-specific, move it down to that repository's file and replace with a note in organization file referencing repository-level specialization.
   - **Conflict Handling**: If two repositories implement the same rule with conflicting specifics (e.g., indentation 2 vs 4 spaces) do NOT promote; flag in report under "Manual Review Needed".
   - **Tool / Language Agnostic Rules**: Rules that do not reference a specific language, framework, directory, or file extension should live in the highest applicable level (`enterprise` if present, else `organization`).
   - **Action Outcomes**: Record each promotion/demotion decision (source path, destination path, rule heading) in an internal change log used later in the completion report.
   - **No Physical Moves Yet**: This step defines intended content relocation. Actual file edits occur in subsequent generation steps; ensure idempotency by basing decisions on current state + deterministic fingerprinting.

4. **Generate Organization (and Enterprise) Instructions** - For each discovered language/technology:

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
  - For each additional discovered language (e.g., XML, Markdown, YAML, JSON) create a FOLDER named exactly the language and place `main.instructions.md` inside it instead of using a language-prefixed filename.
    * Example: `$OrganizationInstructionsPath/XML/main.instructions.md`
    * Example: `$OrganizationInstructionsPath/Markdown/main.instructions.md`
    * Example: `$OrganizationInstructionsPath/YAML/main.instructions.md`
    * Example: `$OrganizationInstructionsPath/JSON/main.instructions.md`
  - These language folders follow the same unified frontmatter rules (only description + applyTo) and MUST NOT introduce files named like `xml.main.instructions.md` (language prefix before file) — enforce folder + `main.instructions.md` pattern only.
  - XML instructions: focus on structure, indentation (2 spaces unless existing convention differs), schema/element ordering, and PowerShell formatting view constraints (`.ps1xml`).
  - Markdown instructions: heading hierarchy limits, fenced code block language tags, link formatting, parameter doc examples.
  - YAML instructions: 2-space indentation, key ordering/stability policy, anchors/aliases usage policy, GitHub Actions workflow naming & required top-level keys.
  - JSON instructions: no trailing commas, stable property ordering rules (if any), number formatting, schema reference/validation guidance, camelCase vs PascalCase conventions.

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
  - Auto-generate missing language instruction files for every language in the mapping even if currently unused for logic (e.g., only one file present) to prevent future drift.
  - Where languages are configuration-only (Markdown / YAML / JSON / XML), tailor repository instructions to project-specific conventions (e.g., GitHub Actions workflow naming, documentation heading depth limits, JSON property ordering expectations, XML view schema constraints).

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

  - **Cross-Level Consolidation Validation**:
    * Every promoted rule MUST have been removed from its original lower-level location (except for a short reference line) to prevent duplication.
    * No rule content (post-normalization) appears identically in more than one level unless intentionally overridden (override must include an explicit "Override:" prefix in the repository-level rule heading).
    * Demotions are reflected only in the target repository file and removed from organization/enterprise scope.
    * Enterprise file (if present) contains only universally applicable guidance (no directory or repository-specific references).

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
     * Each discovered language from mapping has both organization and repository instruction files (unless explicitly excluded and exclusion is listed in report)
     * `languages.instructions.md` exists at both organization and repository instruction roots and reflects current mapping hash (recompute & compare)

  If validation fails, report specific issues and DO NOT proceed to cleanup. Include a subsection "Consolidation Issues" listing any promotion/demotion anomalies (duplicate still present, orphaned reference, conflicting style rule, unresolved conflict flagged for manual review).

7.1 **Post-Generation Promotion Sweep (Default Elevation)**

  AFTER an initial successful validation (Step 7) but BEFORE cleanup:

  - **Objective**: Detect newly uniform rules introduced or normalized during generation/migration that now qualify for elevation to higher levels (repository → organization → enterprise).
  - **Scope**: Evaluate both language-specific and universal (`main.instructions.md`) files.
  - **Process**:
    1. Recompute normalized fingerprints (same normalization as Step 3.1) for each rule section across all repository-level files per language.
    2. Identify rule blocks that:
      * Appear identically (≥ 90% normalized similarity) in ≥ Threshold repositories (default Threshold = 100% of repositories for that language unless fewer than 3 repositories exist; then require all) → Candidate for organization-level promotion.
      * Appear identically in all organization-level language files (multi-org scenario with enterprise layer present) → Candidate for enterprise-level promotion.
    3. For candidates already present at higher level but partially diverged (minor wording differences ≤ 10% edit distance), unify by choosing the most specific variant that does NOT reference repository-specific paths; record the chosen canonical text.
    4. Insert (or update) promoted rule in higher-level file under correct section ordering. Remove full content from lower levels, leaving a single reference line:
      `(Inherited from organization guidelines: <Section Heading>)` or `(Inherited from enterprise guidelines: <Section Heading>)`.
    5. Mark overrides explicitly: If a repository needs to differ, prefix the section heading with `Override:` and retain full content (do NOT delete). Overrides are excluded from promotion.
    6. Append promotion actions to consolidation change log (source, destination, rule heading, action = Promote/Skip/Override) for final reporting.
    7. Re-run Validation (Step 7 structural + cross-level checks) to ensure no duplication remains post-promotion.
  - **Conflict Handling**: If two candidate blocks differ on a measurable parameter (e.g., indentation 2 vs 4) treat as conflict; DO NOT promote—flag under "Manual Review Needed".
  - **Idempotency**: A no-op if no additional promotions qualify.
  - **Failure Mode**: If re-validation fails after promotions, revert the last batch of promotions (retain change log entries marked Reverted) and report issues; skip cleanup.

  Proceed to Cleanup (Step 8) only after successful re-validation.

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
 - Language Mapping:
   | Language | Extensions | Representative Files | Org File | Repo File | Notes |
   |----------|-----------|----------------------|----------|-----------|-------|
   (Populate rows for each language; Notes column flags missing coverage or exclusions.)
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
 - Confirm excluded languages (if any) are intentional; add them to a persisted ExclusionList if recurring
 - Adjust auto-generated language instruction stubs with richer examples where beneficial
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
