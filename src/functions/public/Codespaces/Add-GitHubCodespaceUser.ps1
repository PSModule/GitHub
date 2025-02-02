function Add-GitHubCodespaceUser {
    <#
    .SYNOPSIS
        Adds users to Codespaces access for an organization.

    .DESCRIPTION
        Codespaces for the specified users will be billed to the organization.
        To use this endpoint, the access settings for the organization must be set to selected_members.
        For information on how to change this setting please see [these docs](https://docs.github.com/rest/codespaces/organizations#manage-access-control-for-organization-codespaces)
        You must authenticate using an access token with the admin:org scope to use this endpoint.

    .PARAMETER Organization
        The organization name. The name is not case sensitive.

    .PARAMETER User
        Handle for the GitHub user account(s).

    .EXAMPLE
        > Add-GitHubCodespaceUser -Organization PSModule -user fake_user_name

    .OUTPUTS
        [PSObject[]]

    .LINK
        https://docs.github.com/en/rest/codespaces/organizations?apiVersion=2022-11-28#add-users-to-codespaces-access-for-an-organization
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
                "Adding users [$($User -join ',')] to GitHub codespace access",
                "Are you sure you want to add $($User -join ',')?",
                'Add codespace users'
            )) {
            $postParams = @{
                APIEndpoint = "/orgs/$Organization/codespaces/access/selected_users"
                Body        = [PSCustomObject]@{ selected_usernames = @($User) } | ConvertTo-Json
                Context     = $Context
                Method      = 'POST'
            }
            Invoke-GitHubAPI @postParams | Select-Object -ExpandProperty Response
        }
    }
}
