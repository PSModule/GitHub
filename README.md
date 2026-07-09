# GitHub PowerShell

The module provides a PowerShell-flavored approach to managing and automating your GitHub environments. It's tailored for developers, administrators,
and GitHub enthusiasts who want to use PowerShell to integrate or manage GitHub seamlessly.

## Supported use-cases

- **Operate any GitHub environment**
  As an operator of any type of GitHub environment, you can use this module to automate your workflows and tasks. The module supports connecting
  with multiple accounts; be that GitHub (public, github.com), GitHub Enterprise Cloud (GHEC, including GHE.com) and GitHub Enterprise Server (GHES).
- **A great GitHub Action Workflow companion**
  The module is built to be a companion in GitHub Actions. It comes with PowerShell-flavored
  [workflow-commands](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions) and
  is [context aware](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs).
  So it detects how it is being used and loads available information dynamically. You can provide it the `GITHUB_TOKEN`, a client ID and private key
  for a GitHub App, or a user access token (fine-grained or classic). In addition to be a great local scripting companion, it also understands when
  its run in GitHub Actions where it will automatically detect the event that triggered the workflow and provide the necessary context to commands. So
  if you want to comment on the PR that triggered the workflow, that is the default it will use when writing a comment to the PR.
  Use the [`GitHub-Script`](https://github.com/PSModule/GitHub-Script) action to get started. You can also use it in you own composite actions by
  either using the [`GitHub-Script`](https://github.com/PSModule/GitHub-Script) action or by installing the module.
- **Automate GitHub**
  The module works quite nicly in other automation too. If you want to build a bot that interacts with GitHub using Azure Function App the module
  can easily be installed and used to automate tasks. It can also be used in scheduled tasks, CI/CD pipelines, and other automation scenarios.

## Supported platforms

As the module is built with the goal to support modern operators (assumed to use a newer OS), GitHub Actions and FunctionApps, the module
will **only support the latest LTS version of PowerShell on Windows, macOS, and Linux**.

## Getting Started with GitHub PowerShell

To dive into the world of GitHub automation with PowerShell, follow the sections below.

### Installing the module

Download and install the GitHub PowerShell module from the PowerShell Gallery with the following command:

```powershell
Install-PSResource -Name GitHub -Repository PSGallery -TrustRepository
```

### Logging on

Authenticate with `Connect-GitHubAccount`. The recommended method is an interactive browser sign-in backed by a GitHub App, with short-lived tokens that refresh automatically:

```powershell
Connect-GitHubAccount
```

The module supports many methods: OAuth apps, personal access tokens (classic and fine-grained), GitHub Apps (client ID and private key or an Azure Key Vault key), automatic use of `GH_TOKEN`/`GITHUB_TOKEN` in GitHub Actions, and GitHub Enterprise Server or data-residency hosts via `-Host`. See the full [Authentication guide](https://psmodule.io/GitHub/Functions/Auth/Auth/) for every method, Key Vault setup, custom apps, and automatic token renewal.

## Documentation

Every command ships with full reference documentation, generated from its comment-based help and published at [psmodule.io/GitHub](https://psmodule.io/GitHub/). Explore the commands and read detailed help directly from PowerShell:

```powershell
Get-Command -Module GitHub
Get-Help -Name Get-GitHubRepository -Examples
```

## References

### Official GitHub Resources

- [REST API Description](https://github.com/github/rest-api-description)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub Platform Samples](https://github.com/github/platform-samples)
- [Octokit](https://github.com/octokit) [rest.js API docs](https://octokit.github.io/rest.js/v20) - GitHub API clients for different languages.
- [actions/toolkit](https://github.com/actions/toolkit) - GitHub Actions Toolkit for JavaScript and TypeScript.
- [actions/github-script](https://github.com/actions/github-script) - GitHub Action for running ts/js octokit scripts.

### General Web References

- [Generic HTTP Status Codes (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

### Alternative GitHub PowerShell Modules

- [Microsoft's PowerShellForGitHub](https://github.com/microsoft/PowerShellForGitHub)
- [PSGitHub by pcgeek86](https://github.com/pcgeek86/PSGitHub)
- [GitHubActions by ebekker](https://github.com/ebekker/pwsh-github-action-tools)
- [powershell-devops by smokedlinq](https://github.com/smokedlinq/powershell-devops)
- [GitHubActionsToolkit by hugoalh-studio](https://github.com/hugoalh-studio/ghactions-toolkit-powershell)
