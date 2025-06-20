﻿###
### CONNECTING
###

# Connect to GitHub interactively using GitHub App and Device Flow (User Access Token, UAT)
Connect-GitHub

# Log on to a specific instance of GitHub (enterprise)
Connect-GitHub -Host 'msx.ghe.com'
Get-GitHubRepository -Context 'msx.ghe.com/MariusStorhaug' # Contexts should be selectable/overrideable on any call

# Connect to GitHub interactively using OAuth App and Device Flow (should not use this, should we even support it?)
Connect-GitHub -Mode 'OAuthApp' -Scope 'gist read:org repo workflow'

# Connect to GitHub interactively using less desired PAT flow
Connect-GitHub -UseAccessToken

# Connect to GitHub programatically (GitHub Actions)
Connect-GitHub # Looks for the GITHUB_TOKEN variable

# Connect to GitHub programatically (GitHub App, for GitHub Actions or external applications, JWT login)
Connect-GitHub -ClientID '<client_id>' -PrivateKey '<private_key>'

# Connect to GitHub programatically (GitHub App Installation Access Token or PAT)
Connect-GitHub -Token ***********

###
### Contexts / Profiles
###

# Returns the default context
Get-GitHubContext

# Returns all available contexts
Get-GitHubContext -ListAvailable

# Returns a specific context, autocomplete the name.
Get-GitHubContext -Context 'msx.ghe.com/MariusStorhaug'

# Take a name dynamically from Get-GitHubContext? Autocomplete the name
Switch-GitHubContext -Context 'msx.ghe.com/MariusStorhaug'

# Set a specific context as the default context using pipeline
'msx.ghe.com/MariusStorhaug' | Switch-GitHubContext

Get-GitHubContext -Context 'github.com/MariusStorhaug' | Switch-GitHubContext

# Abstraction layers on GitHubContexts
Get-GitHubContext -Context 'msx.ghe.com/MariusStorhaug'

###
### DISCONNECTING
###

# Disconnect from GitHub and remove the default context. NB, this does not set another default context.
Disconnect-GitHub

# Disconnect from GitHub and remove a specific context
Disconnect-GitHub -Context 'msx.ghe.com/MariusStorhaug'
