filter Set-GitHubOrganization {
    <#
        .SYNOPSIS
        Update an organization

        .DESCRIPTION
        **Parameter Deprecation Notice:** GitHub will replace and discontinue `members_allowed_repository_creation_type`
        in favor of more granular permissions. The new input parameters are `members_can_create_public_repositories`,
        `members_can_create_private_repositories` for all organizations and `members_can_create_internal_repositories`
        for organizations associated with an enterprise account using GitHub Enterprise Cloud or GitHub Enterprise Server
        2.20+. For more information, see the [blog post](https://developer.github.com/changes/2019-12-03-internal-visibility-changes).

        Enables an authenticated organization owner with the `admin:org` scope or the `repo` scope to update the organization's
        profile and member privileges.

        .EXAMPLE
        Set-GitHubOrganization -Organization 'GitHub' -Blog 'https://github.blog'

        Sets the blog URL for the organization 'GitHub' to '<https://github.blog>'.

        .EXAMPLE
        $param = @{
            Organization = 'GitHub'
            MembersCanCreatePublicRepositories = $true
            MembersCanCreatePrivateRepositories = $true
            MembersCanCreateInternalRepositories = $true
        }
        Set-GitHubOrganization @param

        Sets the repository creation permissions for the organization 'GitHub' to allow all members to create public, private,
        and internal repositories.

        .NOTES
        [Update an organization](https://docs.github.com/rest/orgs/orgs#update-an-organization)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '',
        Justification = 'Long parameter names'
    )]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [Alias('org')]
        [Alias('owner')]
        [Alias('login')]
        [string] $Organization,

        # Billing email address. This address is not publicized.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('billing_email')]
        [string] $BillingEmail,

        # The company name.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Company,

        # The publicly visible email address.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Email,

        # The Twitter username of the company.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('twitter_username')]
        [string] $TwitterUsername,

        # The location.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Location,

        # The shorthand name of the company.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Name,

        # The description of the company.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description,

        # Whether an organization can use organization projects.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('has_organization_projects')]
        [bool] $HasOrganizationProjects,

        # Whether repositories that belong to the organization can use repository projects.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('has_repository_projects')]
        [bool] $HasRepositoryProjects,

        # Default permission level members have for organization repositories.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('default_repository_permission')]
        [ValidateSet('read', 'write', 'admin', 'none')]
        [string] $DefaultRepositoryPermission,

        # Whether of non-admin organization members can create repositories.
        # Note: A parameter can override this parameter. See members_allowed_repository_creation_type in this table for details.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_can_create_repositories')]
        [bool] $MembersCanCreateRepositories = $true,

        # Whether organization members can create internal repositories, which are visible to all enterprise members.
        # You can only allow members to create internal repositories if your organization is associated with an enterprise
        # account using GitHub Enterprise Cloud or GitHub Enterprise Server 2.20+. For more information, see
        # "Restricting repository creation in your organization" in the GitHub Help documentation.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_can_create_internal_repositories')]
        [bool] $MembersCanCreateInternalRepositories,

        # Whether organization members can create private repositories, which are visible to organization members with permission.
        # For more information, see "Restricting repository creation in your organization" in the GitHub Help documentation.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_can_create_private_repositories')]
        [bool] $MembersCanCreatePrivateRepositories,

        # Whether organization members can create public repositories, which are visible to anyone. For more information,
        # see 'Restricting repository creation in your organization' in the GitHub Help documentation.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_can_create_public_repositories')]
        [bool] $MembersCanCreatePublicRepositories,

        # Specifies which types of repositories non-admin organization members can create. private is only available to
        # repositories that are part of an organization on GitHub Enterprise Cloud. Note: This parameter is deprecated and
        # will be removed in the future. Its return value ignores internal repositories. Using this parameter overrides values
        # set in members_can_create_repositories. See the parameter deprecation notice in the operation description for details.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_allowed_repository_creation_type')]
        [ValidateSet('all', 'private', 'none')]
        [string] $MembersAllowedRepositoryCreationType,

        # Whether organization members can create GitHub Pages sites. Existing published sites will not be impacted.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_can_create_pages')]
        [bool] $MembersCanCreatePages = $true,

        # Whether organization members can create public GitHub Pages sites. Existing published sites will not be impacted.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_can_create_public_pages')]
        [bool] $MembersCanCreatePublicPages = $true,

        # Whether organization members can create private GitHub Pages sites. Existing published sites will not be impacted.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_can_create_private_pages')]
        [bool] $MembersCanCreatePrivatePages = $true,

        # Whether organization members can fork private organization repositories.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('members_can_fork_private_repositories')]
        [bool] $MembersCanForkPrivateRepositories = $false,

        # Whether contributors to organization repositories are required to sign off on commits they make through GitHub's web interface.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('web_commit_signoff_required')]
        [bool] $WebCommitSignoffRequired = $false,

        # Path to the organization's blog.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Blog,

        # Whether GitHub Advanced Security is automatically enabled for new repositories.
        # To use this parameter, you must have admin permissions for the repository or be an owner or security manager for
        # the organization that owns the repository. For more information, see "Managing security managers in your organization."
        # You can check which security and analysis features are currently enabled by using a GET /orgs/{org} request.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('advanced_security_enabled_for_new_repositories')]
        [bool] $AdvancedSecurityEnabledForNewRepositories = $false,

        # Whether Dependabot alerts is automatically enabled for new repositories.
        # To use this parameter, you must have admin permissions for the repository or be an owner or security manager for
        # the organization that owns the repository. For more information, see "Managing security managers in your organization."
        # You can check which security and analysis features are currently enabled by using a GET /orgs/{org} request.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('dependabot_alerts_enabled_for_new_repositories')]
        [bool] $DependabotAlertsEnabledForNewRepositories = $false,

        # Whether Dependabot security updates is automatically enabled for new repositories.
        # To use this parameter, you must have admin permissions for the repository or be an owner or security manager for
        # the organization that owns the repository. For more information, see "Managing security managers in your organization."
        # You can check which security and analysis features are currently enabled by using a GET /orgs/{org} request.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('dependabot_security_updates_enabled_for_new_repositories')]
        [bool] $DependabotSecurityUpdatesEnabledForNewRepositories = $false,

        # Whether dependency graph is automatically enabled for new repositories.
        # To use this parameter, you must have admin permissions for the repository or be an owner or security manager for
        # the organization that owns the repository. For more information, see "Managing security managers in your organization."
        # You can check which security and analysis features are currently enabled by using a GET /orgs/{org} request.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('dependency_graph_enabled_for_new_repositories')]
        [bool] $DependencyGraphEnabledForNewRepositories = $false,

        # Whether secret scanning is automatically enabled for new repositories.
        # To use this parameter, you must have admin permissions for the repository or be an owner or security manager for
        # the organization that owns the repository. For more information, see "Managing security managers in your organization."
        # You can check which security and analysis features are currently enabled by using a GET /orgs/{org} request.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('secret_scanning_enabled_for_new_repositories')]
        [bool] $SecretScanningEnabledForNewRepositories = $false,

        # Whether secret scanning push protection is automatically enabled for new repositories.
        # To use this parameter, you must have admin permissions for the repository or be an owner or security manager for
        # the organization that owns the repository. For more information, see "Managing security managers in your organization."
        # You can check which security and analysis features are currently enabled by using a GET /orgs/{org} request.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('secret_scanning_push_protection_enabled_for_new_repositories')]
        [bool] $SecretScanningPushProtectionEnabledForNewRepositories = $false,

        # Whether a custom link is shown to contributors who are blocked from pushing a secret by push protection.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('secret_scanning_push_protection_custom_link_enabled')]
        [bool] $SecretScanningPushProtectionCustomLinkEnabled = $false,

        # If secret_scanning_push_protection_custom_link_enabled is true, the URL that will be displayed to contributors who
        # are blocked from pushing a secret.
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('secret_scanning_push_protection_custom_link')]
        [string] $SecretScanningPushProtectionCustomLink,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner: [$Owner]"
    }

    process {
        try {
            $body = @{
                billing_email                                                = $BillingEmail
                company                                                      = $Company
                email                                                        = $Email
                twitter_username                                             = $TwitterUsername
                location                                                     = $Location
                name                                                         = $Name
                description                                                  = $Description
                has_organization_projects                                    = $HasOrganizationProjects
                has_repository_projects                                      = $HasRepositoryProjects
                default_repository_permission                                = $DefaultRepositoryPermission
                members_can_create_repositories                              = $MembersCanCreateRepositories ? $MembersCanCreateRepositories : $true
                members_can_create_internal_repositories                     = $MembersCanCreateInternalRepositories
                members_can_create_private_repositories                      = $MembersCanCreatePrivateRepositories
                members_can_create_public_repositories                       = $MembersCanCreatePublicRepositories
                members_allowed_repository_creation_type                     = $MembersAllowedRepositoryCreationType
                members_can_create_pages                                     = $MembersCanCreatePages ? $MembersCanCreatePages : $true
                members_can_create_public_pages                              = $MembersCanCreatePublicPages ? $MembersCanCreatePublicPages : $true
                members_can_create_private_pages                             = $MembersCanCreatePrivatePages ? $MembersCanCreatePrivatePages : $true
                members_can_fork_private_repositories                        = $MembersCanForkPrivateRepositories ? $MembersCanForkPrivateRepositories : $false
                web_commit_signoff_required                                  = $WebCommitSignoffRequired ? $WebCommitSignoffRequired : $false
                blog                                                         = $Blog
                advanced_security_enabled_for_new_repositories               = $AdvancedSecurityEnabledForNewRepositories ? $AdvancedSecurityEnabledForNewRepositories : $false
                dependabot_alerts_enabled_for_new_repositories               = $DependabotAlertsEnabledForNewRepositories ? $DependabotAlertsEnabledForNewRepositories : $false
                dependabot_security_updates_enabled_for_new_repositories     = $DependabotSecurityUpdatesEnabledForNewRepositories ? $DependabotSecurityUpdatesEnabledForNewRepositories : $false
                dependency_graph_enabled_for_new_repositories                = $DependencyGraphEnabledForNewRepositories ? $DependencyGraphEnabledForNewRepositories : $false
                secret_scanning_enabled_for_new_repositories                 = $SecretScanningEnabledForNewRepositories ? $SecretScanningEnabledForNewRepositories : $false
                secret_scanning_push_protection_enabled_for_new_repositories = $SecretScanningPushProtectionEnabledForNewRepositories ? $SecretScanningPushProtectionEnabledForNewRepositories : $false
                secret_scanning_push_protection_custom_link_enabled          = $SecretScanningPushProtectionCustomLinkEnabled ? $SecretScanningPushProtectionCustomLinkEnabled : $false
                secret_scanning_push_protection_custom_link                  = $SecretScanningPushProtectionCustomLink
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/orgs/$Organization"
                Method      = 'PATCH'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess("organization [$Organization]", 'Set')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
