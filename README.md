# GitHub

GitHub is a PowerShell module for interacting with GitHub, both interactively and in automation. It gives operators, administrators, and GitHub Actions authors a PowerShell-flavored way to manage GitHub across GitHub.com, GitHub Enterprise Cloud (GHEC, including GHE.com and data residency), and GitHub Enterprise Server (GHES).

## Highlights

- **Operate any GitHub environment** — connect with multiple accounts and token types across github.com, GHEC, and GHES.
- **A GitHub Actions companion** — context-aware, with PowerShell-flavored [workflow commands](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions). It detects the event that triggered the workflow and supplies the right context to commands automatically. Get started with the [`GitHub-Script`](https://github.com/PSModule/GitHub-Script) action.
- **Automate GitHub anywhere** — bots, Azure Function Apps, scheduled tasks, and other CI/CD pipelines.

## Prerequisites

Supports the latest LTS version of PowerShell on Windows, macOS, and Linux.

## Installation

Install the module from the PowerShell Gallery:

```powershell
Install-PSResource -Name GitHub
Import-Module -Name GitHub
```

## Authentication

Connect with `Connect-GitHubAccount`. The module supports interactive and programmatic authentication and manages short-lived tokens for you.

Interactive (recommended) uses a browser-based device flow backed by a GitHub App. Tokens are short-lived and refreshed automatically:

```powershell
Connect-GitHubAccount
```

Other interactive options use an OAuth app or a personal access token:

```powershell
Connect-GitHubAccount -Mode OAuth        # OAuth app instead of the GitHub App
Connect-GitHubAccount -UseAccessToken    # paste a classic or fine-grained PAT
```

Programmatic authentication covers CI/CD, scheduled tasks, and apps. In GitHub Actions the module automatically uses `GH_TOKEN` or `GITHUB_TOKEN` when present:

```powershell
Connect-GitHubAccount                                              # uses GH_TOKEN / GITHUB_TOKEN when available
Connect-GitHubAccount -ClientID $ClientID -PrivateKey $PrivateKey  # GitHub App; a JWT is generated per call
```

For GitHub Apps, you can keep the private key in Azure Key Vault instead of exposing it in scripts. This requires an existing `az login` or `Connect-AzAccount` session:

```powershell
Connect-GitHubAccount -ClientID $ClientID -KeyVaultKeyReference 'https://my-vault.vault.azure.net/keys/github-app-key'
```

Connect to GitHub Enterprise Server, or to GHEC with data residency, with `-Host` — optionally with your own app's `-ClientID`:

```powershell
Connect-GitHubAccount -Host 'https://github.local'
Connect-GitHubAccount -Host 'https://msx.ghe.com' -ClientID 'lv123456789'
```

The module refreshes GitHub App user access tokens and rotates app JWTs automatically. Long-lived PATs and provided installation tokens (`GH_TOKEN` / `GITHUB_TOKEN`) are used as-is and are not refreshed.

## Usage

Discover the available commands and start managing GitHub:

```powershell
Get-Command -Module GitHub
Get-GitHubRepository -Owner 'PSModule' -Name 'GitHub'
```

## Documentation

Documentation is published at [psmodule.io/GitHub](https://psmodule.io/GitHub/).

Use PowerShell help and command discovery for module details:

```powershell
Get-Command -Module GitHub
Get-Help -Name Get-GitHubRepository -Examples
```

## References

- [REST API Description](https://github.com/github/rest-api-description)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Octokit](https://github.com/octokit) — GitHub API clients for many languages
- [actions/toolkit](https://github.com/actions/toolkit) — GitHub Actions toolkit for JavaScript and TypeScript
