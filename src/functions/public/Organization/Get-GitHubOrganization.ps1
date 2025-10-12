filter Get-GitHubOrganization {
    <#
        .SYNOPSIS
        List organization

        .DESCRIPTION
        List organizations for the authenticated user - if no parameters are provided.
        List organizations for a user - if a username is provided.
        Lists all organizations, in the order that they were created on GitHub - if '-All' is provided.
        Get an organization - if a organization name is provided.

        .EXAMPLE
        ```pwsh
        Get-GitHubOrganization
        ```

        List all organizations for the authenticated user.

        .EXAMPLE
        ```pwsh
        Get-GitHubOrganization -Username 'octocat'
        ```

        List public organizations for a specific user.

        .EXAMPLE
        ```pwsh
        Get-GitHubOrganization -All -Since 142951047
        ```

        List all organizations made after an ID.

        .EXAMPLE
        ```pwsh
        Get-GitHubOrganization -Name 'PSModule'
        ```

        Get a specific organization.

        .EXAMPLE
        ```pwsh
        Get-GitHubOrganization -Enterprise 'msx'
        ```

        Get the organizations belonging to an Enterprise.

        .OUTPUTS
        GitHubOrganization

        .LINK
        https://psmodule.io/GitHub/Functions/Organization/Get-GitHubOrganization
    #>
    [OutputType([GitHubOrganization])]
    [CmdletBinding(DefaultParameterSetName = 'List all organizations for the authenticated user')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'All', Justification = 'Required for parameter set')]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Get a specific organization',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # The handle for the GitHub user account.
        [Parameter(
            Mandatory,
            ParameterSetName = 'List public organizations for a specific user',
            ValueFromPipelineByPropertyName
        )]
        [Alias('User')]
        [string] $Username,

        # The Enterprise slug to get organizations from.
        [Parameter(
            Mandatory,
            ParameterSetName = 'Get the organizations belonging to an Enterprise',
            ValueFromPipelineByPropertyName
        )]
        [string] $Enterprise,

        # List all organizations. Use '-Since' to start at a specific organization ID.
        [Parameter(
            Mandatory,
            ParameterSetName = 'List all organizations on the tenant'
        )]
        [switch] $All,

        # A organization ID. Only return organizations with an ID greater than this ID.
        [Parameter(ParameterSetName = 'List all organizations on the tenant')]
        [int] $Since = 0,

        # The number of results per page (max 100).
        [Parameter(ParameterSetName = 'List all organizations on the tenant')]
        [Parameter(ParameterSetName = 'List all organizations for the authenticated user')]
        [System.Nullable[int]] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Get a specific organization' {
                Get-GitHubOrganizationByName -Name $Name -Context $Context
            }
            'List public organizations for a specific user' {
                Get-GitHubUserOrganization -Username $Username -Context $Context
            }
            'Get the organizations belonging to an Enterprise' {
                Get-GitHubAppInstallableOrganization -Enterprise $Enterprise -Context $Context
            }
            'List all organizations on the tenant' {
                Get-GitHubAllOrganization -Since $Since -PerPage $PerPage -Context $Context
            }
            'List all organizations for the authenticated user' {
                Get-GitHubOrganizationListForAuthUser -PerPage $PerPage -Context $Context
            }
            default {
                Write-Error "Invalid parameter set name: $($PSCmdlet.ParameterSetName)"
                throw "Unsupported parameter set name: $($PSCmdlet.ParameterSetName)"
            }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
