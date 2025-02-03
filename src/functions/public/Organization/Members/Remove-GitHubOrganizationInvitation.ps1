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

        .NOTES
        [Cancel an organization invitation](https://docs.github.com/rest/orgs/members#cancel-an-organization-invitation)
    #>
    [OutputType([bool])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string] $Organization,

        # The unique identifier of the invitation.
        [Parameter(Mandatory)]
        [Alias('invitation_id', 'InvitationID')]
        [string] $ID,

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
        try {
            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/orgs/$Organization/invitations/$ID"
                Method      = 'Delete'
            }

            try {
                if ($PSCmdlet.ShouldProcess('GitHub Organization invitation', 'Remove')) {
                    $null = (Invoke-GitHubAPI @inputObject)
                }
                return $true
            } catch {
                Write-Error $_.Exception.Response
                throw $_
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
