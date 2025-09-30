---
applyTo: '**/classes/**/*.{ps1,psm1}'
description: Framework-level PowerShell class patterns and object-oriented design expectations.
---

# Framework PowerShell Classes Guidelines

Use this guidance when authoring or updating PowerShell classes that back PSModule modules, formatters, or API abstractions.

## Goal
- Encourage consistent, maintainable class implementations that align with PSModule’s single-responsibility philosophy.
- Provide reusable patterns for constructors, serialization helpers, and GitHub-centric models.

## Execution Steps
1. Determine the class’s responsibility and ensure it models a single concept (data or behavior cluster).
2. Pick PascalCase names for the class and public members, avoiding abbreviations.
3. Sketch constructors, property defaults, and helper methods, referencing the template below.
4. Implement serialization (`ToHashtable`, `FromHashtable`) and pipeline-friendly output as needed.
5. Add comment-based help (or XML documentation if required), run tests, and verify usage across modules.

## Behavior Rules
- **Design Principles**
	- Adhere to single responsibility, keep method names descriptive, and mark internal-only members as `hidden`.
- **Template Reference**
	- Base new classes on this structure:

```powershell
class ObjectName {
	[string] $Property1
	[int] $Property2
	hidden [datetime] $CreatedAt

	ObjectName([string] $property1, [int] $property2) {
		$this.Property1 = $property1
		$this.Property2 = $property2
		$this.CreatedAt = [datetime]::UtcNow
	}

	ObjectName() {
		$this.CreatedAt = [datetime]::UtcNow
	}

	[string] ToString() {
		"$($this.Property1): $($this.Property2)"
	}

	[hashtable] ToHashtable() {
		@{
			Property1 = $this.Property1
			Property2 = $this.Property2
			CreatedAt = $this.CreatedAt
		}
	}

	static [ObjectName] FromHashtable([hashtable] $data) {
		$obj = [ObjectName]::new()
		$obj.Property1 = $data.Property1
		$obj.Property2 = $data.Property2
		if ($data.ContainsKey('CreatedAt')) {
			$obj.CreatedAt = $data.CreatedAt
		}
		return $obj
	}
}
```
- **Properties & Constructors**
	- Choose precise .NET types, set defaults in constructors, and validate input parameters.
	- Offer overloads or factory methods when callers may supply different shapes of data.
- **Methods & Serialization**
	- Implement `ToString()` for debugging and `ToHashtable()`/`FromHashtable()` for serialization.
	- Handle circular references carefully; prefer IDs or summaries over nesting entire objects.
- **Inheritance & Interfaces**
	- Prefer composition; when inheriting, document base-class expectations and override virtual members deliberately.
	- Implement interfaces for shared behavior across modules (e.g., `IJsonSerializable`).
- **Error Handling**
	- Throw meaningful exceptions on invalid state, guard property assignments, and keep messages actionable.
- **GitHub Integration**
	- When modeling GitHub API objects, store raw payloads or metadata as hidden properties and expose pipeline-friendly data.
	- Surface helper methods that wrap common API operations while respecting authentication context.

## Output Format
- Classes must compile on Windows PowerShell 5.1 and PowerShell 7+, integrate into modules without export conflicts, and be covered by targeted tests.
- Serialization helpers should round-trip sample payloads used in documentation or unit tests.

## Error Handling
- Treat validation failures or inconsistent serialization as blocking; update tests and constructors to enforce invariants.
- Document temporary exceptions (e.g., incomplete API fields) via TODO comments with linked issues.

## Definitions
| Term | Description |
| --- | --- |
| **Single responsibility** | Design principle where a class addresses one cohesive concern, simplifying maintenance. |
| **Hidden property** | PowerShell class member marked `hidden` to restrict exposure while keeping data accessible internally. |
| **Round-trip** | Ability for serialization/deserialization helpers to return an equivalent object without data loss. |
