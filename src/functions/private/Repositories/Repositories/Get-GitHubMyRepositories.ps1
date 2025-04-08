filter Get-GitHubMyRepositories {
    <#
        .SYNOPSIS
        List repositories for the authenticated user

        .DESCRIPTION
        Lists repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.
        The authenticated user has explicit permission to access repositories they own, repositories where
        they are a collaborator, and repositories that they can access through an organization membership.

        .EXAMPLE
        Get-GitHubMyRepositories

        Gets the repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Visibility 'private'

        Gets the private repositories for the authenticated user.

        .EXAMPLE
        $param = @{
            Visibility = 'public'
            Affiliation = 'owner','collaborator'
            Sort = 'created'
            Direction = 'asc'
            PerPage = 100
            Since = (Get-Date).AddYears(-5)
            Before = (Get-Date).AddDays(-1)
        }
        Get-GitHubMyRepositories @param

        Gets the public repositories for the authenticated user that are owned by the authenticated user
        or that the authenticated user has been added to as a collaborator. The results are sorted by
        creation date in ascending order and the results are limited to 100 repositories. The results
        are limited to repositories created between 5 years ago and 1 day ago.

        .EXAMPLE
        Get-GitHubMyRepositories -Type 'forks'

        Gets the forked repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Type 'sources'

        Gets the non-forked repositories for the authenticated user.

        .EXAMPLE
        Get-GitHubMyRepositories -Type 'member'

        Gets the repositories for the authenticated user that are owned by an organization.

        .NOTES
        https://docs.github.com/rest/repos/repos#list-repositories-for-the-authenticated-user

    #>
    [CmdletBinding(DefaultParameterSetName = 'Type')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Private function, not exposed to user.')]
    param(
        # Limit results to repositories with the specified visibility.
        [Parameter(
            ParameterSetName = 'Aff-Vis'
        )]
        [ValidateSet('all', 'public', 'private')]
        [string] $Visibility = 'all',

        # Comma-separated list of values. Can include:
        # - owner: Repositories that are owned by the authenticated user.
        # - collaborator: Repositories that the user has been added to as a collaborator.
        # - organization_member: Repositories that the user has access to through being a member of an organization.
        #   This includes every repository on every team that the user is on.
        # Default: owner, collaborator, organization_member
        [Parameter(
            ParameterSetName = 'Aff-Vis'
        )]
        [ValidateSet('owner', 'collaborator', 'organization_member')]
        [string[]] $Affiliation = @('owner', 'collaborator', 'organization_member'),

        # Specifies the types of repositories you want returned.
        [Parameter(
            ParameterSetName = 'Type'
        )]
        [ValidateSet('all', 'owner', 'public', 'private', 'member')]
        [string] $Type = 'all',

        # The property to sort the results by.
        [Parameter()]
        [ValidateSet('created', 'updated', 'pushed', 'full_name')]
        [string] $Sort = 'created',

        # The order to sort by.
        # Default: asc when using full_name, otherwise desc.
        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string] $Direction,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # Only show repositories updated after the given time.
        [Parameter()]
        [datetime] $Since,

        # Only show repositories updated before the given time.
        [Parameter()]
        [datetime] $Before,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $body = @{
            sort      = $Sort
            direction = $Direction
            per_page  = $PerPage
        }
        if ($PSBoundParameters.ContainsKey('Since')) {
            $body['since'] = $Since.ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        if ($PSBoundParameters.ContainsKey('Before')) {
            $body['before'] = $Before.ToString('yyyy-MM-ddTHH:mm:ssZ')
        }
        Write-Debug "ParamSet: [$($PSCmdlet.ParameterSetName)]"
        switch ($PSCmdlet.ParameterSetName) {
            'Aff-Vis' {
                $body['affiliation'] = $Affiliation -join ','
                $body['visibility'] = $Visibility
            }
            'Type' {
                $body['type'] = $Type
            }
        }

        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = '/user/repos'
            body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response | ForEach-Object {
                [GitHubRepository]@{
                    ID          = $_.id
                    NodeID      = $_.node_id
                    Name        = $_.name
                    FullName    = $_.full_name
                    Owner       = [GitHubOrganization]@{
                        ID     = $_.owner.id
                        NodeID = $_.owner.node_id
                        Name   = $_.owner.login
                    }
                    Visibility  = $_.visibility
                    Description = $_.description
                    Url         = $_.html_url
                    IsFork      = $_.fork
                    IsArchived  = $_.archived
                    IsDisabled  = $_.disabled
                    CreatedAt   = $_.created_at
                    UpdatedAt   = $_.created_at
                    PushedAt    = $_.pushed_at
                    Topics      = $_.topics
                    Permissions = [GitHubRepositoryPermissions]@{
                        Admin    = $_.permissions.admin
                        Maintain = $_.permissions.maintain
                        Push     = $_.permissions.push
                        Triage   = $_.permissions.triage
                        Pull     = $_.permissions.pull
                    }
                }
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
