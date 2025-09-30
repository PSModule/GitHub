---
description: "Auto-generated language mapping summary"
applyTo: "**/*"
---

## Discovered Language Mapping (Project View)

```json
{
  "Languages": [
    {"Language": "PowerShell", "Extensions": ["ps1","psd1","psm1"], "RepresentativeFiles": ["src/functions/public/Repositories/Get-GitHubRepository.ps1","src/manifest.psd1","tests/Repositories.Tests.ps1"], "InstructionFilesPresent": true},
    {"Language": "YAML", "Extensions": ["yml","yaml"], "RepresentativeFiles": [".github/workflows/Linter.yml",".github/dependabot.yml"], "InstructionFilesPresent": true},
    {"Language": "Markdown", "Extensions": ["md"], "RepresentativeFiles": ["README.md","CodingStandard.md"], "InstructionFilesPresent": true},
    {"Language": "JSON", "Extensions": ["json"], "RepresentativeFiles": [".github/linters/.jscpd.json"], "InstructionFilesPresent": true},
    {"Language": "XML", "Extensions": ["ps1xml","xml"], "RepresentativeFiles": ["src/formats/GitHubRepository.Format.ps1xml"], "InstructionFilesPresent": true},
    {"Language": "GitAttributes", "Extensions": ["gitattributes"], "RepresentativeFiles": [".gitattributes"], "InstructionFilesPresent": true},
    {"Language": "GitIgnore", "Extensions": ["gitignore"], "RepresentativeFiles": [".gitignore"], "InstructionFilesPresent": true}
  ]
}
```

| Language | Repo-Specific Notes |
|----------|---------------------|
| PowerShell | Context + public/private function split is enforced (see PowerShell repository instructions). |
| YAML | Workflows must call PowerShell scripts instead of large inline `run` blocks. |
| Markdown | Include runnable examples; prefer PowerShell fenced blocks. |
| JSON | Only tooling configs currently; keep minimal & documented. |
| XML | Only format/types metadata; add new types when introducing new classes. |
| GitAttributes | Ensure LF normalization for cross-platform contributors. |
| GitIgnore | Keep patterns tight; review when adding tooling. |
