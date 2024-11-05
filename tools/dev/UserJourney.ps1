###
### CONNECTING
###

# When you connect, a context is saved.
# Variables, stored under "Contexts" on the existing config.json.
# Secrets, names are stored in the variables.
# Context = [
#     {
#         name: "github.com/MariusStorhaug"
#         id: 1
#         host: "github.com"
#         default: true
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

# Connect to GitHub interactively using GitHub App and Device Flow (User Access Token, UAT)
Connect-GitHub (-Host github.com) (-ClientID '<client_id>')

# Log on to a specific instance of GitHub (enterprise)
Connect-GitHub -Host 'dnb.ghe.com'

# Connect to GitHub interactively using OAuth App and Device Flow (should not use this, should we even support it?)
Connect-GitHub -Mode 'OAuthApp' -Scope 'gist read:org repo workflow'

# Connect to GitHub interactively using less desired PAT flow
Connect-GitHub -AccessToken

# Connect to GitHub programatically (GitHub Actions)
Connect-GitHub # Looks for the GITHUB_TOKEN variable

# Connect to GitHub programatically (GitHub App, for GitHub Actions or external applications, JWT login)
Connect-GitHub -ClientID '<client_id>' -PrivateKey '<private_key>'

# Connect to GitHub programatically (GitHub App Installation Access Token)
Connect-GitHub -Token ***********

###
### ADVANCED CONNECTING
###

# Bring you own GitHub App
Set-GitHubAuthApp -ClientID ''
Check-GitHubAuthApp
Connect-GitHub





# What about profiles?
Get-GitHubContext # List all contexts
Get-GitHubContext -Context 'name' # Returns a specific context

Set-GitHubContext -Context 'name' # Take a name? Autocomplete the name

Disconnect-GitHub -Context 'name'


# Calling specific functions with context or an ad-hoc token?
Get-GitHubRepository -Context 'dnb.ghe.com/MariusStorhaug'
