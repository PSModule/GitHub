# Authentication

Authenticate using your GitHub credentials or access tokens to begin executing commands. The module supports everything:

- Personal authentication
  - User Access Tokens (UATs) for personal accounts using both GitHub Apps and OAuth Apps. You can also bring your own app, so you dont have to use ours.
  - Personal Access Tokens (PATs) using both classic and fine-grained scopes.
- Programmatic authentication
  - GitHub Apps using the client ID and private key.
  - Installation Access Tokens (IATs) for CI/CD pipelines, scheduled tasks and automation from other systems, like FunctionApps.

## Personal authentication - User access tokens

This is the recommended method for authentication due to access tokens being short lived.
It opens a browser window and prompts you to log in to GitHub. Once you log in, you will be provided with
a code that you need to paste into the PowerShell console. The command already puts the code in your clipboard.
It uses a GitHub App to authenticate, which is more secure than using a personal access token. The GitHub App
is only granted access to the organizations or repositories you install it on. Visit the [GitHub Apps documentation](https://docs.github.com/developers/apps/about-apps)
to read more about GitHub Apps. You can also use a different GitHub App to issue user access tokens, check the section on
[Using a different GitHub App for issuing User access tokens](#using-a-different-github-app-for-issuing-user-access-tokens) for more information.

```powershell
Connect-GitHubAccount
! We added the code to your clipboard: [AB55-FA2E]
Press Enter to open github.com in your browser...:  #-> Press enter and paste the code in the browser window
✓ Logged in as octocat!
```

After this you will need to install the GitHub App on the repos you want to manage. You can do this by visiting the
[PowerShell for GitHub](https://github.com/apps/powershell-for-github) app page.

## Personal authentication - User access tokens with OAuth app

This uses the same flow as above, but instead of using the GitHub App, it uses an OAuth app with long lived tokens.
During the signing you can also authorize the app to access your private repositories.
Visit the [OAuth apps documentation](https://docs.github.com/developers/apps/about-apps) to read more about OAuth apps on GitHub.

```powershell
Connect-GitHubAccount -Mode OAuth

! We added the code to your clipboard: [AB55-FA2E]
Press Enter to open github.com in your browser...:
✓ Logged in as octocat!
```

## Personal authentication - Personal Access Token

This is the least secure method of authentication, but it is also the simplest. Running the `Connect-GitHubAccount` command
with the `-UseAccessToken` parameter will send you to the GitHub site where you can create a new personal access token.
Give it the access you need and paste it into the terminal.

```powershell
Connect-GitHubAccount -UseAccessToken
! Enter your personal access token: ****************************************
✓ Logged in as octocat!
```

## Programmatic authentication - Installation Access Tokens (IATs)

The module also detects the presence of a system access token and uses that if it is present.
This is useful if you are running the module in a CI/CD pipeline or in a scheduled task.
The function looks for the `GH_TOKEN` and `GITHUB_TOKEN` environment variables (in order).

```powershell
Connect-GitHubAccount
✓ Logged in as system!
```

You can also specify the token directly in the command.

```powershell
Connect-GitHubAccount -Token '...'
✓ Logged in as octocat!
```

## Using a GitHub App

If you are using a GitHub App, you can use the `Connect-GitHubAccount` command to authenticate using the client ID and private key.

```powershell
Connect-GitHubAccount -ClientID $ClientID -PrivateKey $PrivateKey
✓ Logged in as my-github-app!
```

Using this approach, the module will autogenerate a JWT every time you run a command. I.e. Get-GitHubApp.

## Using a GitHub App with Azure Key Vault

For enhanced security, you can store your GitHub App's keys in Azure Key Vault and use that as way to signing the JWTs.
This approach requires a pre-authenticated session with either Azure CLI or Azure PowerShell.

**Prerequisites:**

- Azure CLI authenticated session (`az login`) or Azure PowerShell authenticated session (`Connect-AzAccount`)
- GitHub App private key stored as a key in Azure Key Vault, with 'Sign' as a permitted operation
- Appropriate permissions to read keys from the Key Vault, like 'Key Vault Crypto User'

**Using Azure CLI authentication:**

```powershell
# Ensure you're authenticated with Azure CLI
az login

# Connect using Key Vault key reference (URI with or without version)
Connect-GitHubAccount -ClientID $ClientID -KeyVaultKeyReference 'https://my-keyvault.vault.azure.net/keys/github-app-private-key'
✓ Logged in as my-github-app!
```

**Using Azure PowerShell authentication:**

```powershell
# Ensure you're authenticated with Azure PowerShell
Connect-AzAccount

# Connect using Key Vault key reference (URI with or without version)
Connect-GitHubAccount -ClientID $ClientID -KeyVaultKeyReference 'https://my-keyvault.vault.azure.net/keys/github-app-private-key'
✓ Logged in as my-github-app!
```

**Using Key Vault key reference with version:**

```powershell
# Connect using Key Vault key reference with specific version
Connect-GitHubAccount -ClientID $ClientID -KeyVaultKeyReference 'https://my-keyvault.vault.azure.net/keys/github-app-private-key/abc123def456'
✓ Logged in as my-github-app!
```

This method ensures that your private key is securely stored in Azure Key Vault and never exposed in your scripts or configuration files.

## Using a different host

If you are using GitHub Enterprise, you can use the `-Host` (or `-HostName`) parameter to specify the host you want to connect to.
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

## Using a different GitHub App for issuing User access tokens

Instead of using our default GitHub App, you can use a different GitHub App to issue user access tokens.
You can use the `-ClientID` parameters to specify the app you want to use.

```powershell
Connect-GitHubAccount -Host 'https://msx.ghe.com' -ClientID 'lv123456789'
✓ Logged in as octocat!
```

## Automatic token renewal

The module automatically manages short‑lived tokens for GitHub Apps:

- User access tokens (when you authenticate via a GitHub App) are short‑lived and include a refresh token. The module refreshes them automatically before/when they expire—no extra steps are required.
- App JWTs (when the context is a GitHub App) are generated and rotated automatically per call as needed. You never need to create or renew the JWT yourself.

Note: Long‑lived tokens like classic/fine‑grained PATs and provided installation tokens (GH_TOKEN/GITHUB_TOKEN) are not refreshed by the module.
