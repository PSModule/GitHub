# GitHub Powershell Module

# GitHub PowerShell

The **GitHub PowerShell** module serves as a convenient API wrapper around [GitHub's REST API](https://docs.github.com/en/rest), making the functionalities and data available on GitHub accessible through PowerShell commands. This module is tailored for developers, administrators, and GitHub enthusiasts who are familiar with PowerShell and want to integrate or manage their GitHub repositories seamlessly.

**GitHub PowerShell** is built with the community in mind and targets individuals who prefer script-based solutions and want to automate various tasks on GitHub without resorting to a full-fledged development approach.

## Features & Benefits of GitHub PowerShell:

- **Comprehensive Access**: Harness the power of GitHub's REST API from your PowerShell console, providing you with capabilities to manage repositories, issues, pull requests, and more.

- **Support for PowerShell Versions**: This module is tested and compatible with both PowerShell 7 and Windows PowerShell 5.1 ensuring wide accessibility.

- **Cross-Platform**: Whether you're on Windows, macOS, or Linux, GitHub PowerShell has you covered.

- **Modern Authentication**: Integrate seamlessly with GitHub's authentication methods, including personal access tokens and OAuth, for secure script execution.

- **Active Development and Community Support**: As with the open-source spirit of GitHub, this module invites contributors for constant improvement and evolution. Regular updates ensure that the module remains in sync with any changes to the GitHub REST API.

- **Intuitive Command Design**: Commands are structured logically, ensuring that even new users can get started quickly without a steep learning curve.

## Getting Started with GitHub PowerShell

To dive into the world of GitHub automation with PowerShell, follow these steps:

1. **Installation**: Download and install the GitHub PowerShell module from the provided link or the PowerShell Gallery.

    ```powershell
    Install-Module -Name GitHub -Force -AllowClobber
    ```

1. **Authentication**: Authenticate using your GitHub credentials or access tokens to begin executing commands.

Logging in using device flow:
```powershell
Connect-GitHubAccount

Please visit: https://github.com/login/device
and enter code: ABCD-1234
Successfully authenticated!
```

Logging in using PAT token:
```powershell
>_ Connect-GitHubAccount -AccessToken 'ghp_abcdefghklmnopqrstuvwxyz123456789123'
>_
```

2. **Command Exploration**: Familiarize yourself with the available cmdlets using the module's comprehensive documentation or inline help.

    ```powershell
    Get-Command -Module GitHub
    ```

3. **Sample Scripts**: Check out sample scripts and usage patterns to jumpstart your automation tasks on GitHub.

## More Information & Resources

- If you're new to PowerShell or GitHub's REST API, consider checking out the provided beginner guides for both.

- Explore detailed cmdlet documentation, tutorials, and community-contributed scripts to enhance your GitHub PowerShell experience.

- Join the community discussions, provide feedback, or contribute to the module's development on the repository's issues and pull requests sections.

Embrace the efficiency and power of scripting with **GitHub PowerShell** – Your gateway to GitHub automation and integration.

## PowerShell Module Development and Release Framework

We utilize the **[PSModule framework](https://github.com/PSModule/)** to streamline our module development and release process.

- **New-Module**: Quickly set up a consistent module structure that fits with the framework.
- **Build-Module**: Construct the project for deployment to the [PowerShell Gallery](https://www.powershellgallery.com/) and publish documentation for [GitHub Pages](https://pages.github.com/).
- **Test-Module**: Run comprehensive tests ensuring module quality.
- **Release-Module**: Handle versioning, create repository releases, and publish to the PowerShell Gallery and GitHub Pages.

For a detailed understanding of the framework, [read more about PSModule here](https://github.com/PSModule/).

## References

### Official GitHub Resources:
- [REST API Description](https://github.com/github/rest-api-description)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub Platform Samples](https://github.com/github/platform-samples)

### General Web References:
- [Generic HTTP Status Codes (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

### Tools Planned for Development:
- [Microsoft.PowerShell.SecretManagement](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules)
- [Azure AutoRest (OpenAPI Specification Code Generator)](https://github.com/Azure/autorest)

### Inspiration Behind the Project:
- [Microsoft's PowerShellForGitHub](https://github.com/microsoft/PowerShellForGitHub)
- [PSGitHub by pcgeek86](https://github.com/pcgeek86/PSGitHub)
- [PSSodium by TylerLeonhardt](https://github.com/TylerLeonhardt/PSSodium)
- [libsodium NuGet Package](https://www.nuget.org/packages/Sodium.Core/)

### Authentication and Login:
- [SecretManagement and SecretStore Overview](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules)
- [PowerShell for GitHub on GitHub Marketplace](https://github.com/apps/powershell-for-github)
- [Building a CLI with a GitHub App](https://docs.github.com/en/apps/creating-github-apps/writing-code-for-a-github-app/building-a-cli-with-a-github-app)

### Module Configuration and Environment:
- [GH Environment for GitHub CLI](https://cli.github.com/manual/gh_help_environment)
