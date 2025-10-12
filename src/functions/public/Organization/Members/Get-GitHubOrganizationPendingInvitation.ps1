function Get-GitHubOrganizationPendingInvitation {
    <#
        .SYNOPSIS
        List pending organization invitations

        .DESCRIPTION
        The return hash contains a `role` field which refers to the Organization
        Invitation role and will be one of the following values: `direct_member`, `admin`,
        `billing_manager`, or `hiring_manager`. If the invitee is not a GitHub
        member, the `login` field in the return hash will be `null`.

        .EXAMPLE
        ```pwsh
        Get-GitHubOrganizationPendingInvitation -Organization 'github'
        ```

        List all pending organization invitations for the organization `github`.

        .EXAMPLE
        ```pwsh
        Get-GitHubOrganizationPendingInvitation -Organization 'github' -Role 'admin'
        ```

        List all pending organization invitations for the organization `github` with the role `admin`.

        .NOTES
        [List pending organization invitations](https://docs.github.com/rest/orgs/members#list-pending-organization-invitations)

        .LINK
        https://psmodule.io/GitHub/Functions/Organization/Members/Get-GitHubOrganizationPendingInvitation
    #>
    [CmdletBinding()]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # Filter invitations by their member role.
        [Parameter()]
        [ValidateSet('all', 'admin', 'direct_member', 'billing_manager', 'hiring_manager')]
        [string] $Role = 'all',

        # Filter invitations by their invitation source.
        [Parameter()]
        [ValidateSet('all', 'member', 'scim')]
        [string] $InvitationSource = 'all',

        # The number of results per page (max 100).
        [Parameter()]
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
        $body = @{
            role              = $Role
            invitation_source = $InvitationSource
        }

        $apiParams = @{
            Method      = 'GET'
            APIEndpoint = "/orgs/$Organization/invitations"
            Body        = $body
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @apiParams | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
