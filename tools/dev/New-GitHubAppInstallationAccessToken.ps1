#Create an installation access token for an app

<#
Path parameters
Name, Type, Description
installation_id integer Required
The unique identifier of the installation.

Body parameters
Name, Type, Description
repositories array of strings
List of repository names that the token should have access to

repository_ids array of integers
List of repository IDs that the token should have access to

permissions object
The permissions granted to the user access token.

Properties of permissions
Name, Type, Description
actions string
The level of permission to grant the access token for GitHub Actions workflows, workflow runs, and artifacts.

Can be one of: read, write

administration string
The level of permission to grant the access token for repository creation, deletion, settings, teams, and collaborators creation.

Can be one of: read, write

checks string
The level of permission to grant the access token for checks on code.

Can be one of: read, write

codespaces string
The level of permission to grant the access token to create, edit, delete, and list Codespaces.

Can be one of: read, write

contents string
The level of permission to grant the access token for repository contents, commits, branches, downloads, releases, and merges.

Can be one of: read, write

dependabot_secrets string
The leve of permission to grant the access token to manage Dependabot secrets.

Can be one of: read, write

deployments string
The level of permission to grant the access token for deployments and deployment statuses.

Can be one of: read, write

environments string
The level of permission to grant the access token for managing repository environments.

Can be one of: read, write

issues string
The level of permission to grant the access token for issues and related comments, assignees, labels, and milestones.

Can be one of: read, write

metadata string
The level of permission to grant the access token to search repositories, list collaborators, and access repository metadata.

Can be one of: read, write

packages string
The level of permission to grant the access token for packages published to GitHub Packages.

Can be one of: read, write

pages string
The level of permission to grant the access token to retrieve Pages statuses, configuration, and builds, as well as create new builds.

Can be one of: read, write

pull_requests string
The level of permission to grant the access token for pull requests and related comments, assignees, labels, milestones, and merges.

Can be one of: read, write

repository_custom_properties string
The level of permission to grant the access token to view and edit custom properties for a repository, when allowed by the property.

Can be one of: read, write

repository_hooks string
The level of permission to grant the access token to manage the post-receive hooks for a repository.

Can be one of: read, write

repository_projects string
The level of permission to grant the access token to manage repository projects, columns, and cards.

Can be one of: read, write, admin

secret_scanning_alerts string
The level of permission to grant the access token to view and manage secret scanning alerts.

Can be one of: read, write

secrets string
The level of permission to grant the access token to manage repository secrets.

Can be one of: read, write

security_events string
The level of permission to grant the access token to view and manage security events like code scanning alerts.

Can be one of: read, write

single_file string
The level of permission to grant the access token to manage just a single file.

Can be one of: read, write

statuses string
The level of permission to grant the access token for commit statuses.

Can be one of: read, write

vulnerability_alerts string
The level of permission to grant the access token to manage Dependabot alerts.

Can be one of: read, write

workflows string
The level of permission to grant the access token to update GitHub Actions workflow files.

Value: write

members string
The level of permission to grant the access token for organization teams and members.

Can be one of: read, write

organization_administration string
The level of permission to grant the access token to manage access to an organization.

Can be one of: read, write

organization_custom_roles string
The level of permission to grant the access token for custom repository roles management.

Can be one of: read, write

organization_custom_org_roles string
The level of permission to grant the access token for custom organization roles management.

Can be one of: read, write

organization_custom_properties string
The level of permission to grant the access token for custom property management.

Can be one of: read, write, admin

organization_copilot_seat_management string
The level of permission to grant the access token for managing access to GitHub Copilot for members of an organization with a Copilot Business subscription. This property is in beta and is subject to change.

Value: write

organization_announcement_banners string
The level of permission to grant the access token to view and manage announcement banners for an organization.

Can be one of: read, write

organization_events string
The level of permission to grant the access token to view events triggered by an activity in an organization.

Value: read

organization_hooks string
The level of permission to grant the access token to manage the post-receive hooks for an organization.

Can be one of: read, write

organization_personal_access_tokens string
The level of permission to grant the access token for viewing and managing fine-grained personal access token requests to an organization.

Can be one of: read, write

organization_personal_access_token_requests string
The level of permission to grant the access token for viewing and managing fine-grained personal access tokens that have been approved by an organization.

Can be one of: read, write

organization_plan string
The level of permission to grant the access token for viewing an organization's plan.

Value: read

organization_projects string
The level of permission to grant the access token to manage organization projects and projects beta (where available).

Can be one of: read, write, admin

organization_packages string
The level of permission to grant the access token for organization packages published to GitHub Packages.

Can be one of: read, write

organization_secrets string
The level of permission to grant the access token to manage organization secrets.

Can be one of: read, write

organization_self_hosted_runners string
The level of permission to grant the access token to view and manage GitHub Actions self-hosted runners available to an organization.

Can be one of: read, write

organization_user_blocking string
The level of permission to grant the access token to view and manage users blocked by the organization.

Can be one of: read, write

team_discussions string
The level of permission to grant the access token to manage team discussions and related comments.

Can be one of: read, write

email_addresses string
The level of permission to grant the access token to manage the email addresses belonging to a user.

Can be one of: read, write

followers string
The level of permission to grant the access token to manage the followers belonging to a user.

Can be one of: read, write

git_ssh_keys string
The level of permission to grant the access token to manage git SSH keys.

Can be one of: read, write

gpg_keys string
The level of permission to grant the access token to view and manage GPG keys belonging to a user.

Can be one of: read, write

interaction_limits string
The level of permission to grant the access token to view and manage interaction limits on a repository.

Can be one of: read, write

profile string
The level of permission to grant the access token to manage the profile settings belonging to a user.

Value: write

starring string
The level of permission to grant the access token to list and manage repositories a user is starring.

Can be one of: read, write
#>
Invoke-RestMethod -Uri 'https://api.github.com/app/installations/53353776/access_tokens' -Headers @{
    Authorization = "Bearer $token"
} -Method POST
