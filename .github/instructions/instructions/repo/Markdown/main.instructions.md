---
applyTo: '**/*.md'
description: Markdown standards specific to the PSModule documentation site and sample content.
---

# Repository Markdown Guidelines

These rules extend the framework Markdown guidance with MkDocs-specific navigation, PSModule voice, and example requirements.

## Goal
- Keep documentation pages, blog posts, and READMEs consistent with PSModule brand and site structure.
- Ensure examples remain executable against current modules and workflows.

## Execution Steps
1. Confirm the document’s placement in the MkDocs navigation and update `mkdocs.yml` if structure changes.
2. Start the page with a descriptive H1, then follow the heading hierarchy established for the site section.
3. Embed runnable examples (PowerShell or YAML) using fenced code blocks with language annotations.
4. Add cross-links to relevant PSModule modules, actions, or dictionary entries using relative references defined in `includes/links.md`.
5. Run `mkdocs serve` (or build) locally to verify navigation, formatting, and link integrity.

## Behavior Rules
- **Document Structure**
	- Provide a table of contents when sections exceed three H2 headings.
	- Close with related links, references, or next steps to support discoverability.
- **README Standards**
	- Summarize purpose, installation, usage, contribution, and license; keep them aligned with module repositories.
- **Code Blocks & Samples**
	- Use ```powershell, ```yaml, or appropriate language hints; show inputs and expected outputs when relevant.
	- Prefer examples that authenticate via PSModule helpers or demonstrate GitHub Actions integration.
- **Linking**
	- Use descriptive link text, relative paths for internal content, and shared link definitions from `includes/links.md` when possible.
- **Formatting**
	- Bold key terms sparingly, use inline code for commands/filenames, blockquotes for callouts, and tables for structured data.
- **Integration**
	- Align content with MkDocs metadata/frontmatter conventions and ensure navigation breadcrumbs remain accurate.
- **Examples & Scenarios**
	- Cover common use cases, include error-handling guidance, and highlight PSModule best practices.

## Output Format
- Markdown pages must render cleanly in MkDocs, appear in navigation, and reference any updated assets (images, includes).
- Example code should be copy/paste ready and validated against current module versions.

## Error Handling
- Treat broken links, missing includes, or failing MkDocs builds as blocking issues.
- Document temporary discrepancies (e.g., pending module release) with visible callouts and follow-up tasks.

## Definitions
| Term | Description |
| --- | --- |
| **MkDocs navigation** | Menu structure defined in `mkdocs.yml` that controls page placement. |
| **Dictionary entries** | Shared glossary pages under `docs/Dictionary/` referenced throughout the site. |
