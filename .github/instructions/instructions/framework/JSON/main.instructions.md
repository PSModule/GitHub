---
applyTo: '**/*.json'
description: Framework-level JSON patterns for configuration, tooling, and data assets.
---

# Framework JSON Guidelines

JSON files underpin tooling configs, API payloads, and data artifacts across PSModule repositories; these rules keep them consistent and machine-friendly.

## Goal
- Define formatting, structure, and validation expectations so JSON remains deterministic and easy to consume across platforms.
- Prevent accidental drift in schema usage, sensitive value handling, or tooling integration.

## Execution Steps
1. Format the document with two-space indentation, UTF-8 + LF endings, and double-quoted strings.
2. Group related keys logically and confirm casing consistency (camelCase, PascalCase, or snake_case per schema).
3. Attach schema references or validation commands when available and run them as part of your change.
4. Review arrays/objects for unnecessary nesting and ensure null handling matches consumer expectations.
5. For configuration files, document non-default overrides and keep companion README entries synchronized.

## Behavior Rules
- **Formatting**
	- Enforce two-space indentation, single trailing newline, and no trailing whitespace; limit lines to ≤ 150 characters when feasible.
- **Structure**
	- Use meaningful keys, keep related keys adjacent, and avoid deep hierarchies without value.
	- Represent collections with arrays and maintain consistent ordering when order matters to tooling.
- **Configuration & Tooling**
	- Reference schemas (e.g., via `$schema`) or document validators; align naming conventions across similar configs.
	- Capture linter/tool overrides explicitly and document the rationale.
- **Data Files**
	- Include version metadata when datasets evolve, maintain type consistency, and treat `null` explicitly.
	- Consider file size—compress or split data when large payloads degrade performance.
- **Security**
	- Exclude secrets and personal data; rely on environment variables or vault abstractions instead.
	- Guard against injection by encoding untrusted input before serialization.
- **Integration**
	- Ensure CI/CD automation can parse the file; provide fallback behavior when keys are optional or new.
	- Maintain backward compatibility unless a breaking change is intentional and documented.

## Output Format
- JSON artifacts must validate against their schema (when provided), parse with standard libraries, and present deterministic key ordering if consumed by version control comparisons.
- Configuration changes should update related documentation or changelog entries describing the impact.

## Error Handling
- Treat parse errors or schema violations as blockers; resolve before merging.
- Document any temporary schema gaps in repo instructions and plan remediation.

## Definitions
| Term | Description |
| --- | --- |
| **Schema** | JSON Schema or similar definition that constrains permitted structure and values. |
| **Deterministic ordering** | Stable ordering of keys/arrays to minimize differences between runs or environments. |
| **Injection** | Malicious or accidental insertion of executable content via improperly sanitized JSON fields. |
