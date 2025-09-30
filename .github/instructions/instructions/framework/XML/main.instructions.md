---
applyTo: '**/*.xml'
description: Framework-level XML patterns for configuration payloads and test outputs.
---

# Framework XML Guidelines

XML remains common for tool configuration and reporting in PSModule repos; these rules ensure the documents remain parseable and cross-platform.

## Goal
- Provide consistent encoding, structure, and schema practices for XML artifacts.
- Keep CI/CD tooling (test runners, coverage reports, deployment manifests) interoperable across environments.

## Execution Steps
1. Start each file with an XML declaration specifying UTF-8 encoding and ensure LF line endings.
2. Organize elements under a single root, following schema or tool conventions for ordering and naming.
3. Apply consistent indentation (2 spaces recommended) and remove trailing whitespace before saving.
4. Validate the document against its schema or DTD where available; capture validation steps in comments or automation.
5. Review namespaces, links, and file paths to confirm they behave on both Windows and Unix runners.

## Behavior Rules
- **Formatting**
	- Use UTF-8 encoding, include `<?xml version="1.0" encoding="utf-8"?>`, and end the file with a single newline.
	- Maintain two-space indentation (unless a consuming tool enforces four) and keep lines ≤ 150 characters.
- **Structure**
	- Choose meaningful element/attribute names, maintain consistent casing, and avoid unnecessary nesting.
	- For configuration files, place metadata (version, description) near the top and group functional sections logically.
- **Test & Report Files**
	- Follow standard formats (JUnit, JaCoCo, Pester NUnit) including timestamps, durations, and failure details.
	- Preserve ordering of suites/cases when consumers rely on deterministic layouts.
- **Configuration Files**
	- Comment complex sections, provide sensible defaults, and validate with schemas or XSDs when supplied.
	- Keep cross-platform paths normalized (forward slashes) and document platform-specific requirements.
- **Security**
	- Disable or avoid external entities (XXE) unless explicitly required and vetted.
	- Escape special characters properly and sanitize untrusted input before serialization.
- **Integration**
	- Ensure files load in standard processors (System.Xml, xmllint) and surface informative errors if parsing fails.
	- Maintain backward compatibility or note breaking changes in release notes when altering structure.

## Output Format
- XML artifacts should validate successfully, open in standard viewers without warnings, and align with the consuming tool's expectations (e.g., GitHub integration, Azure DevOps reports).
- Test outputs must include full failure context (message, stack trace) for troubleshooting.

## Error Handling
- Treat validation or parsing failures as blockers; fix structure or schema references before merge.
- Document exceptions (e.g., third-party schema bugs) in repo instructions and plan remediation.

## Definitions
| Term | Description |
| --- | --- |
| **XML declaration** | First line specifying version and encoding (e.g., `<?xml version="1.0" encoding="utf-8"?>`). |
| **XXE** | XML External Entity processing; potential security vulnerability when untrusted entities are loaded. |
| **JUnit format** | Widely used XML schema for test results consumed by CI dashboards. |
