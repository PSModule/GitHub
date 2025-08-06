###
### CONNECTING
###

# Connect to GitHub interactively using GitHub App and Device Flow (User Access Token, UAT)
Connect-GitHub

# Log on to a specific instance of GitHub (enterprise)
Connect-GitHub -Host 'msx.ghe.com'
Get-GitHubRepository -Context 'msx.ghe.com/MariusStorhaug' # Contexts are selectable/overrideable on any call

# Connect to GitHub interactively using OAuth App and Device Flow.
Connect-GitHub -Mode 'OAuthApp' -Scope 'gist read:org repo workflow'

# Connect to GitHub interactively using less desired PAT flow, supports both fine-grained and classic PATs
Connect-GitHub -UseAccessToken

# Connect to GitHub programatically (GitHub App Installation Access Token or PAT)
Connect-GitHub -Token ***********

# Connect to GitHub programatically (GitHub Actions)
Connect-GitHub # Looks for the GITHUB_TOKEN variable

# Connect using a GitHub App and its private key (local signing of JWT)
Connect-GitHub -ClientID '<client_id>' -PrivateKey '<private_key>'

# Connect using a GitHub App and the Key vault for signing the JWT.
# Prereq: The private key is stored in an Azure Key Vault and the shell has an authenticated Azure PowerShell or Azure CLI session
$ClientID = 'Iv23lieHcDQDwVV3alK1'
$KeyVaultKeyReference = 'https://psmodule-test-vault.vault.azure.net/keys/psmodule-ent-app'
Connect-GitHub -ClientID $ClientID -KeyVaultKeyReference $KeyVaultKeyReference
Connect-GitHubApp -Organization 'dnb-tooling'


###
### Contexts / Profiles
###

# Returns the default context
Get-GitHubContext

# Returns all available contexts
Get-GitHubContext -ListAvailable

# Returns a specific context, autocomplete the name.
Get-GitHubContext -Context 'msx.ghe.com/MariusStorhaug'

# Take a name dynamically from Get-GitHubContext? tab-complete the name
Switch-GitHubContext -Context 'msx.ghe.com/MariusStorhaug'

# Set a specific context as the default context using pipeline
'msx.ghe.com/MariusStorhaug' | Switch-GitHubContext

# Abstraction layers on GitHubContexts
Get-GitHubContext -Context 'msx.ghe.com/MariusStorhaug'

###
### DISCONNECTING
###

# Disconnect from GitHub and remove the default context. NB, this does not set another default context.
Disconnect-GitHub

# Disconnect from GitHub and remove a specific context
Disconnect-GitHub -Context 'msx.ghe.com/MariusStorhaug'
