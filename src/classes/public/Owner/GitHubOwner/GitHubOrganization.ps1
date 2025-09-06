class GitHubOrganization : GitHubOwner {
    # The email of the account.
    # Example: octocat@github.com
    [string] $Email

    # The Twitter username.
    # Example: monalisa
    [string] $TwitterUsername

    # The user's plan.
    # Includes: Name, Collaborators, PrivateRepos, Space
    [GitHubPlan] $Plan

    # The number of public repositories.
    # Example: 2
    [System.Nullable[uint]] $PublicRepos

    # The number of public gists.
    # Example: 1
    [System.Nullable[uint]] $PublicGists

    # The number of followers.
    # Example: 20
    [System.Nullable[uint]] $Followers

    # The number of accounts this account is following.
    # Example: 0
    [System.Nullable[uint]] $Following

    # The number of private gists.
    # Example: 81
    [System.Nullable[uint]] $PrivateGists

    # The number of total private repositories.
    # Example: 100
    [System.Nullable[uint]] $TotalPrivateRepos

    # The number of owned private repositories.
    # Example: 100
    [System.Nullable[uint]] $OwnedPrivateRepos

    # The size of the organization's repositories, in bytes.
    # Example: 10240000
    [System.Nullable[uint]] $Size

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
    [System.Nullable[bool]] $RequiresTwoFactorAuthentication

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

    static [hashtable] $PropertyToGraphQLMap = @{
        ArchivedAt      = 'archivedAt'
        AvatarUrl       = 'avatarUrl'
        CreatedAt       = 'createdAt'
        Description     = 'description'
        DisplayName     = 'name'
        Email           = 'email'
        ID              = 'databaseId'
        Location        = 'location'
        Name            = 'login'
        NodeID          = 'id'
        IsVerified      = 'isVerified'
        # MembersCanForkPrivateRepositories = 'membersCanForkPrivateRepositories'
        # RequiresTwoFactorAuthentication   = 'requiresTwoFactorAuthentication'
        TwitterUsername = 'twitterUsername'
        UpdatedAt       = 'updatedAt'
        Url             = 'url'
        # RequireWebCommitSignoff = 'webCommitSignoffRequired'
        Website         = 'websiteUrl'
    }

    GitHubOrganization() {}

    GitHubOrganization([PSCustomObject] $Object, [GitHubContext] $Context) {
        # From GitHubNode
        $this.ID = $Object.databaseId ?? $Object.id
        $this.NodeID = $Object.node_id ?? $Object.id

        # From GitHubOwner
        $this.Name = $Object.login
        $this.DisplayName = $Object.name
        $this.AvatarUrl = $Object.avatar_url ?? $Object.avatarUrl
        $this.Url = $Object.html_url ?? $Object.url ?? "https://$($Context.HostName)/$($Object.login)"
        $this.Type = $Object.type ?? 'Organization'
        $this.Location = $Object.location
        $this.Description = $Object.description
        $this.Website = $Object.website ?? $Object.blog
        $this.CreatedAt = $Object.created_at ?? $Object.createdAt
        $this.UpdatedAt = $Object.updated_at ?? $Object.updatedAt

        # From GitHubOrganization
        $this.Email = $Object.email
        $this.TwitterUsername = $Object.twitter_username ?? $Object.twitterUsername
        $this.Plan = [GitHubPlan]::New($Object.plan)
        $this.PublicRepos = $Object.public_repos
        $this.PublicGists = $Object.public_gists
        $this.Followers = $Object.followers
        $this.Following = $Object.following
        $this.PrivateGists = $Object.total_private_gists
        $this.TotalPrivateRepos = $Object.total_private_repos
        $this.OwnedPrivateRepos = $Object.owned_private_repos
        $this.Size = $Object.disk_usage * 1KB
        $this.Collaborators = $Object.collaborators
        $this.IsVerified = $Object.is_verified ?? $Object.isVerified
        $this.HasOrganizationProjects = $Object.has_organization_projects
        $this.HasRepositoryProjects = $Object.has_repository_projects
        $this.BillingEmail = $Object.billing_email
        $this.DefaultRepositoryPermission = $Object.default_repository_permission
        $this.MembersCanCreateRepositories = $Object.members_can_create_repositories
        $this.RequiresTwoFactorAuthentication = $Object.two_factor_requirement_enabled ?? $Object.requiresTwoFactorAuthentication
        $this.MembersAllowedRepositoryCreationType = $Object.members_allowed_repository_creation_type
        $this.MembersCanCreatePublicRepositories = $Object.members_can_create_public_repositories
        $this.MembersCanCreatePrivateRepositories = $Object.members_can_create_private_repositories
        $this.MembersCanCreateInternalRepositories = $Object.members_can_create_internal_repositories
        $this.MembersCanInviteCollaborators = $Object.members_can_invite_collaborators
        $this.MembersCanCreatePages = $Object.members_can_create_pages
        $this.MembersCanForkPrivateRepositories = $Object.members_can_fork_private_repositories ?? $Object.membersCanForkPrivateRepositories
        $this.RequireWebCommitSignoff = $Object.web_commit_signoff_required ?? $Object.webCommitSignoffRequired
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
        $this.ArchivedAt = $Object.archived_at ?? $Object.archivedAt
    }

    [string] ToString() {
        return $this.Name
    }
}
