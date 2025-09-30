---
applyTo: '**/*.md'
description: Framework-level Markdown patterns for all PSModule documentation.
---

# Framework Markdown Guidelines

PSModule documentation must stay readable in raw form, render cleanly in MkDocs and GitHub, and remain easy to diff—these rules secure that baseline.

## Goal
- Provide cross-repository Markdown conventions that keep tone, structure, and tooling compatibility aligned.
- Minimize churn in diffs by prescribing consistent heading usage, spacing, and fenced code presentation.

## Execution Steps
1. Check whether the page needs YAML frontmatter; add only when navigation or metadata requires it.
2. Draft content following the heading hierarchy (single H1, sequential levels) and paragraph guidance.
3. Format lists, code blocks, and tables using the rules below; ensure examples are copy-ready.
4. Validate links (prefer relative paths) and confirm the document builds under MkDocs without warnings.
5. Run Markdown linting (where available) or manually spot-check for spacing, line endings, and language tone.

## Behavior Rules
- **Universal Standards**
	- Encode as UTF-8 with LF endings, strip trailing whitespace, end with a single newline, and keep lines ≤ 150 characters when practical.
- **Front Matter**
	- Include YAML front matter only when required by the build; limit keys to essentials (`title`, `description`, overrides).
	- Place front matter at the top with no preceding blank lines.
- **Headings & Structure**
	- Use exactly one H1 immediately after front matter.
	- Step through heading levels sequentially and avoid terminal punctuation in heading text.
- **Paragraphs & Line Handling**
	- Keep paragraphs as single logical lines; avoid arbitrary hard wraps except for clarity improvements.
	- Don't hard-wrap inside code fences or tables; insert blank lines between paragraphs and lists as needed.
- **Lists**
	- Prefer `*` for unordered items with two-space indentation for nested content.
	- Leave a blank line before/after lists unless the list follows a heading directly.
- **Code Blocks**
	- Always specify a fence language; use `powershell` for module examples, avoid `PS>` prompts, and trim to essential lines.
	- Use inline backticks for commands or filenames.
- **Links & References**
	- Use descriptive link text, relative paths for internal references, and reference-style links for reusable URLs.
- **Cross-Platform & Integration**
	- Show forward-slash paths and note OS-specific nuances where needed.
	- Ensure documents remain compatible with MkDocs, search indexing, and PSModule documentation navigation.
- **Style Consistency**
	- Maintain consistent voice, terminology, and formatting choices across documents.

## Output Format
- Markdown files should preview cleanly in MkDocs and GitHub, include working code samples, and respect the prescribed heading/list formatting.
- Navigation metadata (front matter, `mkdocs.yml`) must stay synchronized with document titles and hierarchy.

## Error Handling
- When tooling or legacy pages prevent full compliance, document the exception inline and create a follow-up task to remediate.
- Treat broken links, malformed tables, or fenced code without language hints as blocking issues.

## Definitions
| Term | Description |
| --- | --- |
| **MkDocs** | Static site generator used for PSModule documentation sites. |
| **Front matter** | Optional YAML metadata block at the top of a Markdown file controlling navigation or page settings. |
| **Reference-style link** | Markdown pattern that separates link usage from URL definition to encourage reuse (`[text][ref]` and `[ref]: url`). |
