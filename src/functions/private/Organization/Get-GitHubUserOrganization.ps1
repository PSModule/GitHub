filter Get-GitHubUserOrganization {
    <#
        .SYNOPSIS
        List organizations for a user

        .DESCRIPTION
        List [public organization memberships](https://docs.github.com/articles/publicizing-or-concealing-organization-membership)
        for the specified user.

        This method only lists _public_ memberships, regardless of authentication.
        If you need to fetch all of the organization memberships (public and private) for the authenticated user, use the
        [List organizations for the authenticated user](https://docs.github.com/rest/orgs/orgs#list-organizations-for-the-authenticated-user)
        API instead.

        .EXAMPLE
        Get-GitHubUserOrganization -Username 'octocat'

        List public organizations for the user 'octocat'.

        .OUTPUTS
        GitHubOrganization

        .LINK
        [List organizations for a user](https://docs.github.com/rest/orgs/orgs#list-organizations-for-a-user)
    #>
    [OutputType([GitHubOrganization])]
    [CmdletBinding()]
    param(
        # The handle for the GitHub user account.
        [Parameter(Mandatory)]
        [string] $Username,

        # The number of results per page (max 100).
        [Parameter()]
        [ValidateRange(0, 100)]
        [int] $PerPage,

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
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/users/$Username/orgs"
            PerPage     = $PerPage
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            $_.Response | ForEach-Object { [GitHubOrganization]::new($_) }
        }
    }
    end {
        Write-Debug "[$stackPath] - End"
    }
}
