---
description: "Auto-generated language mapping summary"
applyTo: "**/*"
---

## Discovered Language Mapping

JSON structure (authoritative for automation):
```json
{
  "Languages": [
    {
      "Language": "PowerShell",
      "Extensions": ["ps1", "psd1", "psm1"],
      "RepresentativeFiles": [
        "src/functions/public/Repositories/Get-GitHubRepository.ps1",
        "src/manifest.psd1",
        "tests/Repositories.Tests.ps1"
      ],
      "InstructionFilesPresent": true
    },
    {
      "Language": "YAML",
      "Extensions": ["yml", "yaml"],
      "RepresentativeFiles": [
        ".github/workflows/Linter.yml",
        ".github/dependabot.yml"
      ],
      "InstructionFilesPresent": true
    },
    {
      "Language": "Markdown",
      "Extensions": ["md"],
      "RepresentativeFiles": [
        "README.md",
        "CodingStandard.md",
        "tests/README.md"
      ],
      "InstructionFilesPresent": true
    },
    {
      "Language": "JSON",
      "Extensions": ["json"],
      "RepresentativeFiles": [
        ".github/linters/.jscpd.json"
      ],
      "InstructionFilesPresent": true
    },
    {
      "Language": "XML",
      "Extensions": ["ps1xml", "xml"],
      "RepresentativeFiles": [
        "src/formats/GitHubRepository.Format.ps1xml",
        "src/types/GitHubRepository.Types.ps1xml"
      ],
      "InstructionFilesPresent": true
    },
    {
      "Language": "GitAttributes",
      "Extensions": ["gitattributes"],
      "RepresentativeFiles": [
        ".gitattributes"
      ],
      "InstructionFilesPresent": true
    },
    {
      "Language": "GitIgnore",
      "Extensions": ["gitignore"],
      "RepresentativeFiles": [
        ".gitignore"
      ],
      "InstructionFilesPresent": true
    }
  ]
}
```

| Language      | Extensions                     | Representative Files (subset)                                   | Org File | Repo File | Notes |
|---------------|--------------------------------|------------------------------------------------------------------|---------|----------|-------|
| PowerShell    | ps1, psd1, psm1                | src/functions/public/Repositories/Get-GitHubRepository.ps1      | Yes     | Yes      | Includes tests & manifest |
| YAML          | yml, yaml                      | .github/workflows/Linter.yml                                     | Yes     | Yes      | Workflows + dependabot |
| Markdown      | md                             | README.md                                                        | Yes     | Yes      | Docs & tests README |
| JSON          | json                           | .github/linters/.jscpd.json                                      | Yes     | Yes      | Tooling config |
| XML           | ps1xml, xml                    | src/formats/GitHubRepository.Format.ps1xml                       | Yes     | Yes      | PowerShell metadata |
| GitAttributes | gitattributes                  | .gitattributes                                                   | Yes     | Yes      | Text normalization rules |
| GitIgnore     | gitignore                      | .gitignore                                                       | Yes     | Yes      | Ignore patterns |

All discovered textual extensions have instruction coverage. Binary/image assets intentionally excluded from mapping.
