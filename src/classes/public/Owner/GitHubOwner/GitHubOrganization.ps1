class GitHubOrganization : GitHubOwner {
    # The description of the organization.
    # Example: A great organization
    [string] $Description

    # Whether the organization is verified.
    # Example: $true
    [System.Nullable[bool]] $IsVerified

    # Whether organization projects are enabled.
    # Example: $true
    [System.Nullable[bool]] $HasOrganizationProjects

    # Whether repository projects are enabled.
    # Example: $true
    [System.Nullable[bool]] $HasRepositoryProjects

    # The billing email address for the organization.
    # Example: org@example.com
    [string] $BillingEmail

    # The date and time when the organization was archived, if applicable.
    [System.Nullable[datetime]] $ArchivedAt

    # Simple parameterless constructor
    GitHubOrganization() {}

    # Creates an object from a hashtable of key-value pairs.
    GitHubOrganization([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates an object from a PSCustomObject.
    GitHubOrganization([PSCustomObject]$Object) {
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id
        $this.Name = $Object.login
        $this.DisplayName = $Object.name
        $this.AvatarUrl = $Object.avatar_url
        $this.Url = $Object.html_url
        $this.Type = $Object.type
        $this.Company = $Object.company
        $this.Location = $Object.location
        $this.Email = $Object.email
        $this.TwitterUsername = $Object.twitter_username
        $this.Blog = $Object.blog
        $this.Followers = $Object.followers
        $this.Following = $Object.following
        $this.PublicRepos = $Object.public_repos
        $this.PublicGists = $Object.public_gists
        $this.PrivateGists = $Object.total_private_gists
        $this.TotalPrivateRepos = $Object.total_private_repos
        $this.OwnedPrivateRepos = $Object.owned_private_repos
        $this.DiskUsage = $Object.disk_usage
        $this.Collaborators = $Object.collaborators
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.Plan = [GitHubPlan]::New($Object.plan)

        ## Organization specific properties
        $this.Description = $Object.description
        $this.IsVerified = $Object.is_verified
        $this.HasOrganizationProjects = $Object.has_organization_projects
        $this.HasRepositoryProjects = $Object.has_repository_projects
        $this.ArchivedAt = $Object.archived_at
        $this.BillingEmail = $Object.billing_email
        $this.DefaultRepositoryPermission = $Object.default_repository_permission
        $this.MembersCanCreateRepositories = $Object.members_can_create_repositories
        $this.TwoFactorRequirementEnabled = $Object.two_factor_requirement_enabled
        $this.MembersAllowedRepositoryCreationType = $Object.members_allowed_repository_creation_type
        $this.MembersCanCreatePublicRepositories = $Object.members_can_create_public_repositories
        $this.MembersCanCreatePrivateRepositories = $Object.members_can_create_private_repositories
        $this.MembersCanCreateInternalRepositories = $Object.members_can_create_internal_repositories
        $this.MembersCanInviteCollaborators = $Object.members_can_invite_collaborators
        $this.MembersCanCreatePages = $Object.members_can_create_pages
        $this.MembersCanForkPrivateRepositories = $Object.members_can_fork_private_repositories
        $this.RequireWebCommitSignoff = $Object.web_commit_signoff_required
        $this.DeployKeysEnabledForRepositories = $Object.deploy_keys_enabled_for_repositories
        $this.MembersCanCreatePublicPages = $Object.members_can_create_public_pages
        $this.MembersCanCreatePrivatePages = $Object.members_can_create_private_pages
        $this.AdvancedSecurityEnabledForNewRepositories = $Object.advanced_security_enabled_for_new_repositories
        $this.DependabotAlertsEnabledForNewRepositories = $Object.dependabot_alerts_enabled_for_new_repositories
        $this.DependabotSecurityUpdatesEnabledForNewRepositories = $Object.dependabot_security_updates_enabled_for_new_repositories
        $this.DependencyGraphEnabledForNewRepositories = $Object.dependency_graph_enabled_for_new_repositories
        $this.SecretScanningEnabledForNewRepositories = $Object.secret_scanning_enabled_for_new_repositories
        $this.SecretScanningPushProtectionEnabledForNewRepositories = $Object.secret_scanning_push_protection_enabled_for_new_repositories
        $this.SecretScanningPushProtectionCustomLinkEnabled = $Object.secret_scanning_push_protection_custom_link_enabled
        $this.SecretScanningPushProtectionCustomLink = $Object.secret_scanning_push_protection_custom_link
        $this.SecretScanningValidityChecksEnabled = $Object.secret_scanning_validity_checks_enabled
    }

    [string] ToString() {
        return $this.Name
    }
}
