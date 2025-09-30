---
applyTo:
	- '**/*.yml'
	- '**/*.yaml'
description: Framework-level YAML practices for shared configuration components.
---

# Framework YAML Guidelines

This file complements the top-level YAML guidance with patterns for generic configuration files that aren’t specific to workflows or composite actions.

## Goal
- Keep YAML configuration readable, validated, and modular across PSModule repositories.
- Ensure environmental integration (local + CI) without duplicating workflow-specific rules.

## Execution Steps
1. Name the file with lowercase hyphenated words reflecting purpose (`mkdocs.yml`, `settings-release.yml`).
2. Format with UTF-8, LF endings, two-space indentation, and a single trailing newline.
3. Organize logical sections with metadata first, then functional blocks separated by a single blank line.
4. Insert schema hints or validation commands if the consuming tool supports them and run the validation.
5. Update accompanying documentation or comments to explain complex settings.

## Behavior Rules
- **Structure & Formatting**
	- Group related keys, avoid excessive nesting, and keep key names descriptive but succinct.
	- Maintain deterministic key ordering to reduce diff churn.
- **Comments & Documentation**
	- Use comments sparingly for non-obvious behavior; format TODOs as `# TODO(owner): summary`.
	- Document default values and overrides near their definitions.
- **Environment Integration**
	- Leverage environment variables or templating features for values that differ between environments.
	- Validate configuration under Windows, Linux, and macOS contexts when applicable.
- **Versioning & Compatibility**
	- Track schema versions or tool version compatibility; note breaking changes in release notes.
	- Prefer additive changes over destructive reorganizations to preserve backward compatibility.
- **Security**
	- Keep secrets out of configuration files; reference secure stores or placeholder tokens.
	- Validate external inputs before interpolation to prevent injection.

## Output Format
- Configuration YAML must parse without warnings in the target tool, and any generated artifacts (site configs, templates) should remain functional.
- Documented defaults and overrides should stay synchronized with README or docs references.

## Error Handling
- Treat schema validation failures or parse exceptions as blockers—resolve before delivery.
- If a third-party tool enforces conflicting formatting, document the exception and scope it narrowly.

## Definitions
| Term | Description |
| --- | --- |
| **Deterministic ordering** | Keeping keys in a consistent order for predictable diffs and tooling consumption. |
| **Schema hint** | Metadata (comment or key) pointing a YAML file to a validation schema. |
