function Remove-GitHubCodespaceUser {
    <#
    .SYNOPSIS
        Removes users from Codespaces access for an organization.

    .DESCRIPTION
        Codespaces for the specified users will no longer be billed to the organization.
        To use this endpoint, the billing settings for the organization must be set to selected_members.
        For information on how to change this setting please see [these docs](https://docs.github.com/rest/codespaces/organizations#manage-access-control-for-organization-codespaces)
        You must authenticate using an access token with the admin:org scope to use this endpoint.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER User
        Handle for the GitHub user account(s).

    .EXAMPLE
        > Remove-GitHubCodespaceUser -Organization PSModule -user fake_user_name

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/organizations?apiVersion=2022-11-28#remove-users-from-codespaces-access-for-an-organization
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$User,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )
    process {
        if ($PSCmdLet.ShouldProcess(
                "Removing user [$($User -join ',')] from GitHub codespace access",
                "Are you sure you want to remove $($User -join ',') from GitHub codespace access?",
                'Remove codespace users'
            )) {
            $delParams = @{
                APIEndpoint = "/orgs/$Organization/codespaces/access/selected_users"
                Body        = [PSCustomObject]@{ selected_usernames = @($User) } | ConvertTo-Json
                Context     = $Context
                Method      = 'DELETE'
            }
            Invoke-GitHubAPI @delParams | Select-Object -ExpandProperty Response
        }
    }
}
