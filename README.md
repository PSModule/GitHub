# GitHub PowerShell

The **GitHub PowerShell** module serves as a convenient API wrapper around [GitHub's REST API](https://docs.github.com/en/rest), making the functionalities and data available on GitHub accessible through PowerShell commands. This module is tailored for developers, administrators, and GitHub enthusiasts who are familiar with PowerShell and want to integrate or manage their GitHub repositories seamlessly.

**GitHub PowerShell** is built with the community in mind and targets individuals who prefer script-based solutions and want to automate various tasks on GitHub without resorting to a full-fledged development approach.

## Features & Benefits of GitHub PowerShell

- **Comprehensive Access**: Harness the power of GitHub's REST API from your PowerShell console, providing you with capabilities to manage repositories, issues, pull requests, and more.

- **Support for PowerShell Versions**: This module is tested and compatible with both PowerShell 7 and Windows PowerShell 5.1 ensuring wide accessibility.

- **Cross-Platform**: Whether you're on Windows, macOS, or Linux, GitHub PowerShell has you covered.

- **Modern Authentication**: Integrate seamlessly with GitHub's authentication methods, including personal access tokens and OAuth, for secure script execution.

- **Active Development and Community Support**: As with the open-source spirit of GitHub, this module invites contributors for constant improvement and evolution. Regular updates ensure that the module remains in sync with any changes to the GitHub REST API.

- **Intuitive Command Design**: Commands are structured logically, ensuring that even new users can get started quickly without a steep learning curve.

## Getting Started with GitHub PowerShell

To dive into the world of GitHub automation with PowerShell, follow the sections below.

### Installing the module

Download and install the GitHub PowerShell module from the PowerShell Gallery with the following command:

```powershell
Install-Module -Name GitHub -Force -AllowClobber
```

### Logging on

Authenticate using your GitHub credentials or access tokens to begin executing commands. Tokens and other
configuration details are stored encrypted on the system using the PowerShell modules [SecretManagement and SecretStore Overview](https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules),
for more info on the implementation, see the section on storing configuration.

#### Device flow

This is the recommended method for authentication due to access tokens being short lived.
It opens a browser window and prompts you to log in to GitHub. Once you log in, you will be provided with
a code that you need to paste into the PowerShell console. The command already puts the code in your clipboard.
It uses a GitHub App to authenticate, which is more secure than using a personal access token. The GitHub App
is only granted access to the repositories you add it to. Visit the [GitHub Apps documentation](https://docs.github.com/en/developers/apps/about-apps)
to read more about GitHub Apps.

```powershell
Connect-GitHubAccount
! We added the code to your clipboard: [AB55-FA2E]
Press Enter to open github.com in your browser...:  #-> Press enter and paste the code in the browser window
✓ Logged in as octocat!
```

After this you will need to install the GitHub App on the repos you want to manage. You can do this by visiting the
[PowerShell for GitHub](https://github.com/apps/powershell-for-github) app page.

> Info: We will be looking to include this as a check in the module in the future. So it becomes a part of the regular sign in process.

<!-- ```powershell
Install-GitHubApp -Owner 'PSModule' -Repo 'GitHub'
``` -->

Consecutive runs of the `Connect-GitHubAccount` will not require you to paste the code again unless you revoke the token
or you change the type of authentication you want to use. Instead, it checks the remaining duration of the access token and
uses the refresh token to get a new access token if its less than 4 hours remaining.

```powershell
Connect-GitHubAccount
✓ Access token is still valid for 05:30:41 ...
✓ Logged in as octocat!
```

This is also happening automatically when you run a command that requires authentication. The validity of the token is checked before the command is executed.
If it is no longer valid, the token is refreshed and the command is executed.

#### Device Flow with OAuth app

This uses the same flow as above, but instead of using the GitHub App, it uses an OAuth app with long lived tokens.
During the signing you can also authorize the app to access your private repositories.
Visit the [OAuth apps documentation](https://docs.github.com/en/developers/apps/about-apps) to read more about OAuth apps on GitHub.

```powershell
Connect-GitHubAccount -Mode OAuth

! We added the code to your clipboard: [AB55-FA2E]
Press Enter to open github.com in your browser...:
✓ Logged in as octocat!
```

#### Personal access token

This is the least secure method of authentication, but it is also the simplest. Running the `Connect-GitHubAccount` command
with the `-AccessToken` parameter will send you to the GitHub site where you can create a new personal access token.
Give it the access you need and paste it into the terminal.

```powershell
Connect-GitHubAccount -AccessToken
! Enter your personal access token: ****************************************
✓ Logged in as octocat!
```

#### System Access Token

The module also detects the presence of a system access token and uses that if it is present.
This is useful if you are running the module in a CI/CD pipeline or in a scheduled task.
The function looks for the `GH_TOKEN` and `GITHUB_TOKEN` environment variables (in order).

```powershell
Connect-GitHubAccount
✓ Logged in as system!
```

### Command Exploration

Familiarize yourself with the available cmdlets using the module's comprehensive documentation or inline help.

```powershell
Get-Command -Module GitHub
```

### Sample Scripts

To be added: Sample scripts demonstrating the module's capabilities.

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

### Official GitHub Resources

- [REST API Description](https://github.com/github/rest-api-description)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [GitHub Platform Samples](https://github.com/github/platform-samples)

### General Web References

- [Generic HTTP Status Codes (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

### Tools Planned for Development

- [Azure AutoRest (OpenAPI Specification Code Generator)](https://github.com/Azure/autorest)

### Inspiration Behind the Project

- [Microsoft's PowerShellForGitHub](https://github.com/microsoft/PowerShellForGitHub)
- [PSGitHub by pcgeek86](https://github.com/pcgeek86/PSGitHub)
- [PSSodium by TylerLeonhardt](https://github.com/TylerLeonhardt/PSSodium)
- [libsodium NuGet Package](https://www.nuget.org/packages/Sodium.Core/)
- [GitHubActions by ebekker](https://github.com/ebekker/pwsh-github-action-tools)
- [powershell-devops by smokedlinq](https://github.com/smokedlinq/powershell-devops)
- [GitHubActionsToolkit by hugoalh-studio](https://github.com/hugoalh-studio/ghactions-toolkit-powershell)

### Authentication and Login

- [PowerShell for GitHub on GitHub Marketplace](https://github.com/apps/powershell-for-github)
- [Building a CLI with a GitHub App](https://docs.github.com/en/apps/creating-github-apps/writing-code-for-a-github-app/building-a-cli-with-a-github-app)

### Module Configuration and Environment

- [GH Environment for GitHub CLI](https://cli.github.com/manual/gh_help_environment)
