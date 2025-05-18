filter Update-GitHubOrganization {
    <#
        .SYNOPSIS
        Update an organization

        .DESCRIPTION
        Enables an authenticated organization owner with the `admin:org` scope or the `repo` scope to update the organization's
        profile and member privileges.

        .EXAMPLE
        Update-GitHubOrganization -Organization 'GitHub' -Blog 'https://github.blog'

        Sets the blog URL for the organization 'GitHub' to '<https://github.blog>'.

        .EXAMPLE
        $param = @{
            Organization                         = 'GitHub'
            MembersCanCreatePublicRepositories   = $true
            MembersCanCreatePrivateRepositories  = $true
            MembersCanCreateInternalRepositories = $true
        }
        Update-GitHubOrganization @param

        Sets the repository creation permissions for the organization 'GitHub' to allow all members to create public, private,
        and internal repositories.

        .INPUTS
        GitHubOrganization

        .OUTPUTS
        GitHubOrganization

        .LINK
        https://psmodule.io/GitHub/Functions/Organization/Update-GitHubOrganization

        .LINK
        [Update an organization](https://docs.github.com/rest/orgs/orgs#update-an-organization)
    #>
    [OutputType([GitHubOrganization])]
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
        [string] $Name,

        # Billing email address. This address is not publicized.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $BillingEmail,

        # The company name.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Company,

        # The publicly visible email address.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Email,

        # The Twitter username of the company.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $TwitterUsername,

        # The location.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Location,

        # The shorthand name of the company.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $NewName,

        # The description of the company.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Description,

        # Whether an organization can use organization projects.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $HasOrganizationProjects,

        # Whether repositories that belong to the organization can use repository projects.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $HasRepositoryProjects,

        # Default permission level members have for organization repositories.
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Read', 'Write', 'Admin', 'None')]
        [string] $DefaultRepositoryPermission,

        # Whether of non-admin organization members can create repositories.
        # Note: A parameter can override this parameter. See members_allowed_repository_creation_type in this table for details.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $MembersCanCreateRepositories,

        # Whether organization members can create internal repositories, which are visible to all enterprise members.
        # You can only allow members to create internal repositories if your organization is associated with an enterprise
        # account using GitHub Enterprise Cloud or GitHub Enterprise Server 2.20+. For more information, see
        # "Restricting repository creation in your organization" in the GitHub Help documentation.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $MembersCanCreateInternalRepositories,

        # Whether organization members can create private repositories, which are visible to organization members with permission.
        # For more information, see "Restricting repository creation in your organization" in the GitHub Help documentation.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $MembersCanCreatePrivateRepositories,

        # Whether organization members can create public repositories, which are visible to anyone. For more information,
        # see 'Restricting repository creation in your organization' in the GitHub Help documentation.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $MembersCanCreatePublicRepositories,

        # Whether organization members can create GitHub Pages sites. Existing published sites will not be impacted.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $MembersCanCreatePages,

        # Whether organization members can create public GitHub Pages sites. Existing published sites will not be impacted.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $MembersCanCreatePublicPages,

        # Whether organization members can create private GitHub Pages sites. Existing published sites will not be impacted.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $MembersCanCreatePrivatePages,

        # Whether organization members can fork private organization repositories.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $MembersCanForkPrivateRepositories,

        # Whether contributors to organization repositories are required to sign off on commits they make through GitHub's web interface.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $WebCommitSignoffRequired,

        # Path to the organization's blog.
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $Blog,

        # Whether secret scanning push protection is automatically enabled for new repositories.
        # To use this parameter, you must have admin permissions for the repository or be an owner or security manager for
        # the organization that owns the repository. For more information, see "Managing security managers in your organization."
        # You can check which security and analysis features are currently enabled by using a GET /orgs/{org} request.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $SecretScanningPushProtectionEnabledForNewRepositories,

        # Whether a custom link is shown to contributors who are blocked from pushing a secret by push protection.
        [Parameter(ValueFromPipelineByPropertyName)]
        [bool] $SecretScanningPushProtectionCustomLinkEnabled,

        # If secret_scanning_push_protection_custom_link_enabled is true, the URL that will be displayed to contributors who
        # are blocked from pushing a secret.
        [Parameter(ValueFromPipelineByPropertyName)]
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
    }

    process {
        $body = @{
            name                                                         = $NewName
            billing_email                                                = $BillingEmail
            blog                                                         = $Blog
            company                                                      = $Company
            description                                                  = $Description
            email                                                        = $Email
            location                                                     = $Location
            twitter_username                                             = $TwitterUsername
            has_organization_projects                                    = $PSBoundParameters.ContainsKey('HasOrganizationProjects') ? $HasOrganizationProjects : $null
            has_repository_projects                                      = $PSBoundParameters.ContainsKey('HasRepositoryProjects') ? $HasRepositoryProjects : $null
            default_repository_permission                                = $PSBoundParameters.ContainsKey('DefaultRepositoryPermission') ? $DefaultRepositoryPermission.ToLower() : $null
            members_can_create_repositories                              = $PSBoundParameters.ContainsKey('MembersCanCreateRepositories') ? $MembersCanCreateRepositories : $null
            members_can_create_internal_repositories                     = $PSBoundParameters.ContainsKey('MembersCanCreateInternalRepositories') ? $MembersCanCreateInternalRepositories : $null
            members_can_create_private_repositories                      = $PSBoundParameters.ContainsKey('MembersCanCreatePrivateRepositories') ? $MembersCanCreatePrivateRepositories : $null
            members_can_create_public_repositories                       = $PSBoundParameters.ContainsKey('MembersCanCreatePublicRepositories') ? $MembersCanCreatePublicRepositories : $null
            members_can_create_pages                                     = $PSBoundParameters.ContainsKey('MembersCanCreatePages') ? $MembersCanCreatePages : $null
            members_can_create_public_pages                              = $PSBoundParameters.ContainsKey('MembersCanCreatePublicPages') ? $MembersCanCreatePublicPages : $null
            members_can_create_private_pages                             = $PSBoundParameters.ContainsKey('MembersCanCreatePrivatePages') ? $MembersCanCreatePrivatePages : $null
            members_can_fork_private_repositories                        = $PSBoundParameters.ContainsKey('MembersCanForkPrivateRepositories') ? $MembersCanForkPrivateRepositories : $null
            web_commit_signoff_required                                  = $PSBoundParameters.ContainsKey('WebCommitSignoffRequired') ? $WebCommitSignoffRequired : $null
            secret_scanning_push_protection_enabled_for_new_repositories = $PSBoundParameters.ContainsKey('SecretScanningPushProtectionEnabledForNewRepositories') ? $SecretScanningPushProtectionEnabledForNewRepositories : $null
            secret_scanning_push_protection_custom_link_enabled          = $PSBoundParameters.ContainsKey('SecretScanningPushProtectionCustomLinkEnabled') ? $SecretScanningPushProtectionCustomLinkEnabled : $null
            secret_scanning_push_protection_custom_link                  = $PSBoundParameters.ContainsKey('SecretScanningPushProtectionCustomLink') ? $SecretScanningPushProtectionCustomLink : $null
        }
        $body | Remove-HashtableEntry -NullOrEmptyValues

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = "/orgs/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("organization [$Name]", 'Set')) {
            Invoke-GitHubAPI @inputObject | ForEach-Object {
                [GitHubOrganization]::new($_.Response)
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
