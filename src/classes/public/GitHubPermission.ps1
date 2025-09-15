class GitHubPermissionDefinition {
    # The programmatic name of the permission as returned by the GitHub API
    [string] $Name

    # The human-friendly name of the permission as shown in the GitHub UI
    [string] $DisplayName

    # A brief description of what access the permission grants
    [string] $Description

    # A link to the relevant documentation or GitHub UI page
    [uri] $URL

    # The levels of access that can be granted for this permission
    [string[]] $Options

    # The type of permission (Fine-grained, Classic)
    [string] $Type

    # The scope at which this permission applies (Repository, Organization, User, Enterprise)
    [string] $Scope

    static [GitHubPermissionDefinition[]] $List = @(
        # ------------------------------
        # Repository Fine-Grained Permission Definitions
        # ------------------------------
        [GitHubPermissionDefinition]::new(
            'actions',
            'Actions',
            'Workflows, workflow runs and artifacts.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-actions',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'administration',
            'Administration',
            'Repository creation, deletion, settings, teams, and collaborators.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-administration',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'attestations',
            'Attestations',
            'Create and retrieve attestations for a repository.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-attestations',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'checks',
            'Checks',
            'Checks on code.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-checks',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'security_events',
            'Code scanning alerts',
            'View and manage code scanning alerts.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-code-scanning-alerts',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'codespaces',
            'Codespaces',
            'Create, edit, delete and list Codespaces.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-codespaces',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'codespaces_lifecycle_admin',
            'Codespaces lifecycle admin',
            'Manage the lifecycle of Codespaces, including starting and stopping.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-codespaces-lifecycle-admin',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'codespaces_metadata',
            'Codespaces metadata',
            'Access Codespaces metadata including the devcontainers and machine type.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-codespaces-metadata',
            @(
                'read'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'codespaces_secrets',
            'Codespaces secrets',
            'Restrict Codespaces user secrets modifications to specific repositories.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-codespaces-secrets',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'statuses',
            'Commit statuses',
            'Commit statuses.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-commit-statuses',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'contents',
            'Contents',
            'Repository contents, commits, branches, downloads, releases, and merges.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-contents',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'repository_custom_properties',
            'Custom properties',
            'Read and write repository custom properties values at the repository level, when allowed by the property.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-custom-properties',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'vulnerability_alerts',
            'Dependabot alerts',
            'Retrieve Dependabot alerts.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-dependabot-alerts',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'dependabot_secrets',
            'Dependabot secrets',
            'Manage Dependabot repository secrets.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-dependabot-secrets',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'deployments',
            'Deployments',
            'Deployments and deployment statuses.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-deployments',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'discussions',
            'Discussions',
            'Discussions and related comments and labels.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-discussions',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'environments',
            'Environments',
            'Manage repository environments.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-environments',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'issues',
            'Issues',
            'Issues and related comments, assignees, labels, and milestones.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-issues',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'merge_queues',
            'Merge queues',
            "Manage a repository's merge queues",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-merge-queues',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new( #Mandatory
            'metadata',
            'Metadata',
            'Search repositories, list collaborators, and access repository metadata.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-metadata',
            @(
                'read'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'packages',
            'Packages',
            'Packages published to the GitHub Package Platform.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-packages',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'pages',
            'Pages',
            'Retrieve Pages statuses, configuration, and builds, as well as create new builds.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-pages',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'repository_projects',
            'Projects',
            'Manage classic projects within a repository.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-projects',
            @(
                'read',
                'write',
                'admin'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'pull_requests',
            'Pull requests',
            'Pull requests and related comments, assignees, labels, milestones, and merges.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-pull-requests',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'repository_advisories',
            'Repository security advisories',
            'View and manage repository security advisories.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-repository-security-advisories',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'repo_secret_scanning_dismissal_requests',
            'Secret scanning alert dismissal requests',
            'View and manage secret scanning alert dismissal requests',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-secret-scanning-alert-dismissal-requests',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'secret_scanning_alerts',
            'Secret scanning alerts',
            'View and manage secret scanning alerts.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-secret-scanning-alerts',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'secret_scanning_bypass_requests',
            'Secret scanning push protection bypass requests',
            'Review and manage repository secret scanning push protection bypass requests.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-secret-scanning-push-protection-bypass-requests',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'secrets',
            'Secrets',
            'Manage Actions repository secrets.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-secrets',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'single_file',
            'Single file',
            'Manage just a single file.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-single-file',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'actions_variables',
            'Variables',
            'Manage Actions repository variables.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-variables',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'repository_hooks',
            'Webhooks',
            'Manage the post-receive hooks for a repository.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-webhooks',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),
        [GitHubPermissionDefinition]::new(
            'workflows',
            'Workflows',
            'Update GitHub Action workflow files.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#repository-permissions-for-workflows',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Repository'
        ),

        # ------------------------------
        # Organization Fine-Grained Permission Definitions
        # ------------------------------
        [GitHubPermissionDefinition]::new(
            'organization_api_insights',
            'API Insights',
            'View statistics on how the API is being used for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-api-insights',
            @(
                'read'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_administration',
            'Administration',
            'Manage access to an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-administration',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_user_blocking',
            'Blocking users',
            'View and manage users blocked by the organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-blocking-users',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_campaigns',
            'Campaigns',
            'Manage campaigns.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-campaigns',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_custom_org_roles',
            'Custom organization roles',
            'Create, edit, delete and list custom organization roles. View system organization roles.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-custom-organization-roles',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_custom_properties',
            'Custom properties',
            'Read and write repository custom properties values and administer definitions at the organization level.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-custom-properties',
            @(
                'read',
                'write',
                'admin'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_custom_roles',
            'Custom repository roles',
            'Create, edit, delete and list custom repository roles.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-custom-repository-roles',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_events',
            'Events',
            'View events triggered by an activity in an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-events',
            @(
                'read'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_copilot_seat_management',
            'GitHub Copilot Business',
            'Manage Copilot Business seats and settings',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-github-copilot-business',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'issue_fields',
            'Issue Fields',
            'Manage issue fields for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-issue-fields',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'issue_types',
            'Issue Types',
            'Manage issue types for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-issue-types',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_knowledge_bases',
            'Knowledge bases',
            'View and manage knowledge bases for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-knowledge-bases',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'members',
            'Members',
            'Organization members and teams.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-members',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_models',
            'Models',
            'Manage model access for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-models',
            @(
                'read'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_network_configurations',
            'Network configurations',
            'View and manage hosted compute network configurations available to an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-network-configurations',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_announcement_banners',
            'Organization announcement banners',
            'View and modify announcement banners for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-organization-announcement-banners',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_secret_scanning_bypass_requests',
            'Organization bypass requests for secret scanning',
            'Review and manage secret scanning push protection bypass requests.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-organization-bypass-requests-for-secret-scanning',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_codespaces',
            'Organization codespaces',
            'Manage Codespaces for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-organization-codespaces',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_codespaces_secrets',
            'Organization codespaces secrets',
            'Manage Codespaces Secrets for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-organization-codespaces-secrets',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_codespaces_settings',
            'Organization codespaces settings',
            'Manage Codespaces settings for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-organization-codespaces-settings',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_dependabot_secrets',
            'Organization dependabot secrets',
            'Manage Dependabot organization secrets.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-organization-dependabot-secrets',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_code_scanning_dismissal_requests',
            'Organization dismissal requests for code scanning',
            'Review and manage code scanning alert dismissal requests.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-organization-dismissal-requests-for-code-scanning',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_private_registries',
            'Organization private registries',
            'Manage private registries for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-organization-private-registries',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_personal_access_token_requests',
            'Personal access token requests',
            'Manage personal access token requests from organization members.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-personal-access-token-requests',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_personal_access_tokens',
            'Personal access tokens',
            'View and revoke personal access tokens that have been granted access to an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-personal-access-tokens',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_plan',
            'Plan',
            "View an organization's plan.",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-plan',
            @(
                'read'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_projects',
            'Projects',
            'Manage projects for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-projects',
            @(
                'read',
                'write',
                'admin'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'secret_scanning_dismissal_requests',
            'Secret scanning alert dismissal requests',
            'Review and manage secret scanning alert dismissal requests',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-secret-scanning-alert-dismissal-requests',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_secrets',
            'Secrets',
            'Manage Actions organization secrets.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-secrets',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_self_hosted_runners',
            'Self-hosted runners',
            'View and manage Actions self-hosted runners available to an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-self-hosted-runners',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'team_discussions',
            'Team discussions',
            'Manage team discussions and related comments.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-team-discussions',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_actions_variables',
            'Variables',
            'Manage Actions organization variables.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-variables',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),
        [GitHubPermissionDefinition]::new(
            'organization_hooks',
            'Webhooks',
            'Manage the post-receive hooks for an organization.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#organization-permissions-for-webhooks',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Organization'
        ),

        # ------------------------------
        # User (Account) Fine-Grained Permission Definitions
        # ------------------------------
        [GitHubPermissionDefinition]::new(
            'blocking',
            'Block another user',
            'View and manage users blocked by the user.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-block-another-user',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'codespaces_user_secrets',
            'Codespaces user secrets',
            'Manage Codespaces user secrets.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-codespaces-user-secrets',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'copilot_messages',
            'Copilot Chat',
            'This application will receive your GitHub ID, your GitHub Copilot Chat session messages ' +
            '(not including messages sent to another application), and timestamps of provided GitHub Copilot ' +
            'Chat session messages. This permission must be enabled for Copilot Extensions.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-copilot-chat',
            @(
                'read'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'copilot_editor_context',
            'Copilot Editor Context',
            'This application will receive bits of Editor Context (e.g. currently opened file) whenever you send it a message through Copilot Chat.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-copilot-editor-context',
            @(
                'read'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'emails',
            'Email addresses',
            "Manage a user's email addresses.",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-email-addresses',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'user_events',
            'Events',
            "View events triggered by a user's activity.",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-events',
            @(
                'read'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'followers',
            'Followers',
            "A user's followers",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-followers',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'gpg_keys',
            'GPG keys',
            "View and manage a user's GPG keys.",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-gpg-keys',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'gists',
            'Gists',
            "Create and modify a user's gists and comments.",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-gists',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'keys',
            'Git SSH keys',
            'Git SSH keys',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-git-ssh-keys',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'interaction_limits',
            'Interaction limits',
            'Interaction limits on repositories',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-interaction-limits',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'knowledge_bases',
            'Knowledge bases',
            'View knowledge bases for a user.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-knowledge-bases',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'user_models',
            'Models',
            'Allows access to GitHub Models.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-models',
            @(
                'read'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'plan',
            'Plan',
            "View a user's plan.",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-plan',
            @(
                'read'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'profile',
            'Profile',
            "Manage a user's profile settings.",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-profile',
            @(
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'git_signing_ssh_public_keys',
            'SSH signing keys',
            "View and manage a user's SSH signing keys.",
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-ssh-signing-keys',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'starring',
            'Starring',
            'List and manage repositories a user is starring.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-starring',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),
        [GitHubPermissionDefinition]::new(
            'watching',
            'Watching',
            'List and change repositories a user is subscribed to.',
            'https://docs.github.com/rest/overview/permissions-required-for-github-apps' +
            '#user-permissions-for-watching',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'User'
        ),

        # ------------------------------
        # Enterprise Fine-Grained Permission Definitions
        # ------------------------------
        [GitHubPermissionDefinition]::new(
            'enterprise_custom_properties',
            'Custom properties',
            'View repository custom properties and administer definitions at the enterprise level.',
            'https://docs.github.com/enterprise-cloud@latest/rest/overview/permissions-required-for-github-apps' +
            '#enterprise-permissions-for-custom-properties',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Enterprise'
        ),
        [GitHubPermissionDefinition]::new(
            'enterprise_custom_org_roles',
            'Enterprise custom organization roles',
            'Create, edit, delete and list custom organization roles at the enterprise level. View system organization roles.',
            'https://docs.github.com/enterprise-cloud@latest/rest/overview/permissions-required-for-github-apps' +
            '#enterprise-permissions-for-enterprise-custom-organization-roles',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Enterprise'
        ),
        [GitHubPermissionDefinition]::new(
            'enterprise_organization_installation_repositories',
            'Enterprise organization installation repositories',
            'Manage repository access of GitHub Apps on Enterprise-owned organizations',
            'https://docs.github.com/enterprise-cloud@latest/rest/overview/permissions-required-for-github-apps' +
            '#enterprise-permissions-for-enterprise-organization-installation-repositories',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Enterprise'
        ),
        [GitHubPermissionDefinition]::new(
            'enterprise_organization_installations',
            'Enterprise organization installations',
            'Manage installation of GitHub Apps on Enterprise-owned organizations',
            'https://docs.github.com/enterprise-cloud@latest/rest/overview/permissions-required-for-github-apps' +
            '#enterprise-permissions-for-enterprise-organization-installations',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Enterprise'
        ),
        [GitHubPermissionDefinition]::new(
            'enterprise_organizations',
            'Enterprise organizations',
            'Create and remove enterprise organizations',
            'https://docs.github.com/enterprise-cloud@latest/rest/overview/permissions-required-for-github-apps' +
            '#enterprise-permissions-for-enterprise-organizations',
            @(
                'write'
            ),
            'Fine-grained',
            'Enterprise'
        ),
        [GitHubPermissionDefinition]::new(
            'enterprise_people',
            'Enterprise people',
            'Manage user access to the enterprise',
            'https://docs.github.com/enterprise-cloud@latest/rest/overview/permissions-required-for-github-apps' +
            '#enterprise-permissions-for-enterprise-people',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Enterprise'
        ),
        [GitHubPermissionDefinition]::new(
            'enterprise_sso',
            'Enterprise single sign-on',
            'View and manage enterprise single sign-on configuration',
            'https://docs.github.com/enterprise-cloud@latest/rest/overview/permissions-required-for-github-apps' +
            '#enterprise-permissions-for-enterprise-single-sign-on',
            @(
                'read',
                'write'
            ),
            'Fine-grained',
            'Enterprise'
        )
    )

    GitHubPermissionDefinition() {}

    GitHubPermissionDefinition(
        [string]$Name,
        [string]$DisplayName,
        [string]$Description,
        [string]$URL,
        [string[]]$Options,
        [string]$Type,
        [string]$Scope
    ) {
        $this.Name = $Name
        $this.DisplayName = $DisplayName
        $this.Description = $Description
        $this.URL = [uri]$URL
        $this.Options = $Options
        $this.Type = $Type
        $this.Scope = $Scope
    }

    [string] ToString() {
        return $this.Name
    }
}

class GitHubPermission : GitHubPermissionDefinition {
    # The value assigned to the permission. Must be one of the options defined in the parent class.
    [string] $Value

    GitHubPermission() : base() {}

    GitHubPermission([string] $Permission, [string] $Value) : base() {
        $this.Name = $Permission
        $this.Value = $Value
        $this.DisplayName = $Permission
        $this.Description = 'Unknown permission - Open issue to add metadata'
        $this.URL = $null
        $this.Options = @()
        $this.Type = 'Unknown'
        $this.Scope = 'Unknown'
    }

    # Create a new list of all known permissions with null values
    static [GitHubPermission[]] NewPermissionList() {
        $tmpList = foreach ($def in [GitHubPermissionDefinition]::List) {
            [GitHubPermission]@{
                Name        = $def.Name
                Value       = $null
                DisplayName = $def.DisplayName
                Description = $def.Description
                URL         = $def.URL
                Options     = $def.Options
                Type        = $def.Type
                Scope       = $def.Scope
            }
        }
        return $tmpList | Sort-Object Scope, DisplayName
    }

    # Create a new list of permissions filtered by installation type with null values
    static [GitHubPermission[]] NewPermissionList([string] $InstallationType) {
        $all = [GitHubPermission]::NewPermissionList()
        $returned = switch ($InstallationType) {
            'Enterprise' { $all | Where-Object { $_.Scope -eq 'Enterprise' } }
            'Organization' { $all | Where-Object { $_.Scope -in @('Organization', 'Repository') } }
            'User' { $all | Where-Object { $_.Scope -in @('Repository') } }
            default { $all }
        }
        return $returned | Sort-Object Scope, DisplayName
    }

    # Create a new list of all permissions with values from a PSCustomObject
    static [GitHubPermission[]] NewPermissionList([pscustomobject] $Object) {
        $all = [GitHubPermission]::NewPermissionList()
        foreach ($name in $Object.PSObject.Properties.Name) {
            $objectValue = $Object.$name
            $knownPermission = $all | Where-Object { $_.Name -eq $name }
            if ($knownPermission) {
                $knownPermission.Value = $objectValue
            } else {
                $all += [GitHubPermission]::new($name, $objectValue)
            }
        }
        return $all | Sort-Object Scope, DisplayName
    }

    # Create a new list of permissions filtered by installation type with values from a PSCustomObject
    static [GitHubPermission[]] NewPermissionList([pscustomobject] $Object, [string] $InstallationType) {
        $all = [GitHubPermission]::NewPermissionList($InstallationType)
        foreach ($name in $Object.PSObject.Properties.Name) {
            $objectValue = $Object.$name
            $knownPermission = $all | Where-Object { $_.Name -eq $name }
            if ($knownPermission) {
                $knownPermission.Value = $objectValue
            } else {
                $all += [GitHubPermission]::new($name, $objectValue)
            }
        }
        return $all | Sort-Object Scope, DisplayName
    }

    # Create a new list of permissions with values from an array of objects (import functionality)
    static [GitHubPermission[]] NewPermissionList([object[]] $Objects) {
        $all = [GitHubPermission]::NewPermissionList()
        foreach ($obj in $Objects) {
            $name = $obj.Name
            $value = $obj.Value
            $knownPermission = $all | Where-Object { $_.Name -eq $name }
            if ($knownPermission) {
                $knownPermission.Value = $value
            } else {
                $all += [GitHubPermission]::new($name, $value)
            }
        }
        return $all | Sort-Object Scope, DisplayName
    }

    # Create a new list of permissions filtered by installation type with values from an array of objects (import functionality)
    static [GitHubPermission[]] NewPermissionList([object[]] $Objects, [string] $InstallationType) {
        $all = [GitHubPermission]::NewPermissionList($InstallationType)
        foreach ($obj in $Objects) {
            $name = $obj.Name
            $value = $obj.Value
            $knownPermission = $all | Where-Object { $_.Name -eq $name }
            if ($knownPermission) {
                $knownPermission.Value = $value
            } else {
                $all += [GitHubPermission]::new($name, $value)
            }
        }
        return $all | Sort-Object Scope, DisplayName
    }
}
