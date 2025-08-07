## The uninstall function is context aware and will use the context to determine the type of uninstallation.
## We can uninstall either as a GitHub App or as an Enterprise installation.
## Examples assume that the GitHub App that is performing the uninstalls is the current context.
## See 'Connection' examples to find how to connect as a GitHub App.


##
## As a GitHub App you can uninstall the app from any target where it is currently installed.
##

# First get info about the app installations for the authenticated app.
$installations = Get-GitHubAppInstallation
$installations

# Uninstall the app installation by name. This will string match with the target of the installation.
Uninstall-GitHubApp -Target 'msx'     # Enterprise
Uninstall-GitHubApp -Target 'org-123' # Organization
Uninstall-GitHubApp -Target 'octocat' # User

# Uninstall the app installation by ID. This will do an exact match with the installation ID.
Uninstall-GitHubApp -Target 12345

# Uninstall the app using the installation objects from the pipeline.
Get-GitHubAppInstallation | Uninstall-GitHubApp

# Uninstall the app from all Users using an installation object array.
$installations = Get-GitHubAppInstallation | Where-Object Type -EQ 'User'
$installations | Uninstall-GitHubApp

###
### Full example, uninstalling an app from deleted organizations in an enterprise.
###
# Get the installations for all organizations where the app is installed.
$orgInstallations = Get-GitHubAppInstallation | Where-Object Type -EQ 'Organization'

# Connect to the enterprise using a management app that can manage installations to get the available organizations in the enterprise.
$enterpriseContext = Connect-GitHubApp -Enterprise 'msx' -PassThru
$orgs = Get-GitHubOrganization -Enterprise 'msx' -Context $enterpriseContext

# Uninstall the app from all organizations that are not in the list of available organizations.
$orgInstallations | Where-Object { $_.Target -notin $orgs.Name } | Uninstall-GitHubApp

##
## As an enterprise installation, you can uninstall any app that is installed on an organization in the enterprise.
##

# Get the installations for the organizations in the enterprise that we can manage.
$orgInstallations = Get-GitHubAppInstallation | Where-Object Type -EQ 'Organization'

# Connect to the enterprise using a management app that can manage installations and store it in a variable.
$enterpriseContext = Connect-GitHubApp -Enterprise 'msx' -PassThru

# Get the available organizations in the enterprise.
$orgs = Get-GitHubOrganization -Enterprise 'msx' -Context $enterpriseContext

# Lets say we want to uninstall a specific app from all organizations in the enterprise.
# We can do this by iterating over the installations that we manage and uninstall the app.
$appToUninstall = 'psmodule-enterprise-app'
foreach ($managedOrg in $orgInstallations) {
    Uninstall-GitHubApp -Target $managedOrg.Target -AppSlug $appToUninstall -Context $enterpriseContext
}

# Uninstall an app installation by name.
Uninstall-GitHubApp -Target 'msx' -AppName 'my-app'

$installations | Uninstall-GitHubApp -Target 'enterprise-name'

# Uninstall an app installation by object.
$installations | Uninstall-GitHubApp


# Uninstall an app installation by ID.
Uninstall-GitHubApp -Target 12345


Uninstall-GitHubApp -Target 'fnxsd' -ID 1234567890
Uninstall-GitHubApp -Target 'fnxsd' -Slug 'my-app-slug'
