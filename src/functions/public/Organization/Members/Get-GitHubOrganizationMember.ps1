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
        [ValidateRange(0, 100)]
        [int] $PerPage,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner : [$($Context.Owner)]"
    }

    process {
        try {
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
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}
