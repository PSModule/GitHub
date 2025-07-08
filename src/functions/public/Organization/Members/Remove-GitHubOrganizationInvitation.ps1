function Remove-GitHubOrganizationInvitation {
    <#
        .SYNOPSIS
        Cancel an organization invitation

        .DESCRIPTION
        Cancel an organization invitation. In order to cancel an organization invitation, the authenticated user must be an organization owner.

        This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications).

        .EXAMPLE
        Remove-GitHubOrganizationInvitation -Organization 'github' -InvitationID '12345678'

        Cancel the invitation with the ID '12345678' for the organization `github`.

        .INPUTS
        GitHubOrganization

        .OUTPUTS
        void

        .NOTES
        [Cancel an organization invitation](https://docs.github.com/rest/orgs/members#cancel-an-organization-invitation)

        .LINK
        https://psmodule.io/GitHub/Functions/Organization/Members/Remove-GitHubOrganizationInvitation
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Organization,

        # The unique identifier of the invitation.
        [Parameter(Mandatory)]
        [Alias('invitation_id', 'InvitationID')]
        [string] $ID,

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
        $apiParams = @{
            Method      = 'DELETE'
            APIEndpoint = "/orgs/$Organization/invitations/$ID"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess('GitHub Organization invitation', 'Remove')) {
            $null = Invoke-GitHubAPI @apiParams
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
