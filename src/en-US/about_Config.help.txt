TOPIC
    about_Config

SHORT DESCRIPTION
    Provides details about the configuration management functions in the PowerShell Module.

LONG DESCRIPTION
    The PowerShell Module provides a set of functions to manage the configuration related to the module.
    The configuration is stored in a secret vault and can be accessed, modified, saved, and restored
    using the provided cmdlets.

DATA STRUCTURE

    Name: SecretVault
    Purpose: Hold static configuration data about the secret vault.
    Path: \classes\Data\SecretVault.psd1

    | Name                         | Type           | Static Value                       | Description                   |
    | ---------------------------- | -------------- | ---------------------------------- | ----------------------------- |
    | SecretVault                  | pscustomobject | {Name, Type, Secret}               |                               |
    | SecretVault.Name             | string         | 'GitHub'                           | The name of the secret vault. |
    | SecretVault.Type             | string         | 'Microsoft.PowerShell.SecretStore' | The type of the secret vault. |
    | SecretVault.Secret           | pscustomobject | {Name}                             |                               |
    | SecretVault.Secret.Name      | string         | 'Config'                           | The name of the secret.       |

    Name: Config
    Purpose: Hold the current configuration data.
    Path: \classes\Data\Config.ps1

    | Name                                 | Type           | Default Value            | Description                       |
    | ------------------------------------ | -------------- | ------------------------ | --------------------------------- |
    | App                                  | pscustomobject |                          |                                   |
    | App.API                              | pscustomobject |                          |                                   |
    | App.API.BaseURI                      | string         | 'https://api.github.com' | The GitHub API Base URI.          |
    | App.API.Version                      | string         | '2022-11-28'             | The GitHub API version.           |
    | App.Defaults                         | pscustomobject | {}                       |                                   |
    | User                                 | pscustomobject |                          |                                   |
    | User.Auth                            | pscustomobject |                          |                                   |
    | User.Auth.AccessToken                | pscustomobject |                          | The access token.                 |
    | User.Auth.AccessToken.Value          | string         | ''                       | The access token value.           |
    | User.Auth.AccessToken.ExpirationDate | datetime       | [datetime]::MinValue     | The access token expiration date. |
    | User.Auth.ClientID                   | string         | ''                       | The client ID.                    |
    | User.Auth.Mode                       | string         | ''                       | The authentication mode.          |
    | User.Auth.RefreshToken               | pscustomobject |                          | The refresh token.                |
    | User.Auth.RefreshToken.Value         | string         | ''                       | The refresh token value.          |
    | User.Auth.RefreshToken.ExpirationDate| datetime       | [datetime]::MinValue     | The refresh token expiration date.|
    | User.Auth.Scope                      | string         | ''                       | The scope.                        |
    | User.Defaults                        | pscustomobject |                          |                                   |
    | User.Defaults.Owner                  | string         | ''                       | The default owner.                |
    | User.Defaults.Repo                   | string         | ''                       | The default repository.           |

FUNCTIONS

    - Get-GitHubConfig: Fetches the current module configuration.
    - Reset-GitHubConfig: Resets all or specific sections to its default values.
    - Set-GitHubConfig: Allows setting specific elements of the configuration.

CONFIGURATION

    The configuration values are securely stored using the SecretManagement and SecretStore modules. During the module import, the following steps are performed:

    1. Initialize the configuration store.
         - Check for secret vault of type 'Microsoft.PowerShell.SecretStore'.
             If not registered for the current user, its configuration will be reset to unattended mode.
         - Check for secret vault with the name 'GitHub'.
             If it does not exist, it will be created with current configuration.
             If the user is already using the secret vault, the existing configuration will be kept.
    2. Restore saved configuration from the configuration store.
         - Look for the 'GitHub' secret vault.
         - Look for the secret called 'Config'. If it exists, restore the configuration from it into memory.

EXAMPLES

    -------------------------- EXAMPLE 1 --------------------------

    Get-GitHubConfig

    This command retrieves the current GitHub configuration.

    -------------------------- EXAMPLE 2 --------------------------

    Set-GitHubConfig -APIBaseURI 'https://api.newurl.com' -APIVersion '2023-09-23'

    This command sets the API Base URI to 'https://api.newurl.com' and the API version to '2023-09-23'.

    -------------------------- EXAMPLE 3 --------------------------

    Reset-GitHubConfig -Scope Auth

    This command resets the Auth related settings of the GitHub configuration to its default values.


KEYWORDS

    GitHub
    PowerShell
    SecretManagement
    SecretStore

SEE ALSO

    - For more information about SecretManagement and SecretStore:
      https://learn.microsoft.com/en-us/powershell/utility-modules/secretmanagement/overview?view=ps-modules
    - The GitHub repository of this module:
      https://github.com/PSModule/GitHub
    - PowerShell Gallery page for SecretManagement module:
      https://www.powershellgallery.com/packages/Microsoft.PowerShell.SecretManagement/
