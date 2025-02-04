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
    param(
        # The organization name. The name is not case sensitive.
        [Parameter(Mandatory)]
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
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
            filter   = $Filter
            role     = $Role
            per_page = $PerPage
        }

        $inputObject = @{
            Method      = 'Get'
            APIEndpoint = "/orgs/$Organization/members"
            Body        = $body
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
