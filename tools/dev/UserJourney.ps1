###
### CONNECTING
###

# Connect to GitHub interactively using GitHub App and Device Flow (User Access Token, UAT)
Connect-GitHub (-Host github.com) (-ClientID '<client_id>') # First should set default context

# Log on to a specific instance of GitHub (enterprise)
Connect-GitHub -Host 'msx.ghe.com' # Adds context, but is not default
Connect-GitHub -Host 'msx.ghe.com' -Default # Can be added as default by setting the default flag
Get-GitHubRepository -Context 'msx.ghe.com/MariusStorhaug' # Contexts should be selectable/overrideable on any call

# Connect to GitHub interactively using OAuth App and Device Flow (should not use this, should we even support it?)
Connect-GitHub -Mode 'OAuthApp' -Scope 'gist read:org repo workflow'

# Connect to GitHub interactively using less desired PAT flow
Connect-GitHub -UseAccessToken

# Connect to GitHub programatically (GitHub Actions)
Connect-GitHub # Looks for the GITHUB_TOKEN variable

# Connect to GitHub programatically (GitHub App, for GitHub Actions or external applications, JWT login)
Connect-GitHub -ClientID '<client_id>' -PrivateKey '<private_key>'

# Connect to GitHub programatically (GitHub App Installation Access Token)
Connect-GitHub -Token ***********


###
### Contexts / Profiles
###

# When you connect, a context is saved.
# Variables, stored under "Contexts" on the existing config.json.
# Secrets, names are stored in the variables.
# Context = [
#     {
#         name: "github.com/MariusStorhaug"
#         id: 1
#         host: "github.com" -> Public
#         default: true
#         type: UAT
#     },
#     {
#         name: "github.com/qweqweqwe"
#         id: 1
#         host: "github.com"
#         default: false
#         type: UAT
#     },
#     {
#         name: "dnb.ghe.com/Marius-Storhaug"
#         id: 2
#         host: "dnb.ghe.com"
#         default: false
#         type: UAT
#     }
# ]
<#
$Config = @{
    ConfigFilePath = 'C:\Repos\GitHub\PSModule\src\functions\private\Config\config.json'

    Contexts       = @(
        @{
            Name         = 'github.com/MariusStorhaug'
            Host         = 'github.com'
            Default      = $true
            Type         = 'UAT'
            Organization = 'PSModule'
            Repository   = 'GitHub'
        },
        @{
            Name    = 'msx.ghe.com/Marius-Storhaug'
            Host    = 'msx.ghe.com'
            Default = $false
            Type    = 'UAT'
        }
    )
}
$Config
#>

Get-GitHubContext # List all contexts -> Get-GitHubConfig?
Get-GitHubContext -Context 'name' # Returns a specific context, autocomplete the name.

Set-GitHubContext -Context 'name' # Take a name dynamically from Get-GitHubContext? Autocomplete the name

Disconnect-GitHub -Context 'name' # Removes the context variables and secrets


# Calling specific functions with context or an ad-hoc token?
Get-GitHubRepository
Get-GitHubRepository -Context 'msx.ghe.com/MariusStorhaug'



Connect-GitHub -ClientID '<client_id>' -PrivateKey '<private_key>'
Get-GitHubOrganization
foreach (org) {
    Connect-GitHub -Token ***********
    Get-GitHubRepository
}
