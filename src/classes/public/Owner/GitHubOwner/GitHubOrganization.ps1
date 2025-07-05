class GitHubOrganization : GitHubOwner {
    # The description of the organization.
    # Example: A great organization
    [string] $Description

    # The number of private gists.
    # Example: 81
    [System.Nullable[uint]] $PrivateGists

    # The number of total private repositories.
    # Example: 100
    [System.Nullable[uint]] $TotalPrivateRepos

    # The number of owned private repositories.
    # Example: 100
    [System.Nullable[uint]] $OwnedPrivateRepos

    # The disk usage in kilobytes.
    # Example: 10000
    [System.Nullable[uint]] $DiskUsage

    # The number of collaborators on private repositories.
    # Example: 8
    [System.Nullable[uint]] $Collaborators

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

    # The default permission level members have for organization repositories.
    # Example: read
    [string] $DefaultRepositoryPermission

    # Whether members can create repositories.
    # Example: $true
    [System.Nullable[bool]] $MembersCanCreateRepositories

    # Whether two-factor authentication is required for members.
    # Example: $true
    [System.Nullable[bool]] $TwoFactorRequirementEnabled

    # The type of repositories members can create.
    # Example: all
    [string] $MembersAllowedRepositoryCreationType

    # Whether members can create public repositories.
    # Example: $true
    [System.Nullable[bool]] $MembersCanCreatePublicRepositories

    # Whether members can create private repositories.
    # Example: $true
    [System.Nullable[bool]] $MembersCanCreatePrivateRepositories

    # Whether members can create internal repositories.
    # Example: $true
    [System.Nullable[bool]] $MembersCanCreateInternalRepositories

    # Whether members can invite collaborators to repositories.
    # Example: $true
    [System.Nullable[bool]] $MembersCanInviteCollaborators

    # Whether members can create GitHub Pages sites.
    # Example: $true
    [System.Nullable[bool]] $MembersCanCreatePages

    # Whether members can fork private repositories.
    # Example: $false
    [System.Nullable[bool]] $MembersCanForkPrivateRepositories

    # Whether commit signoff is required on the web.
    # Example: $true
    [System.Nullable[bool]] $RequireWebCommitSignoff

    # Whether deploy keys are enabled for all repositories.
    # Example: $true
    [System.Nullable[bool]] $DeployKeysEnabledForRepositories

    # Whether members can create public GitHub Pages sites.
    # Example: $true
    [System.Nullable[bool]] $MembersCanCreatePublicPages

    # Whether members can create private GitHub Pages sites.
    # Example: $true
    [System.Nullable[bool]] $MembersCanCreatePrivatePages

    # Whether advanced security is enabled by default for new repositories.
    # Example: $true
    [System.Nullable[bool]] $AdvancedSecurityEnabledForNewRepositories

    # Whether Dependabot alerts are enabled by default for new repositories.
    # Example: $true
    [System.Nullable[bool]] $DependabotAlertsEnabledForNewRepositories

    # Whether Dependabot security updates are enabled by default for new repositories.
    # Example: $true
    [System.Nullable[bool]] $DependabotSecurityUpdatesEnabledForNewRepositories

    # Whether the dependency graph is enabled by default for new repositories.
    # Example: $true
    [System.Nullable[bool]] $DependencyGraphEnabledForNewRepositories

    # Whether secret scanning is enabled by default for new repositories.
    # Example: $true
    [System.Nullable[bool]] $SecretScanningEnabledForNewRepositories

    # Whether push protection for secret scanning is enabled by default for new repositories.
    # Example: $true
    [System.Nullable[bool]] $SecretScanningPushProtectionEnabledForNewRepositories

    # Whether a custom link is enabled for push protection in secret scanning.
    # Example: $true
    [System.Nullable[bool]] $SecretScanningPushProtectionCustomLinkEnabled

    # The custom link used for push protection in secret scanning.
    # Example: https://docs.example.com/secrets
    [string] $SecretScanningPushProtectionCustomLink

    # Whether secret scanning validity checks are enabled.
    # Example: $true
    [System.Nullable[bool]] $SecretScanningValidityChecksEnabled

    # The date and time when the organization was archived, if applicable.
    [System.Nullable[datetime]] $ArchivedAt

    GitHubOrganization() {}

    GitHubOrganization([PSCustomObject] $Object, [GitHubContext] $Context) {
        # From GitHubNode
        $this.ID = $Object.id
        $this.NodeID = $Object.node_id

        # From GitHubOwner
        $this.Name = $Object.login
        $this.DisplayName = $Object.name
        $this.AvatarUrl = $Object.avatar_url
        $this.Url = $Object.html_url ?? "https://$($Context.HostName)/$($Object.login)"
        $this.Type = $Object.type
        $this.Company = $Object.company
        $this.Blog = $Object.blog
        $this.Location = $Object.location
        $this.Email = $Object.email
        $this.TwitterUsername = $Object.twitter_username
        $this.PublicRepos = $Object.public_repos
        $this.PublicGists = $Object.public_gists
        $this.Followers = $Object.followers
        $this.Following = $Object.following
        $this.CreatedAt = $Object.created_at
        $this.UpdatedAt = $Object.updated_at
        $this.Plan = [GitHubPlan]::New($Object.plan)

        # From GitHubOrganization
        $this.Description = $Object.description
        $this.PrivateGists = $Object.total_private_gists
        $this.TotalPrivateRepos = $Object.total_private_repos
        $this.OwnedPrivateRepos = $Object.owned_private_repos
        $this.DiskUsage = $Object.disk_usage
        $this.Collaborators = $Object.collaborators
        $this.IsVerified = $Object.is_verified
        $this.HasOrganizationProjects = $Object.has_organization_projects
        $this.HasRepositoryProjects = $Object.has_repository_projects
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
        $this.ArchivedAt = $Object.archived_at
    }

    [string] ToString() {
        return $this.Name
    }
}
