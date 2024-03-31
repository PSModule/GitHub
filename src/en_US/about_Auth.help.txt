TOPIC
    about_Auth

SHORT DESCRIPTION
    Describes the authentication methods provided in the PowerShell module for interacting with GitHub's REST API.

LONG DESCRIPTION
    This module provides several functions to manage authentication for GitHub's REST API. There are primarily two ways to authenticate:

    1. GitHub Device Flow: This method prompts the user to visit a specific URL on GitHub where they must enter a user verification code. Once this is done, the module retrieves the necessary access tokens to make authenticated API requests.

    2. Personal Access Token: The user can provide a Personal Access Token (PAT) to authenticate. This PAT allows the module to interact with the API on the user's behalf. The module can automatically use environment variables `GH_TOKEN` or `GITHUB_TOKEN` if they are present.

    The module also provides functionalities to refresh the access token and to disconnect or logout from the GitHub account.

EXAMPLES
    Example 1:
        Connect-GitHubAccount
        Connects to GitHub using the device flow login. You'll be prompted to visit a specific URL on GitHub and enter the provided user verification code.

    Example 2:
        Connect-GitHubAccount -AccessToken 'ghp_####'
        Connects to GitHub using a provided personal access token (PAT).

    Example 3:
        Connect-GitHubAccount -Refresh
        Refreshes the access token for continued session validity.

    Example 4:
        Disconnect-GitHubAccount
        Disconnects from GitHub and removes the current GitHub configuration.

    Example 5 (Automatic login using environment variables):
        If either the `GH_TOKEN` or `GITHUB_TOKEN` environment variables are set, the module will automatically use them for authentication during module initialization.

KEYWORDS
    GitHub, Authentication, Device Flow, Personal Access Token, PowerShell, REST API

SEE ALSO
    For more information on the Device Flow visit:
    - https://docs.github.com/apps/creating-github-apps/writing-code-for-a-github-app/building-a-cli-with-a-github-app

    For information about scopes and other authentication methods on GitHub:
    - https://docs.github.com/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps
    - https://docs.github.com/rest/overview/other-authentication-methods#authenticating-for-saml-sso
