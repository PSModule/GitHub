# GitHub PowerShell

The module serves as a wrapper around [GitHub's REST API](https://docs.github.com/en/rest), making the functionalities and data available on GitHub
accessible through PowerShell functions and classes. This module is tailored for developers, administrators, and GitHub enthusiasts who are familiar
with PowerShell and want to integrate or manage GitHub seamlessly.

## Desired supported scenarios

- Support operators of personal repos, organization repos, and enterprise repos. -> Similar to the GitHub CLI, but with more commands.
- Help operators that have multiple account and is a member of multiple organizations/enterprises. -> Similar to the GitHub CLI.
- A context aware module that knows what environment you are working in, both locally and in GitHub Actions. -> Similar to the Octokit.
- Built to be a native companion with GitHub Actions with Workflow commands that you can use. -> Similar to the Octokit and github-scripts
- A module that can be used in other PowerShell compatible automation environments, like FunctionApps. -> Similar to the Octokit.
- A way to deploy, declare and manage resources in GitHub programmatically. -> Similar to Terraform and Pulumi.

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

Authenticate using your GitHub credentials or access tokens to begin executing commands. The module supports multiple authentication methods.

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

#### Using a GitHub App

If you are using a GitHub App, you can use the `Connect-GitHubApp` command to authenticate using the client ID and private key.

```powershell
Connect-GitHubApp -ClientId 'lv123456789' -PrivateKey '-----BEGIN PRIVATE KEY----- ... -----END PRIVATE KEY-----'
✓ Logged in as my-github-app!
```

#### Using a different host

If you are using GitHub Enterprise, you can use the `-Host` parameter to specify the host you want to connect to.
This can be used in combination with all the other authentication methods.

```powershell
Connect-GitHubAccount -Host 'https://github.local'
✓ Logged in as octocat!
```

Or you might be using GitHub Enterprise Cloud with Data Residency.

```powershell
Connect-GitHubAccount -Host 'https://msx.ghe.com'
✓ Logged in as octocat!
```

#### Using a different GitHub App for issuing User access tokens

Instead of using our default GitHub App, you can use a different GitHub App to issue user access tokens.
You can use the `-ClientID` parameters to specify the app you want to use.

```powershell
Connect-GitHubAccount -Host 'https://msx.ghe.com' -ClientID 'lv123456789'
✓ Logged in as octocat!
```

### Command Exploration

Familiarize yourself with the available cmdlets using the module's comprehensive documentation or inline help.

```powershell
Get-Command -Module GitHub
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
