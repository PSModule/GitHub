function Get-GitHubOrganizationMember {
    <#
        .SYNOPSIS
        List organization members

        .DESCRIPTION
        List all users who are members of an organization.
        If the authenticated user is also a member of this organization then both concealed and public members will be returned.

        .NOTES
        [List organization members](https://docs.github.com/en/rest/orgs/members?apiVersion=2022-11-28#list-organization-members)
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string] $Organization,

        # Filter members returned in the list.
        # `2fa_disabled` means that only members without two-factor authentication enabled will be returned.
        # This options is only available for organization owners.
        [Parameter()]
        [ValidateSet('2fa_disabled', 'all')]
        [string] $Filter = 'all',

        # Filter members returned by their role.
        [Parameter()]
        [ValidateSet('all', 'admin', 'member')]
        [string] $Role = 'all',

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(1, 100)]
        [int] $PerPage = 30,

        # The context to run the command in
        [Parameter()]
        [string] $Context = (Get-GitHubConfig -Name 'DefaultContext')
    )

    $body = @{
        filter   = $Filter
        role     = $Role
        per_page = $PerPage
    }

    $inputObject = @{
        Context     = $Context
        Body        = $body
        Method      = 'Get'
        APIEndpoint = "/orgs/$Organization/members"
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
