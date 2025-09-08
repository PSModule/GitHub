# Populate the GitHub.Permissions property with all GitHub permission definitions
$script:GitHub.Permissions = @(
    # Repository Fine-Grained Permissions
    [GitHubPermission]@{
        Name = 'actions'
        DisplayName = 'Actions'
        Description = 'Manage GitHub Actions workflow runs, artifacts, and caches'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'administration'
        DisplayName = 'Administration'
        Description = 'Manage repository settings, webhooks, and team access'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'checks'
        DisplayName = 'Checks'
        Description = 'View and manage status checks'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'code_scanning_alerts'
        DisplayName = 'Code scanning alerts'
        Description = 'View and manage code scanning alerts'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'codespaces'
        DisplayName = 'Codespaces'
        Description = 'Manage GitHub Codespaces'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'codespaces_lifecycle_admin'
        DisplayName = 'Codespaces lifecycle admin'
        Description = 'Manage the lifecycle of Codespaces'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'codespaces_metadata'
        DisplayName = 'Codespaces metadata'
        Description = 'Access Codespaces metadata'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'codespaces_secrets'
        DisplayName = 'Codespaces secrets'
        Description = 'Manage Codespaces secrets'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'contents'
        DisplayName = 'Contents'
        Description = 'Read and write repository contents'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'dependabot_alerts'
        DisplayName = 'Dependabot alerts'
        Description = 'View and manage Dependabot alerts'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'dependabot_secrets'
        DisplayName = 'Dependabot secrets'
        Description = 'Manage Dependabot secrets'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'deployments'
        DisplayName = 'Deployments'
        Description = 'Manage deployments and deployment environments'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'discussions'
        DisplayName = 'Discussions'
        Description = 'Manage repository discussions'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'environments'
        DisplayName = 'Environments'
        Description = 'Manage deployment environments'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'issues'
        DisplayName = 'Issues'
        Description = 'Manage repository issues'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'metadata'
        DisplayName = 'Metadata'
        Description = 'Access repository metadata'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'packages'
        DisplayName = 'Packages'
        Description = 'Manage GitHub Packages'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'pages'
        DisplayName = 'Pages'
        Description = 'Manage GitHub Pages'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'pull_requests'
        DisplayName = 'Pull requests'
        Description = 'Manage repository pull requests'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'repository_custom_properties'
        DisplayName = 'Repository custom properties'
        Description = 'Manage custom properties for repositories'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'repository_hooks'
        DisplayName = 'Repository hooks'
        Description = 'Manage repository webhooks'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'repository_projects'
        DisplayName = 'Repository projects'
        Description = 'Manage repository projects'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write', 'admin')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'secret_scanning_alerts'
        DisplayName = 'Secret scanning alerts'
        Description = 'View and manage secret scanning alerts'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'secrets'
        DisplayName = 'Secrets'
        Description = 'Manage Actions secrets'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'security_events'
        DisplayName = 'Security events'
        Description = 'Read security events'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'single_file'
        DisplayName = 'Single file'
        Description = 'Access to specific files'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'statuses'
        DisplayName = 'Statuses'
        Description = 'Create commit statuses'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'variables'
        DisplayName = 'Variables'
        Description = 'Manage Actions variables'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },
    [GitHubPermission]@{
        Name = 'vulnerability_alerts'
        DisplayName = 'Vulnerability alerts'
        Description = 'View vulnerability alerts'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#repository-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Repository'
    },

    # Organization Fine-Grained Permissions
    [GitHubPermission]@{
        Name = 'members'
        DisplayName = 'Members'
        Description = 'Manage organization members'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_administration'
        DisplayName = 'Organization administration'
        Description = 'Manage organization settings'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_custom_properties'
        DisplayName = 'Organization custom properties'
        Description = 'Manage custom properties for organization repositories'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_custom_roles'
        DisplayName = 'Organization custom roles'
        Description = 'Manage organization custom roles'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_hooks'
        DisplayName = 'Organization hooks'
        Description = 'Manage organization webhooks'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_personal_access_tokens'
        DisplayName = 'Organization personal access tokens'
        Description = 'Manage personal access tokens within the organization'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_personal_access_token_requests'
        DisplayName = 'Organization personal access token requests'
        Description = 'Approve or deny personal access token requests'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_plan'
        DisplayName = 'Organization plan'
        Description = 'View organization billing information'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_projects'
        DisplayName = 'Organization projects'
        Description = 'Manage organization projects'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write', 'admin')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_secrets'
        DisplayName = 'Organization secrets'
        Description = 'Manage organization secrets'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_self_hosted_runners'
        DisplayName = 'Organization self-hosted runners'
        Description = 'Manage organization self-hosted runners'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'organization_user_blocking'
        DisplayName = 'Organization user blocking'
        Description = 'Block and unblock users from the organization'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },
    [GitHubPermission]@{
        Name = 'team_discussions'
        DisplayName = 'Team discussions'
        Description = 'Manage team discussions'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#organization-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'Organization'
    },

    # Account Fine-Grained Permissions (User scope)
    [GitHubPermission]@{
        Name = 'block_another_user'
        DisplayName = 'Block another user'
        Description = 'Block and unblock users'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'codespaces_user_secrets'
        DisplayName = 'Codespaces user secrets'
        Description = 'Manage your own Codespaces secrets'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'email_addresses'
        DisplayName = 'Email addresses'
        Description = 'Manage your email addresses'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'followers'
        DisplayName = 'Followers'
        Description = 'Manage your followers'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'git_ssh_keys'
        DisplayName = 'Git SSH keys'
        Description = 'Manage your Git SSH keys'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'gpg_keys'
        DisplayName = 'GPG keys'
        Description = 'Manage your GPG keys'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'interaction_limits'
        DisplayName = 'Interaction limits'
        Description = 'Manage interaction limits on your account'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'plan'
        DisplayName = 'Plan'
        Description = 'View your billing plan'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'private_repository_forking'
        DisplayName = 'Private repository forking'
        Description = 'Manage private repository forking'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'profile'
        DisplayName = 'Profile'
        Description = 'Update your profile information'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'ssh_signing_keys'
        DisplayName = 'SSH signing keys'
        Description = 'Manage your SSH signing keys'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'starring'
        DisplayName = 'Starring'
        Description = 'Star and unstar repositories'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    },
    [GitHubPermission]@{
        Name = 'watching'
        DisplayName = 'Watching'
        Description = 'Watch and unwatch repositories'
        URL = 'https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens#account-permissions'
        Options = @('read', 'write')
        Type = 'Fine-grained'
        Scope = 'User'
    }
)